SELECT '01) Concepts of Interest' AS CONCEPT_TYPE,
  CONCEPT_ID,
  CONCEPT_NAME
FROM @vocabulary.CONCEPT
WHERE CONCEPT_ID IN (
  @conceptsOfInterest
)
UNION ALL
SELECT '02) User Defined Concepts to Exclude' AS CONCEPT_TYPE,
  CONCEPT_ID,
  CONCEPT_NAME
FROM @vocabulary.CONCEPT
WHERE CONCEPT_ID IN (
  @conceptsToExclude
)
UNION ALL
SELECT '03) User Defined Concepts to Include' AS CONCEPT_TYPE,
  CONCEPT_ID,
  CONCEPT_NAME
FROM @vocabulary.CONCEPT
WHERE CONCEPT_ID IN (
  @conceptsToInclude
)
ORDER BY 1, CONCEPT_NAME
