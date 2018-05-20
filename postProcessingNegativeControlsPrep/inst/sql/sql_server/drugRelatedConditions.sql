/*@vocabulary*/

IF OBJECT_ID('@storeData', 'U') IS NOT NULL DROP TABLE @storeData;

SELECT c1.CONCEPT_ID,
  CASE WHEN c2.SORT_ORDER IS NULL THEN 0 ELSE c2.SORT_ORDER END SORT_ORDER
INTO @storeData
FROM @vocabulary.concept c1
  JOIN @conceptUniverseData c2
    ON c2.CONDITION_CONCEPT_ID = c1.CONCEPT_ID
WHERE UPPER(c1.CONCEPT_NAME) LIKE '%DRUG%'
OR UPPER(c1.CONCEPT_NAME) LIKE '%ALCOHOL-INDUCED%'
OR UPPER(c1.CONCEPT_NAME) LIKE '%MEDICATION%'
OR c1.CONCEPT_ID IN (
	4126119, /*Toxic nephropathy*/
	4279309, /*Substance Abuse*/
	4172024, /*Propensity to adverse reactions*/
	4002014, /*Post-treatment pain*/
	442562, /*poisoning*/
	36712767,	/*Allergy to antibiotic*/
  4241527,	/*Allergy to sulfonamides*/
  437456,	/*Poisoning by anticonvulsant*/
  433083,	/*Poisoning by opiate AND/OR related narcotic*/
  438661,	/*Complication of infusion*/
  4168644,	/*Propensity to adverse reactions to substance*/
  434900 /*Drug-induced psychosis*/
)
ORDER BY SORT_ORDER;

CREATE INDEX IDX_LU_DRUG_RELATED_CONCEPT_ID ON @storeData (CONCEPT_ID);

ALTER TABLE @storeData OWNER TO RW_GRP;
