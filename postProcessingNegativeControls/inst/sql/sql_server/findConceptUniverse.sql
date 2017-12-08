{@outcomeOfInterest == 'condition'}?{
  /*Find conditions after exposure to drug*/
  /*Drug is first exposure*/
  WITH CTE_DC AS (
  	SELECT c.CONCEPT_ID, c.CONCEPT_NAME,
  		COUNT_BIG(DISTINCT co.PERSON_ID) AS PERSON_COUNT_DC
  	FROM (
    		SELECT PERSON_ID, MIN(de.DRUG_EXPOSURE_START_DATE) AS INDEX_DATE
    		FROM @schemaRaw.DRUG_EXPOSURE de
    		WHERE DRUG_CONCEPT_ID IN (
    			SELECT DESCENDANT_CONCEPT_ID FROM @schemaRaw.CONCEPT_ANCESTOR WHERE ANCESTOR_CONCEPT_ID IN (@conceptsOfInterest)
    		)
    		GROUP BY PERSON_ID
  	) i
  		JOIN @schemaRaw.OBSERVATION_PERIOD op
    			ON op.PERSON_ID = i.PERSON_ID
    			AND i.INDEX_DATE BETWEEN op.OBSERVATION_PERIOD_START_DATE AND op.OBSERVATION_PERIOD_END_DATE
    			AND DATEDIFF(dd,op.OBSERVATION_PERIOD_START_DATE,i.INDEX_DATE) >= 180
  		JOIN @schemaRaw.CONDITION_OCCURRENCE co
  			ON co.PERSON_ID = i.PERSON_ID
  			AND i.INDEX_DATE <= co.CONDITION_START_DATE
  		JOIN @schemaRaw.CONCEPT_ANCESTOR ca
  			ON ca.ANCESTOR_CONCEPT_ID = co.CONDITION_CONCEPT_ID
  		JOIN @schemaRaw.CONCEPT c
  			ON c.CONCEPT_ID = ca.DESCENDANT_CONCEPT_ID
  			AND UPPER(c.DOMAIN_ID) = 'CONDITION'
  			AND UPPER(c.STANDARD_CONCEPT) = 'S'
  	GROUP BY c.CONCEPT_ID, c.CONCEPT_NAME
  	HAVING COUNT_BIG(DISTINCT co.PERSON_ID) >= @filter
  ),
  CTE_RC AS (
  	SELECT c.CONCEPT_ID, c.CONCEPT_NAME,
  		COUNT_BIG(DISTINCT co.PERSON_ID) AS PERSON_COUNT_RC
  	FROM (
    		SELECT PERSON_ID, MIN(de.DRUG_EXPOSURE_START_DATE) AS INDEX_DATE
    		FROM @schemaRaw.DRUG_EXPOSURE de
    		WHERE DRUG_CONCEPT_ID IN (
    			SELECT DESCENDANT_CONCEPT_ID FROM @schemaRaw.CONCEPT_ANCESTOR WHERE ANCESTOR_CONCEPT_ID IN (@conceptsOfInterest)
    		)
    		GROUP BY PERSON_ID
  	) i
  		JOIN @schemaRaw.OBSERVATION_PERIOD op
    			ON op.PERSON_ID = i.PERSON_ID
    			AND i.INDEX_DATE BETWEEN op.OBSERVATION_PERIOD_START_DATE AND op.OBSERVATION_PERIOD_END_DATE
    			AND DATEDIFF(dd,op.OBSERVATION_PERIOD_START_DATE,i.INDEX_DATE) >= 180
  		JOIN @schemaRaw.CONDITION_OCCURRENCE co
  			ON co.PERSON_ID = i.PERSON_ID
  			AND i.INDEX_DATE <= co.CONDITION_START_DATE
  		JOIN @schemaRaw.CONCEPT c
  			ON c.CONCEPT_ID = co.CONDITION_CONCEPT_ID
  			AND UPPER(c.DOMAIN_ID) = 'CONDITION'
  			AND UPPER(c.STANDARD_CONCEPT) = 'S'
  	GROUP BY c.CONCEPT_ID, c.CONCEPT_NAME
  	HAVING COUNT_BIG(DISTINCT co.PERSON_ID) >= @filter
  )
  SELECT dc.CONCEPT_ID, dc.CONCEPT_NAME, rc.PERSON_COUNT_RC, dc.PERSON_COUNT_DC
  FROM CTE_DC dc
  	LEFT OUTER JOIN CTE_RC rc
  		ON rc.CONCEPT_ID = dc.CONCEPT_ID
  ORDER BY dc.PERSON_COUNT_DC DESC, rc.PERSON_COUNT_RC DESC, dc.CONCEPT_NAME;
}

