IF OBJECT_ID('@tableName', 'U') IS NOT NULL DROP TABLE @tableName;

WITH CTE_VOCAB AS (
	SELECT *
	FROM CEM_SOURCE_TO_CONCEPT_MAP
	WHERE SOURCE_VOCABULARY_ID = 'SPL_TO_STANDARD_DRUG'
),
CTE_VOCAB_2 AS (
	SELECT *
	FROM CEM_SOURCE_TO_CONCEPT_MAP
	WHERE SOURCE_VOCABULARY_ID = 'MEDDRA_TO_STANDARD'
)
SELECT ID,
  SOURCE_ID,
  SOURCE_CODE_1,
  SOURCE_CODE_TYPE_1,
  SOURCE_CODE_NAME_1,
  CASE WHEN v1.TARGET_CONCEPT_ID IS NULL THEN 0 ELSE v1.TARGET_CONCEPT_ID  END CONCEPT_ID_1,
  RELATIONSHIP_ID,
  SOURCE_CODE_2,
  SOURCE_CODE_TYPE_2,
  SOURCE_CODE_NAME_2,
  CASE WHEN v2.TARGET_CONCEPT_ID IS NULL THEN 0 ELSE v2.TARGET_CONCEPT_ID  END CONCEPT_ID_2,
  UNIQUE_IDENTIFIER,
  UNIQUE_IDENTIFIER_TYPE,
  SPL_ID,
  TRADE_NAME,
  SPL_DATE,
  SPL_SECTION,
  CONDITION_PT
INTO @tableName
FROM @sourceTableName s
	LEFT OUTER JOIN CTE_VOCAB v1
		ON v1.SOURCE_CODE = s.SOURCE_CODE_1
	LEFT OUTER JOIN CTE_VOCAB_2 v2
		ON v2.SOURCE_CODE = s.SOURCE_CODE_2

CREATE INDEX IDX_@tableName_CONCEPT_ID_1_CONCEPT_ID_2 ON @tableName (CONCEPT_ID_1, CONCEPT_ID_2)
