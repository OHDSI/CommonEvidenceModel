/*
Winnenburg R, Sorbello A, Ripple A, Harpaz R, Tonning J, Szarfman A, Francis
H, Bodenreider O. Leveraging MEDLINE indexing for pharmacovigilance - Inherent
limitations and mitigation strategies. J Biomed Inform. 2015 Oct;57:425-35. doi:
10.1016/j.jbi.2015.08.022. Epub 2015 Sep 2. PubMed PMID: 26342964; PubMed Central
PMCID: PMC4775467.
*/

IF OBJECT_ID('tempdb..#TEMP_DRUG', 'U') IS NOT NULL DROP TABLE #TEMP_DRUG;
IF OBJECT_ID('tempdb..#TEMP_CONDITION', 'U') IS NOT NULL DROP TABLE #TEMP_CONDITION;
IF OBJECT_ID('tempdb..#TEMP_RUNNING_PMID', 'U') IS NOT NULL DROP TABLE #TEMP_RUNNING_PMID;

{@i == 1}?{
	/*RUN THE FIRST ITERATION*/
	IF OBJECT_ID('@targetTable','U') IS NOT NULL DROP TABLE @targetTable;

	CREATE TABLE @targetTable (
		ID SERIAL,
		SOURCE_ID	VARCHAR(30),
		SOURCE_CODE_1	VARCHAR(50),
		SOURCE_CODE_TYPE_1	VARCHAR(55),
		SOURCE_CODE_NAME_1	VARCHAR(255),
		RELATIONSHIP_ID	VARCHAR(20),
		SOURCE_CODE_2	VARCHAR(50),
		SOURCE_CODE_TYPE_2	VARCHAR(55),
		SOURCE_CODE_NAME_2	VARCHAR(255),
		UNIQUE_IDENTIFIER	VARCHAR(50),
		UNIQUE_IDENTIFIER_TYPE	VARCHAR(50),
		ARTICLE_TITLE VARCHAR(MAX),
		JOURNAL VARCHAR(255),
		ISSN VARCHAR(255),
		PUBLICATION_YEAR INT,
		PUBLICATION_TYPE VARCHAR(255)
	);

	IF OBJECT_ID('tempdb..#TEMP_ENGLISH_PMID', 'U') IS NOT NULL DROP TABLE #TEMP_ENGLISH_PMID;
	SELECT PMID
	INTO #TEMP_ENGLISH_PMID
	FROM @sourceSchema.medcit_art_language
	WHERE upper(VALUE) = 'ENG';
	CREATE INDEX IDX_TEMP_ENGLISH_PMID ON #TEMP_ENGLISH_PMID (PMID);

	IF OBJECT_ID('tempdb..#TEMP_HUMAN_MESH_PMID', 'U') IS NOT NULL DROP TABLE #TEMP_HUMAN_MESH_PMID;
	SELECT h.PMID
	INTO #TEMP_HUMAN_MESH_PMID
	FROM @sourceSchema.medcit_meshheadinglist_meshheading h
	WHERE descriptorname_ui = 'D006801';
	CREATE INDEX IDX_TEMP_HUMAN_MESH_PMID ON #TEMP_HUMAN_MESH_PMID (PMID);

	IF OBJECT_ID('tempdb..#TEMP_PUB_TYPE', 'U') IS NOT NULL DROP TABLE #TEMP_PUB_TYPE;
	select pmid, value AS pub_type_value, ui AS pub_type_ui
	INTO #TEMP_PUB_TYPE
	from @sourceSchema.medcit_art_publicationtypelist_publicationtype
	where lower(value) in ('case reports','clinical trial','meta-analysis','comparative study','multicenter study','journal article','controlled clinical trial','clinical trial, phase i','clinical trial, phase ii','clinical trial, phase iii','clinical trial, phase iv', 'randomized controlled trial','observational study');
	CREATE INDEX IDX_TEMP_ACCEPTABLE_PUB_TYPES ON #TEMP_PUB_TYPE (PMID);

	/*BASED ON PMIDS WITH CERTAIN QUALITIES WHICH ONES WILL WE REVIEW*/
	IF OBJECT_ID('tempdb..#TEMP_ACCEPTABLE_PMID', 'U') IS NOT NULL DROP TABLE #TEMP_ACCEPTABLE_PMID;
	SELECT PMID
	INTO #TEMP_ACCEPTABLE_PMID
	FROM (
		SELECT PMID
		FROM TEMP_ENGLISH_PMID
		INTERSECT
		SELECT PMID
		FROM TEMP_HUMAN_MESH_PMID
		INTERSECT
		SELECT PMID
		FROM TEMP_PUB_TYPE
	) z;
	CREATE INDEX IDX_TEMP_ACCEPTABLE_PMID ON TEMP_ACCEPTABLE_PMID (PMID);

}

SELECT *
INTO #TEMP_RUNNING_PMID
FROM TEMP_ACCEPTABLE_PMID
WHERE PMID BETWEEN @start AND @end;
CREATE INDEX IDX_TEMP_RUNNING_PMID ON TEMP_RUNNING_PMID (PMID);

select meshheading.pmid, meshheading.descriptorname, meshheading.descriptorname_ui
INTO #TEMP_DRUG
from @sourceSchema.medcit_meshheadinglist_meshheading meshheading
	JOIN TEMP_RUNNING_PMID rp
		ON rp.PMID = meshheading.PMID
	join @sourceSchema.medcit_meshheadinglist_meshheading_qualifiername qualifier
		on meshheading.pmid = qualifier.pmid
		and meshheading.medcit_meshheadinglist_meshheading_order = qualifier.medcit_meshheadinglist_meshheading_order
		AND qualifier.ui IN (
		  	'Q000009', /*adverse effects*/
      	'Q000506', /*poisoning*/
      	'Q000633', /*toxivity*/
      	'Q000744'  /*contraindications*/
		);
