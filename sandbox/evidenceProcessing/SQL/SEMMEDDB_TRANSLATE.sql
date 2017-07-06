IF OBJECT_ID('@tableName', 'U') IS NOT NULL DROP TABLE @tableName;

WITH CTE_VOCAB_1 AS (
	SELECT *
	FROM CEM_SOURCE_TO_CONCEPT_MAP
	WHERE SOURCE_VOCABULARY_ID = 'CUI_TO_STANDARD'
)
SELECT ID,
      SOURCE_ID,
      SOURCE_CODE_1,
      SOURCE_CODE_TYPE_1,
      SOURCE_CODE_NAME_1,
      CASE WHEN v1.TARGET_CONCEPT_ID IS NULL THEN 0 ELSE v1.TARGET_CONCEPT_ID END AS CONCEPT_ID_1,
      RELATIONSHIP_ID,
      SOURCE_CODE_2,
      SOURCE_CODE_TYPE_2,
      SOURCE_CODE_NAME_2,
      CASE WHEN v2.TARGET_CONCEPT_ID IS NULL THEN 0 ELSE v2.TARGET_CONCEPT_ID END AS CONCEPT_ID_2,
      UNIQUE_IDENTIFIER,
      UNIQUE_IDENTIFIER_TYPE,
      PREDICATION_ID,
      PREDICATE,
      SUBJECT_SEMTYPE,
      SUBJECT_NOVELTY,
      OBJECT_NOVELTY,
      SENTENCE_ID,
      TYPE,
      NUMBER,
      SENTENCE,
      ISSN,
      DP,
      EDAT,
      PYEAR
INTO @tableName
FROM @sourceTableName s
	LEFT OUTER JOIN CTE_VOCAB_1 v1
		ON s.SOURCE_CODE_1 = v1.SOURCE_CODE
	LEFT OUTER JOIN CTE_VOCAB_1 v2
		ON s.SOURCE_CODE_1 = v2.SOURCE_CODE

CREATE INDEX IDX_@tableName_CONCEPT_ID_1_CONCEPT_ID_2 ON @tableName (CONCEPT_ID_1, CONCEPT_ID_2)
