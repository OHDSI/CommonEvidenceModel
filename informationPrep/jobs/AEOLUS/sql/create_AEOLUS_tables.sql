DROP SCHEMA IF EXISTS staging_aeolus CASCADE;
CREATE SCHEMA staging_aeolus;

SET search_path = staging_aeolus;

CREATE TABLE IF NOT EXISTS standard_drug_outcome_statistics
(
    drug_concept_id                       INTEGER,
    outcome_concept_id                    INTEGER,
    snomed_outcome_concept_id             INTEGER,
    case_count                            BIGINT,
    prr                                   NUMERIC,
    prr_95_percent_upper_confidence_limit NUMERIC,
    prr_95_percent_lower_confidence_limit NUMERIC,
    ror                                   NUMERIC,
    ror_95_percent_upper_confidence_limit NUMERIC,
    ror_95_percent_lower_confidence_limit NUMERIC
);

CREATE TABLE IF NOT EXISTS standard_drug_outcome_contingency_table
(
    drug_concept_id    INTEGER,
    outcome_concept_id INTEGER,
    count_a            BIGINT,
    count_b            NUMERIC,
    count_c            NUMERIC,
    count_d            NUMERIC
);
