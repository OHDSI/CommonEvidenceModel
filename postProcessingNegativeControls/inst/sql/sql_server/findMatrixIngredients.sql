IF OBJECT_ID('@storeData', 'U') IS NOT NULL DROP TABLE @storeData;

SELECT *
INTO @storeData
FROM (

  SELECT concept_id as INGREDIENT_CONCEPT_ID
  FROM (
  	SELECT DISTINCT c1.concept_id
  	FROM @cemEvidence cu
  	JOIN @vocabulary.CONCEPT_ANCESTOR ca ON ca.DESCENDANT_CONCEPT_ID = cu.CONCEPT_ID_1
  	JOIN @vocabulary.CONCEPT c1 ON c1.CONCEPT_ID = ca.ANCESTOR_CONCEPT_ID
  			AND c1.DOMAIN_ID = 'Drug'
  			AND c1.CONCEPT_CLASS_ID = 'Ingredient'
  			AND c1.STANDARD_CONCEPT = 'S'
  	WHERE SOURCE_ID IN ('medline_avillach','MEDLINE_PUBMED','medline_winnenburg')
  ) literature

  INTERSECT

  /*SPONTANEOUS REPORTS*/
  SELECT concept_id as INGREDIENT_CONCEPT_ID
  FROM (
  	SELECT DISTINCT c1.concept_id
  	FROM @cemEvidence cu
  	JOIN @vocabulary.CONCEPT_ANCESTOR ca ON ca.DESCENDANT_CONCEPT_ID = cu.CONCEPT_ID_1
  	JOIN @vocabulary.CONCEPT c1 ON c1.CONCEPT_ID = ca.ANCESTOR_CONCEPT_ID
  		AND c1.DOMAIN_ID = 'Drug'
  		AND c1.CONCEPT_CLASS_ID = 'Ingredient'
  		AND c1.STANDARD_CONCEPT = 'S'
  	WHERE SOURCE_ID IN ('aeolus')
  ) spontaneous_reports

  INTERSECT

  /*LABELS*/
  SELECT concept_id as INGREDIENT_CONCEPT_ID
  FROM (
  	SELECT DISTINCT c1.concept_id
  	FROM @cemEvidence cu
  	JOIN @vocabulary.CONCEPT_ANCESTOR ca ON ca.DESCENDANT_CONCEPT_ID = cu.CONCEPT_ID_1
  	JOIN @vocabulary.CONCEPT c1	ON c1.CONCEPT_ID = ca.ANCESTOR_CONCEPT_ID
  		AND c1.DOMAIN_ID = 'Drug'
  		AND c1.CONCEPT_CLASS_ID = 'Ingredient'
  		AND c1.STANDARD_CONCEPT = 'S'
  	WHERE SOURCE_ID IN ('splicer','eu_pl_adr')
  ) labels

) z;


CREATE INDEX IDX_MATRIX_INGREDIENTS ON @storeData (INGREDIENT_CONCEPT_ID);