CREATE INDEX IDX_TEMP_DRUG ON #TEMP_DRUG (PMID);

select meshheading.pmid, meshheading.descriptorname, meshheading.descriptorname_ui
INTO #TEMP_CONDITION
from @sourceSchema.medcit_meshheadinglist_meshheading meshheading
	JOIN TEMP_RUNNING_PMID rp
		ON rp.PMID = meshheading.PMID
	join @sourceSchema.medcit_meshheadinglist_meshheading_qualifiername qualifier
		on qualifier.pmid=  rp.pmid
		and meshheading.medcit_meshheadinglist_meshheading_order = qualifier.medcit_meshheadinglist_meshheading_order
WHERE (
  qualifier.UI = 'Q000139' /*chemically induced*/
  OR
  meshheading.descriptorname_ui IN (
    /*The following MeSH terms imply denoting the chemically induced qualifier*/
    'D056486','D004893','D013262','D004409','D004409','D055963','D000014','D003875','D017109','D020230','D009459','D064807','D063926','D056487','D060831','D020267','D011605','D056150','D064146','D020258'
  )
);
CREATE INDEX IDX_TEMP_CONDITION ON #TEMP_CONDITION (PMID);

with drug_of_ade_step1 as (
		SELECT *
		FROM #TEMP_DRUG
),
drug_of_ade AS (
	/*Search for substances*/
	SELECT pmid, descriptorname,descriptorname_ui
	FROM drug_of_ade_step1
	UNION ALL
	SELECT doa.pmid, mt.name AS DESCRIPTORNAME, mt.ui AS DESCRIPTORNAME_UI
	FROM drug_of_ade_step1 doa
		JOIN @sourceSchema.mesh_ancestor ma
			ON doa.descriptorname_ui = ma.ancestor_ui
		JOIN @sourceSchema.mesh_term mt
			ON mt.ui = ma.descendant_ui
		JOIN @sourceSchema.medcit_chemicallist_chemical clc
			ON clc.pmid = doa.pmid
			AND clc.nameofsubstance_ui = mt.ui
	UNION ALL
	SELECT doa.pmid, mt.name AS DESCRIPTORNAME, mt.ui AS DESCRIPTORNAME_UI
	FROM drug_of_ade_step1 doa
		JOIN @sourceSchema.mesh_relationship ma
			ON doa.descriptorname_ui = ma.ui_2
		JOIN @sourceSchema.mesh_term mt
			ON mt.ui = ma.ui_1
		JOIN @sourceSchema.medcit_chemicallist_chemical clc
			ON clc.pmid = doa.pmid
			AND clc.nameofsubstance_ui = mt.ui
),
effect_of_ade as (
		SELECT *
		FROM #TEMP_CONDITION
),
CTE_RELEVANT_PMIDS AS (
	select ade.pmid, drug, drug_ui, effect, effect_ui, pub_type_value, pub_type_ui
	from (
		select drug_of_ade.pmid pmid,
			drug_of_ade.descriptorname drug,
			drug_of_ade.descriptorname_ui drug_ui,
			effect_of_ade.descriptorname effect,
			effect_of_ade.descriptorname_ui effect_ui
		from drug_of_ade
			join effect_of_ade
				on drug_of_ade.pmid = effect_of_ade.pmid
	) as ade
		join #TEMP_PUB_TYPE publicationtype
			on ade.pmid = publicationtype.pmid
)
INSERT INTO @targetTable (SOURCE_ID, SOURCE_CODE_1,
	SOURCE_CODE_TYPE_1, SOURCE_CODE_NAME_1, RELATIONSHIP_ID,
	SOURCE_CODE_2, SOURCE_CODE_TYPE_2, SOURCE_CODE_NAME_2,
	UNIQUE_IDENTIFIER, UNIQUE_IDENTIFIER_TYPE, ARTICLE_TITLE,
	JOURNAL, ISSN, PUBLICATION_YEAR,PUBLICATION_TYPE)
SELECT DISTINCT
	'@sourceID' AS SOURCE_ID,
	rp.DRUG_UI AS SOURCE_CODE_1,
	'MeSH' AS SOURCE_CODE_TYPE_1,
	rp.DRUG AS SOURCE_CODE_NAME_1,
	'Has Adverse Event' AS RELATIONSHIP_ID,
	rp.EFFECT_UI AS SOURCE_CODE_2,
	'MeSH' AS SOURCE_CODE_TYPE_2,
	rp.EFFECT AS SOURCE_CODE_NAME_2,
	rp.PMID AS UNIQUE_IDENTIFIER,
	'PMID' AS UNIQUE_IDENTIFIER_TYPE,
	i.ART_ARTTITLE AS ARTICLE_TITLE,
	i.art_journal_title AS JOURNAL,
	i.ART_JOURNAL_ISSN AS ISSN,
	i.art_journal_journalissue_pubdate_year AS PUBLICATION_YEAR,
	rp.pub_type_value AS PUBLICATION_TYPE
FROM CTE_RELEVANT_PMIDS rp
	LEFT OUTER JOIN @sourceSchema.MEDCIT i
		ON i.PMID = rp.PMID;

{@i == @iteraterNum}?{
  /*RUN THE LAST ITERATION*/
  CREATE INDEX IDX_@sourceID_SOURCE_CODE_1_SOURCE_CODE_2 ON @targetTable (SOURCE_CODE_1,SOURCE_CODE_2);

  ALTER TABLE @targetTable OWNER TO RW_GRP;
}
