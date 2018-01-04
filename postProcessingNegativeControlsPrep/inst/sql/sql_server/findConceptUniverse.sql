/*in the event that a user does not have patient level information we will use
a static patient count provided by a large US claims database
this table will be a mix of drugs (ingredients) and conditions
*/
SELECT CONDITION_CONCEPT_ID AS CONCEPT_ID,
  COUNT_BIG(DISTINCT PERSON_ID) AS PERSON_COUNT_RC,
  COUNT_BIG(DISTINCT PERSON_ID) AS PERSON_COUNT_DC  /*Duplicating for right now because cannot get DC to come back in a timely manner*/
FROM @schemaRaw.CONDITION_OCCURRENCE
GROUP BY CONDITION_CONCEPT_ID
HAVING COUNT_BIG(DISTINCT PERSON_ID) >= @filter

UNION ALL
/*Since we are using ingredients the RC/DC split doesn't make sense here,
both will be set to the same number*/
SELECT DRUG_CONCEPT_ID AS CONCEPT_ID,
	COUNT_BIG(DISTINCT PERSON_ID) AS PERSON_COUNT_RC,
	COUNT_BIG(DISTINCT PERSON_ID) AS PERSON_COUNT_DC
FROM @schemaRaw.DRUG_ERA
GROUP BY DRUG_CONCEPT_ID
HAVING COUNT_BIG(DISTINCT PERSON_ID) >= @filter
