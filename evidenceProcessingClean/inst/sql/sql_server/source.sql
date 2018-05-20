/*@vocabSchema*/
IF OBJECT_ID('@tableName', 'U') IS NOT NULL DROP TABLE @tableName;

SELECT *
INTO @tableName
FROM @sourceSchema.@sourceId;

ALTER TABLE @tableName OWNER TO RW_GRP;
