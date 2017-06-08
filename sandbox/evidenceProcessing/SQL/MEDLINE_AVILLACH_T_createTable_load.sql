IF OBJECT_ID('@tableName','U') IS NOT NULL
DROP TABLE @tableName;

CREATE TABLE @tableName (
  ID INT IDENTITY(1,1) PRIMARY KEY,
	SOURCE_ID	VARCHAR(20),
	SOURCE_CODE_1	VARCHAR(50),
	SOURCE_CODE_TYPE_1	VARCHAR(55),
	SOURCE_CODE_NAME_1	VARCHAR(255),
	CONCEPT_ID_1	INT,
	RELATIONSHIP_ID	VARCHAR(20),
	SOURCE_CODE_2	VARCHAR(50),
	SOURCE_CODE_TYPE_2	VARCHAR(55),
	SOURCE_CODE_NAME_2	VARCHAR(255),
	CONCEPT_ID_2	INT,
	UNIQUE_IDENTIFIER	VARCHAR(50),
	UNIQUE_IDENTIFIER_TYPE	VARCHAR(50),
  ARTICLE_TITLE VARCHAR(MAX),
  ABSTRACT VARCHAR(MAX),
  ABSTRACT_ORDER INT,
  JOURNAL VARCHAR(255),
  ISSN VARCHAR(255),
  PUBLICATION_YEAR INT,
  PUBLICATION_TYPE VARCHAR(255)
);

with drug_of_ade_step1 as (
 select meshheading.pmid, meshheading.descriptorname, meshheading.descriptorname_ui
 from @sourceSchema.dbo.medcit_meshheadinglist_meshheading meshheading
	join @sourceSchema.dbo.medcit_meshheadinglist_meshheading_qualifiername qualifier
		on meshheading.pmid = qualifier.pmid
		and meshheading.medcit_meshheadinglist_meshheading_order = qualifier.medcit_meshheadinglist_meshheading_order
 @drugQualifier
),
drug_of_ade AS (
	/*Search for substances*/
	SELECT pmid, descriptorname,descriptorname_ui
	FROM drug_of_ade_step1
	UNION
	SELECT doa.pmid, mt.name AS DESCRIPTORNAME, mt.ui AS DESCRIPTORNAME_UI
	FROM drug_of_ade_step1 doa
		JOIN @sourceSchema.dbo.mesh_ancestor ma
			ON doa.descriptorname_ui = ma.ancestor_ui
		JOIN @sourceSchema.dbo.mesh_term mt
			ON mt.ui = ma.descendant_ui
		JOIN @sourceSchema.dbo.medcit_chemicallist_chemical clc
			ON clc.pmid = doa.pmid
			AND clc.nameofsubstance_ui = mt.ui
	UNION
	SELECT doa.pmid, mt.name AS DESCRIPTORNAME, mt.ui AS DESCRIPTORNAME_UI
	FROM drug_of_ade_step1 doa
		JOIN @sourceSchema.dbo.mesh_relationship ma
			ON doa.descriptorname_ui = ma.ui_2
		JOIN @sourceSchema.dbo.mesh_term mt
			ON mt.ui = ma.ui_1
		JOIN @sourceSchema.dbo.medcit_chemicallist_chemical clc
			ON clc.pmid = doa.pmid
			AND clc.nameofsubstance_ui = mt.ui
),
effect_of_ade as (
select meshheading.pmid, meshheading.descriptorname, meshheading.descriptorname_ui
from @sourceSchema.dbo.medcit_meshheadinglist_meshheading meshheading
	join @sourceSchema.dbo.medcit_meshheadinglist_meshheading_qualifiername qualifier
		on meshheading.pmid = qualifier.pmid
		and meshheading.medcit_meshheadinglist_meshheading_order = qualifier.medcit_meshheadinglist_meshheading_order
@conditionQualifier
),
CTE_RELEVANT_PMIDS AS (
	select ade.pmid, drug, drug_ui, effect, effect_ui, pub_type_value, pub_type_ui
	from
	(
	 select drug_of_ade.pmid pmid,
			drug_of_ade.descriptorname drug,
			drug_of_ade.descriptorname_ui drug_ui,
			effect_of_ade.descriptorname effect,
			effect_of_ade.descriptorname_ui effect_ui
	 from drug_of_ade inner join effect_of_ade
	 on drug_of_ade.pmid = effect_of_ade.pmid
	 AND drug_of_ade.pmid IN (
		--PUBMED FILTER:  hasabstract[text]
		SELECT DISTINCT PMID FROM @sourceSchema.dbo.medcit_art_abstract_abstracttext
		UNION
		SELECT DISTINCT pmid FROM @sourceSchema.dbo.medcit_otherabstract_abstracttext
	 )
	 AND drug_of_ade.pmid IN (
		--PUBMED FILTER:  English[lang]
		SELECT DISTINCT PMID FROM @sourceSchema.dbo.[medcit_art_language] WHERE VALUE = 'ENG'
	 )
	 AND drug_of_ade.pmid IN (
		--PUBMED FILTER:  humans[MeSH Terms]
		SELECT DISTINCT PMID FROM @sourceSchema.dbo.medcit_meshheadinglist_meshheading WHERE descriptorname_ui = 'D006801'
	 )
	) as ade
	inner join
	(
	  select pmid,
			value AS pub_type_value,
			ui pub_type_ui
	  from @sourceSchema.dbo.medcit_art_publicationtypelist_publicationtype
	  where value in ('Case Reports','Clinical Trial','Meta-Analysis','Comparative Study','Multicenter Study','Journal Article','Controlled Clinical Trial',
		'Clinical Trial, Phase I','Clinical Trial, Phase II','Clinical Trial, Phase III','Clinical Trial, Phase IV', 'Randomized Controlled Trial','Observational Study')
	) as publicationtype
	on ade.pmid = publicationtype.pmid
),
CTE_MESH_TO_STANDARD_MAPPING AS (
	SELECT c1.CONCEPT_CODE, c1.CONCEPT_ID, c1.CONCEPT_NAME,
		c2.CONCEPT_ID AS STANDARD_CONCEPT_ID, c2.CONCEPT_NAME AS STANDARD_CONCEPT_NAME
	FROM VOCABULARY.dbo.CONCEPT c1
		JOIN VOCABULARY.dbo.CONCEPT_RELATIONSHIP cr
			ON cr.CONCEPT_ID_1 = c1.CONCEPT_ID
			AND (
				cr.INVALID_REASON IS NULL
				OR cr.INVALID_REASON = ''
			)
		JOIN VOCABULARY.dbo.CONCEPT c2
			ON c2.CONCEPT_ID = cr.CONCEPT_ID_2
	WHERE c1.VOCABULARY_ID = 'Mesh'
	AND c2.DOMAIN_ID IN ('Condition','Drug')
),
CTE_PMID_INFO_LU AS (
	SELECT m.PMID, ART_ARTTITLE AS ARTICLE_TITLE, a.VALUE AS ABSTRACT,
	  a.medcit_art_abstract_abstracttext_order AS ABSTRACT_ORDER,
		m.art_journal_title AS JOURNAL, m.ART_JOURNAL_ISSN AS ISSN,
		m.art_journal_journalissue_pubdate_year AS PUBLICATION_YEAR
	FROM @sourceSchema.dbo.MEDCIT m
		LEFT OUTER JOIN @sourceSchema.dbo.medcit_art_abstract_abstracttext a
			ON m.PMID = a.PMID
)
INSERT INTO @tableName (SOURCE_ID, SOURCE_CODE_1,
	SOURCE_CODE_TYPE_1, SOURCE_CODE_NAME_1, CONCEPT_ID_1, RELATIONSHIP_ID,
	SOURCE_CODE_2, SOURCE_CODE_TYPE_2,	SOURCE_CODE_NAME_2, CONCEPT_ID_2,
	UNIQUE_IDENTIFIER, UNIQUE_IDENTIFIER_TYPE, ARTICLE_TITLE, ABSTRACT,
	ABSTRACT_ORDER, JOURNAL, ISSN, PUBLICATION_YEAR,PUBLICATION_TYPE)
