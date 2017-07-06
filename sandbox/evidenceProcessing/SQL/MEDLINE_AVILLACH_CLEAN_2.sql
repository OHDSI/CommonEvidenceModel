with drug_of_ade_step1 as (
  select meshheading.pmid, meshheading.descriptorname, meshheading.descriptorname_ui
  from @sourceSchema.dbo.medcit_meshheadinglist_meshheading meshheading
  join @sourceSchema.dbo.medcit_meshheadinglist_meshheading_qualifiername qualifier
  	on meshheading.pmid = qualifier.pmid
  	and meshheading.medcit_meshheadinglist_meshheading_order = qualifier.medcit_meshheadinglist_meshheading_order
  WHERE meshheading.pmid BETWEEN @start AND @end
  @drugQualifier
),
drug_of_ade AS (
	/*Search for substances*/
	SELECT pmid, descriptorname,descriptorname_ui
	FROM drug_of_ade_step1
	WHERE PMID BETWEEN @start AND @end
	UNION ALL
	SELECT doa.pmid, mt.name AS DESCRIPTORNAME, mt.ui AS DESCRIPTORNAME_UI
	FROM drug_of_ade_step1 doa
		JOIN @sourceSchema.dbo.mesh_ancestor ma
			ON doa.descriptorname_ui = ma.ancestor_ui
		JOIN @sourceSchema.dbo.mesh_term mt
			ON mt.ui = ma.descendant_ui
		JOIN @sourceSchema.dbo.medcit_chemicallist_chemical clc
			ON clc.pmid = doa.pmid
			AND clc.nameofsubstance_ui = mt.ui
	AND doa.PMID BETWEEN @start AND @end
	UNION ALL
	SELECT doa.pmid, mt.name AS DESCRIPTORNAME, mt.ui AS DESCRIPTORNAME_UI
	FROM drug_of_ade_step1 doa
		JOIN @sourceSchema.dbo.mesh_relationship ma
			ON doa.descriptorname_ui = ma.ui_2
		JOIN @sourceSchema.dbo.mesh_term mt
			ON mt.ui = ma.ui_1
		JOIN @sourceSchema.dbo.medcit_chemicallist_chemical clc
			ON clc.pmid = doa.pmid
			AND clc.nameofsubstance_ui = mt.ui
	WHERE doa.PMID BETWEEN @start AND @end
),
effect_of_ade as (
  select meshheading.pmid, meshheading.descriptorname, meshheading.descriptorname_ui
  from @sourceSchema.dbo.medcit_meshheadinglist_meshheading meshheading
  	join @sourceSchema.dbo.medcit_meshheadinglist_meshheading_qualifiername qualifier
  		on meshheading.pmid = qualifier.pmid
  		and meshheading.medcit_meshheadinglist_meshheading_order = qualifier.medcit_meshheadinglist_meshheading_order
  WHERE meshheading.pmid BETWEEN @start AND @end
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
		SELECT PMID FROM @sourceSchema.dbo.medcit_art_abstract_abstracttext WHERE PMID BETWEEN @start AND @end
		UNION ALL
		SELECT pmid FROM @sourceSchema.dbo.medcit_otherabstract_abstracttext WHERE PMID BETWEEN @start AND @end
	 )
	 AND drug_of_ade.pmid IN (
		--PUBMED FILTER:  English[lang]
		SELECT PMID FROM @sourceSchema.dbo.[medcit_art_language] WHERE VALUE = 'ENG' AND PMID BETWEEN @start AND @end
	 )
	 AND drug_of_ade.pmid IN (
		--PUBMED FILTER:  humans[MeSH Terms]
		SELECT PMID FROM @sourceSchema.dbo.medcit_meshheadinglist_meshheading WHERE descriptorname_ui = 'D006801' AND PMID BETWEEN @start AND @end
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
  	AND PMID BETWEEN @start AND @end
  ) as publicationtype
	on ade.pmid = publicationtype.pmid
),
CTE_PMID_INFO_LU AS (
	SELECT m.PMID, ART_ARTTITLE AS ARTICLE_TITLE, a.VALUE AS ABSTRACT,
	  a.medcit_art_abstract_abstracttext_order AS ABSTRACT_ORDER,
		m.art_journal_title AS JOURNAL, m.ART_JOURNAL_ISSN AS ISSN,
		m.art_journal_journalissue_pubdate_year AS PUBLICATION_YEAR
	FROM @sourceSchema.dbo.MEDCIT m
		LEFT OUTER JOIN @sourceSchema.dbo.medcit_art_abstract_abstracttext a
			ON m.PMID = a.PMID
			AND m.PMID BETWEEN @start AND @end
)
INSERT INTO @tableName (SOURCE_ID, SOURCE_CODE_1,
	SOURCE_CODE_TYPE_1, SOURCE_CODE_NAME_1, RELATIONSHIP_ID,
	SOURCE_CODE_2, SOURCE_CODE_TYPE_2,	SOURCE_CODE_NAME_2,
	UNIQUE_IDENTIFIER, UNIQUE_IDENTIFIER_TYPE, ARTICLE_TITLE, ABSTRACT,
	ABSTRACT_ORDER, JOURNAL, ISSN, PUBLICATION_YEAR,PUBLICATION_TYPE)
SELECT DISTINCT
  '@pullName' AS SOURCE_ID,
	rp.DRUG_UI AS SOURCE_CODE_1,
	'MeSH' AS SOURCE_CODE_TYPE_1,
	rp.DRUG AS SOURCE_CODE_NAME_1,
	'Has Adverse Event' AS RELATIONSHIP_ID,
	rp.EFFECT_UI AS SOURCE_CODE_2,
	'MeSH' AS SOURCE_CODE_TYPE_2,
	rp.EFFECT AS SOURCE_CODE_NAME_2,
	rp.PMID AS UNIQUE_IDENTIFIER,
	'PMID' AS UNIQUE_IDENTIFIER_TYPE,
	i.ARTICLE_TITLE, i.ABSTRACT, i.ABSTRACT_ORDER,
	i.JOURNAL, i.ISSN, i.PUBLICATION_YEAR,
	rp.pub_type_value AS PUBLICATION_TYPE
FROM CTE_RELEVANT_PMIDS rp
	LEFT OUTER JOIN CTE_PMID_INFO_LU i
		ON i.PMID = rp.PMID;
