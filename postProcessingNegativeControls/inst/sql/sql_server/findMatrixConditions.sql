IF OBJECT_ID('@storeData', 'U') IS NOT NULL DROP TABLE @storeData;

SELECT *
INTO @storeData
FROM (

  select distinct c1.CONCEPT_ID, c1.CONCEPT_NAME
  FROM @cemEvidence cu
  	JOIN @vocabulary.CONCEPT c1
  		on cu.concept_id_2 = c1.concept_id
  WHERE c1.DOMAIN_ID = 'condition'
  and SOURCE_ID IN ('medline_avillach','MEDLINE_PUBMED','medline_winnenburg','semmeddb', 'aeolus', 'splicer','eu_pl_adr')
  and cu.concept_id_2 not in (
  	select concept_id from @broadConceptsData
  	UNION ALL
  	select concept_id from @pregnancyConditionData
  	UNION ALL
  	select concept_id from @drugInducedConditionsData
  )
  AND c1.CONCEPT_ID in (
  	/*LITERATURE*/
  	SELECT CONCEPT_ID
  	FROM @vocabulary.CONCEPT c1
  	WHERE CONCEPT_ID IN (
  		select ca.descendant_concept_id
  		from @cemEvidence cu
  			JOIN @vocabulary.CONCEPT_ANCESTOR ca
  				on ca.ancestor_concept_id = cu.concept_id_2
  		WHERE SOURCE_ID IN ('medline_avillach','MEDLINE_PUBMED','medline_winnenburg','semmeddb')
  		UNION ALL
  		select ca.ANCESTOR_concept_id
  		from @cemEvidence cu
  			JOIN @vocabulary.CONCEPT_ANCESTOR ca
  				on ca.DESCENDANT_concept_id = cu.concept_id_2
  		WHERE SOURCE_ID IN ('medline_avillach','MEDLINE_PUBMED','medline_winnenburg','semmeddb')
  	)
  )
  AND c1.CONCEPT_ID IN (
  	/*SPONTANEOUS REPORT*/
  	SELECT CONCEPT_ID
  	FROM @vocabulary.CONCEPT c1
  	WHERE CONCEPT_ID IN (
  		select ca.descendant_concept_id
  		from @cemEvidence cu
  			JOIN @vocabulary.CONCEPT_ANCESTOR ca
  				on ca.ancestor_concept_id = cu.concept_id_2
  		WHERE SOURCE_ID IN ('aeolus')
  		UNION ALL
  		select ca.ANCESTOR_concept_id
  		from @cemEvidence cu
  			JOIN @vocabulary.CONCEPT_ANCESTOR ca
  				on ca.DESCENDANT_concept_id = cu.concept_id_2
  		WHERE SOURCE_ID IN ('aeolus')
  	)
  )
  AND c1.CONCEPT_ID IN (
  	/*LABELS*/
  	SELECT CONCEPT_ID
  	FROM @vocabulary.CONCEPT c1
  	WHERE CONCEPT_ID IN (
  		select ca.descendant_concept_id
  		from @cemEvidence cu
  			JOIN @vocabulary.CONCEPT_ANCESTOR ca
  				on ca.ancestor_concept_id = cu.concept_id_2
  		WHERE SOURCE_ID IN ('splicer','eu_pl_adr')
  		UNION ALL
  		select ca.ANCESTOR_concept_id
  		from @cemEvidence cu
  			JOIN @vocabulary.CONCEPT_ANCESTOR ca
  				on ca.DESCENDANT_concept_id = cu.concept_id_2
  		WHERE SOURCE_ID IN ('splicer','eu_pl_adr')
  	)
  )

);

CREATE INDEX IDX_MATRIX_CONDITION ON @storeData (CONDITION_CONCEPT_ID);