{@outcomeOfInterest == 'drug'}?{
  /*Find drugs after condition*/
  /*Condition is first exposure*/
  WITH CTE_DC AS (
  	SELECT c.CONCEPT_ID, c.CONCEPT_NAME,
  		COUNT_BIG(DISTINCT co.PERSON_ID) AS PERSON_COUNT_DC
  	FROM (
    		SELECT PERSON_ID, MIN(de.DRUG_EXPOSURE_START_DATE) AS INDEX_DATE
    		FROM @schemaRaw.DRUG_EXPOSURE de
    		WHERE DRUG_CONCEPT_ID IN (
    			SELECT DESCENDANT_CONCEPT_ID FROM @schemaRaw.CONCEPT_ANCESTOR WHERE ANCESTOR_CONCEPT_ID IN (@conceptsOfInterest)
    		)
    		GROUP BY PERSON_ID
  	) i
  		JOIN @schemaRaw.OBSERVATION_PERIOD op
    			ON op.PERSON_ID = i.PERSON_ID
    			AND i.INDEX_DATE BETWEEN op.OBSERVATION_PERIOD_START_DATE AND op.OBSERVATION_PERIOD_END_DATE
    			AND DATEDIFF(dd,op.OBSERVATION_PERIOD_START_DATE,i.INDEX_DATE) >= 180
  		JOIN @schemaRaw.DRUG_EXPOSURE co
  			ON co.PERSON_ID = i.PERSON_ID
  			AND i.INDEX_DATE <= co.DRUG_EXPOSURE_START_DATE
  		JOIN @schemaRaw.CONCEPT_ANCESTOR ca
  			ON ca.ANCESTOR_CONCEPT_ID = co.DRUG_CONCEPT_ID
  		JOIN @schemaRaw.CONCEPT c
  			ON c.CONCEPT_ID = ca.DESCENDANT_CONCEPT_ID
  			AND UPPER(c.DOMAIN_ID) = 'DRUG'
  			AND UPPER(c.STANDARD_CONCEPT) = 'S'
  	GROUP BY c.CONCEPT_ID, c.CONCEPT_NAME
  	HAVING COUNT_BIG(DISTINCT co.PERSON_ID) >= @filter
  ),
  CTE_RC AS (
  	SELECT c.CONCEPT_ID, c.CONCEPT_NAME,
  		COUNT_BIG(DISTINCT co.PERSON_ID) AS PERSON_COUNT_RC
  	FROM (
    		SELECT PERSON_ID, MIN(de.DRUG_EXPOSURE_START_DATE) AS INDEX_DATE
    		FROM @schemaRaw.DRUG_EXPOSURE de
    		WHERE DRUG_CONCEPT_ID IN (
    			SELECT DESCENDANT_CONCEPT_ID FROM @schemaRaw.CONCEPT_ANCESTOR WHERE ANCESTOR_CONCEPT_ID IN (@conceptsOfInterest)
    		)
    		GROUP BY PERSON_ID
  	) i
  		JOIN @schemaRaw.OBSERVATION_PERIOD op
    			ON op.PERSON_ID = i.PERSON_ID
    			AND i.INDEX_DATE BETWEEN op.OBSERVATION_PERIOD_START_DATE AND op.OBSERVATION_PERIOD_END_DATE
    			AND DATEDIFF(dd,op.OBSERVATION_PERIOD_START_DATE,i.INDEX_DATE) >= 180
  		JOIN @schemaRaw.DRUG_EXPOSURE co
  			ON co.PERSON_ID = i.PERSON_ID
  			AND i.INDEX_DATE <= co.DRUG_EXPOSURE_START_DATE
  		JOIN @schemaRaw.CONCEPT c
  			ON c.CONCEPT_ID = co.DRUG_CONCEPT_ID
  			AND UPPER(c.DOMAIN_ID) = 'DRUG'
  			AND UPPER(c.STANDARD_CONCEPT) = 'S'
  	GROUP BY c.CONCEPT_ID, c.CONCEPT_NAME
  	HAVING COUNT_BIG(DISTINCT co.PERSON_ID) >= @filter
  )
  SELECT dc.CONCEPT_ID, dc.CONCEPT_NAME, rc.PERSON_COUNT_RC, dc.PERSON_COUNT_DC
  FROM CTE_DC dc
  	LEFT OUTER JOIN CTE_RC rc
  		ON rc.CONCEPT_ID = dc.CONCEPT_ID
  ORDER BY dc.PERSON_COUNT_DC DESC, rc.PERSON_COUNT_RC DESC, dc.CONCEPT_NAME;
}