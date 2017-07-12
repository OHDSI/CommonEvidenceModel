IF OBJECT_ID('@fqTableName','U') IS NOT NULL DROP TABLE @fqTableName;

CREATE TABLE @fqTableName (
  source_code             varchar(255) NOT NULL,
  source_concept_id       int NOT NULL,
  source_vocabulary_id    varchar(20) NOT NULL,
  source_code_description varchar(255) NULL,
  target_concept_id       int NOT NULL,
  target_vocabulary_id    varchar(20) NULL,
  valid_start_date        date NOT NULL,
  valid_end_date          date NOT NULL,
  invalid_reason          varchar(1) NULL
);
