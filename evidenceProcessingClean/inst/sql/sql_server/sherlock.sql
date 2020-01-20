/*@vocabSchema*/
IF OBJECT_ID('@tableName', 'U') IS NOT NULL DROP TABLE @tableName;

/*CREATE TABLE*/
CREATE TABLE @tableName (
	ID SERIAL,
	SOURCE_ID	VARCHAR(20),
	SOURCE_CODE_1	VARCHAR(50),
	SOURCE_CODE_TYPE_1	VARCHAR(55),
	SOURCE_CODE_NAME_1	VARCHAR(255),
	RELATIONSHIP_ID	VARCHAR(20),
	SOURCE_CODE_2	VARCHAR(50),
	SOURCE_CODE_TYPE_2	VARCHAR(55),
	SOURCE_CODE_NAME_2	VARCHAR(255),
	UNIQUE_IDENTIFIER	VARCHAR(50),
	UNIQUE_IDENTIFIER_TYPE	VARCHAR(50),
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
	aenumberofparticipants INT,
	aeother INT,
	aeserious INT
);

/*SELECT INTO*/
INSERT INTO @tableName (SOURCE_ID, SOURCE_CODE_1, SOURCE_CODE_TYPE_1, SOURCE_CODE_NAME_1, RELATIONSHIP_ID,
	SOURCE_CODE_2, SOURCE_CODE_TYPE_2, SOURCE_CODE_NAME_2, UNIQUE_IDENTIFIER, UNIQUE_IDENTIFIER_TYPE,
	StudyId, 	overallstatus ,	brieftitle,	sponsor ,	summary,	studyType ,
	InterventionalModel ,	Allocation ,	StudyPhase,	studystartdate ,
	studycompletiondate ,	lastupdatedate,	grouptitle , 	armtitle, 	numberOfArms ,
	enrollment,	aenumberofparticipants,	aeother,	aeserious )
SELECT '@sourceId' AS SOURCE_ID,
	sae.InterventionOmopConceptId AS SOURCE_CODE_1, 'OMOP CONCEPT_ID' AS SOURCE_CODE_TYPE_1, sae.armdescription AS SOURCE_CODE_NAME_1,
	'Has Adverse Event' AS RELATIONSHIP_ID,
	sae.eventtermptomopconceptid AS SOURCE_CODE_2, 'OMOP CONCEPT_ID' AS SOURCE_CODE_TYPE_2, sae.EVENTTERM AS SOURCE_CODE_NAME_2,
	sae.clinicalTrialsid AS UNIQUE_IDENTIFIER, 'NCT Number' AS UNIQUE_IDENTIFIER_TYPE,
	sae.StudyId, sae.overallstatus, sae.brieftitle, sae.sponsor, sae.summary,
	sae.studyType, sae.InterventionalModel,sae.Allocation,sae.StudyPhase,
	sae.studystartdate,sae.studycompletiondate,sae.lastupdatedate,
	sae.grouptitle, sae.armtitle,
	sae.numberOfArms, sae.enrollment, sae.aenumberofparticipants,sae.aeother,sae.aeserious
FROM @sourceSchema.SubAdverseEvent sae
WHERE InterventionalModel = 'Parallel Assignment'
AND Allocation = 'Randomized'
AND clinicaltrialsid = 'NCT02757105';

CREATE INDEX IDX_UNIQUE_@sourceId_UNIQUE_IDENTIFIER_SOURCE_CODE_1_SOURCE_CODE_2 ON @tableName (UNIQUE_IDENTIFIER, SOURCE_CODE_1, SOURCE_CODE_2);

ALTER TABLE @tableName OWNER TO RW_GRP;
