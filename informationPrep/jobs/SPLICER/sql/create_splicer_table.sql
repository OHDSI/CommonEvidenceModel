DROP SCHEMA IF EXISTS staging_splicer CASCADE;
CREATE SCHEMA staging_splicer;

CREATE TABLE staging_splicer.splicer
(
    drug_concept_id        INTEGER,
    spl_id                 TEXT,
    set_id                 TEXT,
    trade_name             TEXT,
    spl_date               TEXT,
    spl_section            TEXT,
    condition_concept_id   INTEGER,
    condition_pt           TEXT,
    condition_llt          TEXT,
    condition_source_value TEXT,
    "parseMethod"          TEXT,
    "sentenceNum"          INTEGER,
    labdirection           TEXT,
    drugfreq               TEXT,
    "exclude"              TEXT
);

ALTER TABLE staging_splicer.splicer
    OWNER TO RW_GRP;

