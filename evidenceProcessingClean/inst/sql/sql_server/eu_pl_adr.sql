/*@vocabSchema*/
IF OBJECT_ID('@tableName','U') IS NOT NULL
DROP TABLE @tableName;

CREATE TABLE @tableName (
  ID SERIAL,
	SOURCE_ID	VARCHAR(20),
	SOURCE_CODE_1	VARCHAR(500),
	SOURCE_CODE_TYPE_1	VARCHAR(55),
	SOURCE_CODE_NAME_1	VARCHAR(2000),
	RELATIONSHIP_ID	VARCHAR(20),
	SOURCE_CODE_2	VARCHAR(500),
	SOURCE_CODE_TYPE_2	VARCHAR(55),
	SOURCE_CODE_NAME_2	VARCHAR(500),
	UNIQUE_IDENTIFIER	VARCHAR(2000),
	UNIQUE_IDENTIFIER_TYPE	VARCHAR(500),
  SOC VARCHAR(500),
  HLGT VARCHAR(500),
  HTL VARCHAR(500),
  LLT VARCHAR(500),
  AGE_GROUP INT,
  GENDER INT,
  CAUSALITY INT,
  FREQUENCY INT,
  CLASS_WARNING INT,
  CLINICAL_TRIALS INT,
  POST_MARKETING INT,
  COMMENT  VARCHAR(2000)
);

INSERT INTO @tableName (SOURCE_ID, SOURCE_CODE_1,
	SOURCE_CODE_TYPE_1, SOURCE_CODE_NAME_1, RELATIONSHIP_ID,
	SOURCE_CODE_2, SOURCE_CODE_TYPE_2,	SOURCE_CODE_NAME_2,
	UNIQUE_IDENTIFIER, UNIQUE_IDENTIFIER_TYPE, SOC, HLGT, HTL, LLT, AGE_GROUP,
	GENDER, CAUSALITY, FREQUENCY, CLASS_WARNING, CLINICAL_TRIALS, POST_MARKETING,
	COMMENT)
SELECT
	'@sourceId' AS SOURCE_ID,
	SUBSTANCE AS SOURCE_CODE_1,
	'Ingredient by Free Text' AS SOURCE_CODE_TYPE_1,
	product+'-'+substance AS SOURCE_CODE_NAME_1,
	'Has Adverse Event' AS RELATIONSHIP_ID,
	PT_CODE AS SOURCE_CODE_2,
	'MedDRA PT' AS SOURCE_CODE_TYPE_2,
	MEDDRA_PT AS SOURCE_CODE_NAME_2,
	product+'-'+substance+'-'+MEDDRA_PT AS UNIQUE_IDENTIFIER,
	'PRODUCT-SUBSTANCE-MEDDRA_PT' AS UNIQUE_IDENTIFIER_TYPE,
	SOC,
	HLGT,
	HLT,
	LLT,
	AGE_GROUP,
	GENDER,
	CAUSALITY,
	FREQUENCY,
	CLASS_WARNING,
	CLINICAL_TRIALS,
	POST_MARKETING,
	COMMENT
FROM @sourceSchema.dbo.EU_PRODUCT_LABELS pl;

CREATE INDEX IDX_UNIQUE_@sourceId_UNIQUE_IDENTIFIER_SOURCE_CODE_1_SOURCE_CODE_2 ON @tableName (UNIQUE_IDENTIFIER, SOURCE_CODE_1, SOURCE_CODE_2);
