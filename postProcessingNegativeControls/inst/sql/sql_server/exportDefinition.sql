SELECT '01) Outcome of Interest' AS CONCEPT_TYP,
  0 AS CONCEPT_ID,
  '@outComeOfInterest' AS CONCEPT_NAME
UNION ALL
SELECT '02) Concepts of Interest' AS CONCEPT_TYPE,
  CONCEPT_ID,
  CONCEPT_NAME
FROM @vocabulary.CONCEPT
WHERE CONCEPT_ID IN (
  @conceptsOfInterest
)
UNION ALL
SELECT '03) User Defined Concepts to Exclude' AS CONCEPT_TYPE,
  CONCEPT_ID,
  CONCEPT_NAME
FROM @vocabulary.CONCEPT
WHERE CONCEPT_ID IN (
  @conceptsToExclude
)
UNION ALL
SELECT '04) User Defined Concepts to Include' AS CONCEPT_TYPE,
  CONCEPT_ID,
  CONCEPT_NAME
FROM @vocabulary.CONCEPT
WHERE CONCEPT_ID IN (
  @conceptsToInclude
)
ORDER BY 1, CONCEPT_NAME
