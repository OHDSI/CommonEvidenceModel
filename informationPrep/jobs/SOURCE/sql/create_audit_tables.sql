DROP SCHEMA IF EXISTS staging_audit CASCADE;
CREATE SCHEMA staging_audit;

CREATE TABLE staging_audit.source
(
    source_id                VARCHAR,
    description              TEXT,
    provenance               VARCHAR,
    contributor_organization VARCHAR,
    contact_name             VARCHAR,
    creation_date            DATE,
    coverage_start_date      DATE,
    coverage_end_date        DATE,
    version_identifier       VARCHAR
);
