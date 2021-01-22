IF OBJECT_ID('@targetTable', 'U') IS NOT NULL DROP TABLE @targetTable;

WITH CTE_VOCAB_1 AS (
	SELECT *
	FROM @stcmTable
	WHERE UPPER(SOURCE_VOCABULARY_ID) = 'SHERLOCK_TO_STANDARD'

)
SELECT DISTINCT
      s.ID,
      s.SOURCE_ID,
      s.SOURCE_CODE_1,
      s.SOURCE_CODE_TYPE_1,
      s.SOURCE_CODE_NAME_1,
      CASE
          WHEN s.SOURCE_CODE_1 = 'Undef' OR NULL THEN 0
          ELSE
              CASE
                  WHEN s.SOURCE_CODE_1 LIKE '%,%' THEN
                      CASE
                          WHEN v1.TARGET_CONCEPT_ID IS NULL THEN 0
                          ELSE v1.TARGET_CONCEPT_ID END
                  ELSE CAST(s.SOURCE_CODE_1 AS INT) END
          END AS CONCEPT_ID_1,
      s.RELATIONSHIP_ID,
      s.SOURCE_CODE_2,
      s.SOURCE_CODE_TYPE_2,
      s.SOURCE_CODE_NAME_2,
      CASE
          WHEN s.SOURCE_CODE_2 = 'Undef' OR NULL THEN 0
          ELSE
              CASE
                  WHEN s.SOURCE_CODE_2 LIKE '%,%' THEN
                      CASE
                          WHEN v2.TARGET_CONCEPT_ID IS NULL THEN 0
                          ELSE v2.TARGET_CONCEPT_ID END
                  ELSE CAST(s.SOURCE_CODE_2 AS INT) END
          END AS CONCEPT_ID_2,
      s.UNIQUE_IDENTIFIER,
      s.UNIQUE_IDENTIFIER_TYPE
INTO @targetTable
FROM @sourceTable s
	LEFT OUTER JOIN CTE_VOCAB_1 v1
		ON v1.SOURCE_CODE = s.SOURCE_CODE_1
	LEFT OUTER JOIN CTE_VOCAB_1 v2
		ON v2.SOURCE_CODE = s.SOURCE_CODE_2;

CREATE INDEX IDX_@id_CONCEPT_ID_1_CONCEPT_ID_2 ON @targetTable (CONCEPT_ID_1, CONCEPT_ID_2);

ALTER TABLE @targetTable OWNER TO RW_GRP;