SELECT DISTINCT
  'MEDLINE_AVILLACH' AS SOURCE_ID,
	rp.DRUG_UI AS SOURCE_CODE_1,
	'MeSH' AS SOURCE_CODE_TYPE_1,
	rp.DRUG AS SOURCE_CODE_NAME_1,
	CASE WHEN m1.STANDARD_CONCEPT_ID IS NULL THEN 0 ELSE m1.STANDARD_CONCEPT_ID END AS CONCEPT_ID_1,
	'Has Adverse Event' AS RELATIONSHIP_ID,
	rp.EFFECT_UI AS SOURCE_CODE_2,
	'MeSH' AS SOURCE_CODE_TYPE_2,
	rp.EFFECT AS SOURCE_CODE_NAME_2,
	CASE WHEN m2.STANDARD_CONCEPT_ID IS NULL THEN 0 ELSE m2.STANDARD_CONCEPT_ID END AS CONCEPT_ID_2,
	rp.PMID AS UNIQUE_IDENTIFIER,
	'PMID' AS UNIQUE_IDENTIFIER_TYPE,
	i.ARTICLE_TITLE, i.ABSTRACT, i.ABSTRACT_ORDER,
	i.JOURNAL, i.ISSN, i.PUBLICATION_YEAR,
	rp.pub_type_value AS PUBLICATION_TYPE
FROM CTE_RELEVANT_PMIDS rp
	LEFT OUTER JOIN CTE_MESH_TO_STANDARD_MAPPING m1
		ON m1.CONCEPT_CODE = rp.DRUG_UI
	LEFT OUTER JOIN CTE_MESH_TO_STANDARD_MAPPING m2
		ON m2.CONCEPT_CODE = rp.EFFECT_UI
	LEFT OUTER JOIN CTE_PMID_INFO_LU i
		ON i.PMID = rp.PMID

CREATE INDEX IDX_UNIQUE_@tableName_IDENTIFIER_DRUG_CONCEPT_ID_1_DRUG_CONCEPT_ID_2 ON @tableName (UNIQUE_IDENTIFIER, CONCEPT_ID_1, CONCEPT_ID_2);
