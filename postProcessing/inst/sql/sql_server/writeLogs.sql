DELETE FROM @source WHERE SOURCE_ID = 'COMMONEVIDENCEMODEL';

INSERT INTO @source  (SOURCE_ID, DESCRIPTION, PROVENANCE, CONTRIBUTOR_ORGANIZATION, CONTACT_NAME, CREATION_DATE, COVERAGE_START_DATE, COVERAGE_END_DATE, VERSION_IDENTIFIER)
VALUES ('@sourceId',
       'CommonEvidenceModel (CEM) is the infrastructure to pull together public sources of information on drugs and conditions and standardize their format and vocabularies.',
       '@sourceId',
       'OHDSI',
       'Erica Voss',
       '@releaseDate',
       (SELECT MIN(COVERAGE_START_DATE) FROM STAGING_AUDIT.SOURCE),
       (SELECT MAX(COVERAGE_END_DATE) FROM STAGING_AUDIT.SOURCE),
       '@releaseVersion');

INSERT INTO @executionLog (SOURCE_ID, EXECUTION_DATE, STATUS, CEM_VERSION)
VALUES ('@sourceId',
	'@releaseDate',
	'Final step of CEM processing',
	'@releaseVersion');
