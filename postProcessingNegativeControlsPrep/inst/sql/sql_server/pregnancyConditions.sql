IF OBJECT_ID('@storeData', 'U') IS NOT NULL DROP TABLE @storeData;

SELECT c.CONCEPT_ID, c.CONCEPT_NAME
INTO @storeData
FROM @vocabulary.CONCEPT_ANCESTOR ca
  JOIN @vocabulary.CONCEPT c
    ON c.CONCEPT_ID = ca.DESCENDANT_CONCEPT_ID
    AND c.CONCEPT_ID IN (
      SELECT CONCEPT_ID FROM @conceptUniverseData
    )
WHERE ca.ANCESTOR_CONCEPT_ID IN (
  440795,441964,4060429,437986,4204553,4212326,4088927,
  /*Rachel's Pregnancy Add*/
  4061157,4216341,435875,4152442

)
UNION
SELECT c.CONCEPT_ID, c.CONCEPT_NAME
FROM @vocabulary.CONCEPT c
WHERE c.CONCEPT_ID IN (
  438480,	/*Abnormal glucose tolerance in mother complicating pregnancy, childbirth AND/OR puerperium*/
  4062790,	/*Disease of the digestive system complicating pregnancy, childbirth and/or the puerperium*/
  314099	/*Abnormal fetal heart rate*/
);

ALTER TABLE @storeData OWNER TO RW_GRP;
