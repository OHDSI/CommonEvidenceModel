/*@vocabSchema*/
IF OBJECT_ID('@tableName', 'U') IS NOT NULL
DROP TABLE @tableName;

/*CREATE TABLE*/
CREATE TABLE @tableName (
	ID SERIAL,
	SOURCE_ID	VARCHAR(20),
	SOURCE_CODE_1	VARCHAR(MAX),
	SOURCE_CODE_TYPE_1	VARCHAR(55),
	SOURCE_CODE_NAME_1	VARCHAR(MAX),
	RELATIONSHIP_ID	VARCHAR(20),
	SOURCE_CODE_2	VARCHAR(MAX),
	SOURCE_CODE_TYPE_2	VARCHAR(55),
	SOURCE_CODE_NAME_2	VARCHAR(MAX),
	UNIQUE_IDENTIFIER	VARCHAR(MAX),
	UNIQUE_IDENTIFIER_TYPE	VARCHAR(450),
    CASE_COUNT INT,
    PARTICIPANTS INT,
	StudyId BIGINT,
	overallstatus VARCHAR(450),
	brieftitle Varchar(MAX),
	sponsor Varchar(MAX),
	summary Varchar(MAX),
	studyType VARCHAR(450),
	InterventionalModel VARCHAR(450),
	Allocation VARCHAR(450),
	StudyPhase VARCHAR(450),
	studystartdate DATE,
	studycompletiondate DATE,
	lastupdatedate DATE,
	grouptitle VARCHAR(450),
	armtitle Varchar(MAX),
	numberOfArms INT,
	enrollment INT,
	aeother INT,
	aeserious INT
);

/*SELECT INTO*/
WITH cte1 AS (SELECT '@sourceId'                                                 AS SOURCE_ID,
                     unnest(string_to_array(sae.InterventionOmopConceptId, ',')) AS SOURCE_CODE_1,
                     'OMOP CONCEPT_ID'                                           AS SOURCE_CODE_TYPE_1,
                     sae.armdescription                                          AS SOURCE_CODE_NAME_1,
                     'Has Adverse Event'                                         AS RELATIONSHIP_ID,
                     sae.eventtermptomopconceptid                                AS SOURCE_CODE_2,
                     'OMOP CONCEPT_ID'                                           AS SOURCE_CODE_TYPE_2,
                     sae.eventterm                                               AS SOURCE_CODE_NAME_2,
                     sae.clinicalTrialsid                                        AS UNIQUE_IDENTIFIER,
                     'NCT Number'                                                AS UNIQUE_IDENTIFIER_TYPE,
                     coalesce(sae.aeserious, 0) + coalesce(sae.aeother, 0)       AS CASE_COUNT,
                     sae.aenumberofparticipants                                  AS PARTICIPANTS,
                     sae.StudyId,
                     sae.overallstatus,
                     sae.brieftitle,
                     sae.sponsor,
                     sae.summary,
                     sae.studyType,
                     sae.InterventionalModel,
                     sae.Allocation,
                     sae.StudyPhase,
                     sae.studystartdate,
                     sae.studycompletiondate,
                     sae.lastupdatedate,
                     sae.grouptitle,
                     sae.armtitle,
                     sae.numberOfArms,
                     sae.enrollment,
                     sae.aeother,
                     sae.aeserious
              FROM staging_sherlock.SubAdverseEvent sae
              WHERE InterventionalModel = 'Parallel Assignment'
                AND Allocation = 'Randomized'),
     cte2 AS (SELECT cte1.SOURCE_ID,
                     cte1.SOURCE_CODE_1,
                     cte1.SOURCE_CODE_TYPE_1,
                     cte1.SOURCE_CODE_NAME_1,
                     cte1.RELATIONSHIP_ID,
                     unnest(string_to_array(cte1.SOURCE_CODE_2, ',')) AS SOURCE_CODE_2,
                     cte1.SOURCE_CODE_TYPE_2,
                     cte1.SOURCE_CODE_NAME_2,
                     cte1.UNIQUE_IDENTIFIER,
                     cte1.UNIQUE_IDENTIFIER_TYPE,
                     cte1.CASE_COUNT,
                     cte1.PARTICIPANTS,
                     cte1.StudyId,
                     cte1.overallstatus,
                     cte1.brieftitle,
                     cte1.sponsor,
                     cte1.summary,
                     cte1.studyType,
                     cte1.InterventionalModel,
                     cte1.Allocation,
                     cte1.StudyPhase,
                     cte1.studystartdate,
                     cte1.studycompletiondate,
                     cte1.lastupdatedate,
                     cte1.grouptitle,
                     cte1.armtitle,
                     cte1.numberOfArms,
                     cte1.enrollment,
                     cte1.aeother,
                     cte1.aeserious
              FROM cte1
              WHERE CASE_COUNT > 0)
INSERT
INTO @tableName (SOURCE_ID, SOURCE_CODE_1, SOURCE_CODE_TYPE_1, SOURCE_CODE_NAME_1, RELATIONSHIP_ID,
                 SOURCE_CODE_2, SOURCE_CODE_TYPE_2, SOURCE_CODE_NAME_2, UNIQUE_IDENTIFIER,
                 UNIQUE_IDENTIFIER_TYPE, CASE_COUNT, PARTICIPANTS,
                 StudyId, overallstatus, brieftitle, sponsor, summary, studyType,
                 InterventionalModel, Allocation, StudyPhase, studystartdate,
                 studycompletiondate, lastupdatedate, grouptitle, armtitle, numberOfArms,
                 enrollment, aeother, aeserious)
SELECT cte2.*
FROM cte2;


CREATE INDEX IDX_UNIQUE_@sourceId_UNIQUE_IDENTIFIER_SOURCE_CODE_1_SOURCE_CODE_2 ON @tableName (UNIQUE_IDENTIFIER, SOURCE_CODE_1, SOURCE_CODE_2);

ALTER TABLE @tableName OWNER TO RW_GRP;
