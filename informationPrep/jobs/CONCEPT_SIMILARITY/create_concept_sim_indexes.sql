-- CREATE INDEXES ON  STAGING_CONCEPT_SIM TABLES --
SET SEARCH_PATH = STAGING_CONCEPT_SIM;
CREATE INDEX idx_staging_concept_sim_concept_1_cui
  ON concept_similarity
  USING btree
  (concept_1_cui);
ALTER TABLE concept_similarity CLUSTER ON idx_staging_concept_sim_concept_1_cui;

CREATE INDEX idx_staging_concept_sim_concept_2_cui
  ON concept_similarity
  USING btree
  (concept_2_cui);
ALTER TABLE concept_similarity CLUSTER ON idx_staging_concept_sim_concept_2_cui;
