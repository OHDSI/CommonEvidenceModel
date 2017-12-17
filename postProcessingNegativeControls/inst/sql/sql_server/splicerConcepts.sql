IF OBJECT_ID('@storeData', 'U') IS NOT NULL DROP TABLE @storeData;

{@outcomeOfInterest == 'condition'}?{
  SELECT DISTINCT DESCENDANT_CONCEPT_ID AS CONCEPT_ID
  INTO @storeData
  FROM @vocabulary.CONCEPT_ANCESTOR ca
  WHERE CAST(ca.ANCESTOR_CONCEPT_ID AS VARCHAR(50)) IN (
  	SELECT SOURCE_CODE_2
  	FROM @splicerData s
  		JOIN @vocabulary.CONCEPT_ANCESTOR ca
  			ON ca.DESCENDANT_CONCEPT_ID = s.CONCEPT_ID_1
  		JOIN @vocabulary.CONCEPT c1
  			ON c1.CONCEPT_ID = ca.ANCESTOR_CONCEPT_ID
  			AND lower(c1.CONCEPT_CLASS_ID) = 'ingredient'
  			AND c1.CONCEPT_ID IN (@conceptsOfInterest)
  	WHERE SOURCE_CODE_2 IS NOT NULL
  );
}

{@outcomeOfInterest == 'drug'}?{
  SELECT DISTINCT CONCEPT_ID AS CONCEPT_ID
  INTO @storeData
  FROM (
    SELECT DISTINCT DESCENDANT_CONCEPT_ID AS CONCEPT_ID
    FROM @vocabulary.CONCEPT_ANCESTOR ca
    WHERE ca.ANCESTOR_CONCEPT_ID IN (
    	SELECT CONCEPT_ID_1
    	FROM @splicerData s
    		JOIN @vocabulary.CONCEPT_ANCESTOR ca
    			ON ca.DESCENDANT_CONCEPT_ID = s.CONCEPT_ID_2
    		JOIN @vocabulary.CONCEPT c1
    			ON c1.CONCEPT_ID = ca.ANCESTOR_CONCEPT_ID
    			AND c1.CONCEPT_ID IN (@conceptsOfInterest)
    	WHERE SOURCE_CODE_1 IS NOT NULL
    )
    UNION ALL
    SELECT DISTINCT c.CONCEPT_ID AS CONCEPT_ID
    FROM @vocabulary.CONCEPT_ANCESTOR ca
  	JOIN @vocabulary.CONCEPT c
  		ON c.CONCEPT_ID = ca.ANCESTOR_CONCEPT_ID
  		AND lower(c.DOMAIN_ID) = 'drug'
  		AND lower(c.standard_concept) = 's'
    WHERE ca.DESCENDANT_CONCEPT_ID IN (
    	SELECT CONCEPT_ID_1
    	FROM @splicerData s
    		JOIN @vocabulary.CONCEPT_ANCESTOR ca
    			ON ca.DESCENDANT_CONCEPT_ID = s.CONCEPT_ID_2
    		JOIN @vocabulary.CONCEPT c1
    			ON c1.CONCEPT_ID = ca.ANCESTOR_CONCEPT_ID
    			AND c1.CONCEPT_ID IN (@conceptsOfInterest)
    	WHERE SOURCE_CODE_1 IS NOT NULL
    )
  ) z;
}

CREATE INDEX IDX_SPLICER_CONCEPT_ID ON @storeData (CONCEPT_ID);

ALTER TABLE @storeData OWNER TO RW_GRP;


