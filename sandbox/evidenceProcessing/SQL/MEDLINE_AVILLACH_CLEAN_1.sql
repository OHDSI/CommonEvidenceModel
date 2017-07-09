IF OBJECT_ID('@tableName','U') IS NOT NULL
DROP TABLE @tableName;

CREATE TABLE @tableName (
  ID INT IDENTITY(1,1) PRIMARY KEY,
	SOURCE_ID	VARCHAR(30),
	SOURCE_CODE_1	VARCHAR(50),
	SOURCE_CODE_TYPE_1	VARCHAR(55),
	SOURCE_CODE_NAME_1	VARCHAR(255),
	RELATIONSHIP_ID	VARCHAR(20),
	SOURCE_CODE_2	VARCHAR(50),
	SOURCE_CODE_TYPE_2	VARCHAR(55),
	SOURCE_CODE_NAME_2	VARCHAR(255),
	UNIQUE_IDENTIFIER	VARCHAR(50),
	UNIQUE_IDENTIFIER_TYPE	VARCHAR(50),
  ARTICLE_TITLE VARCHAR(MAX),
  ABSTRACT VARCHAR(MAX),
  ABSTRACT_ORDER INT,
  JOURNAL VARCHAR(255),
  ISSN VARCHAR(255),
  PUBLICATION_YEAR INT,
  PUBLICATION_TYPE VARCHAR(255)
);