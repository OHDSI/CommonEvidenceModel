DROP TABLE IF EXISTS STAGING_CONCEPT_SIM.concept_similarity CASCADE;
CREATE TABLE STAGING_CONCEPT_SIM.concept_similarity
(
  sim_score numeric,
  concept_1_cui  character varying(25),
  concept_1_str  character varying(255),
  concept_2_cui  character varying(25),
  concept_2_str  character varying(255)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE STAGING_CONCEPT_SIM.concept_similarity
  OWNER TO rw_grp;
