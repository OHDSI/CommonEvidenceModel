SET SEARCH_PATH TO STAGING_VOCABULARY;

-- CREATE INDEXES ON OMOP VOCABULARY TABLES --

-- drug strength

CREATE INDEX idx_stg_drug_strength_id_1
  ON drug_strength
  USING btree
  (drug_concept_id);
ALTER TABLE drug_strength CLUSTER ON idx_stg_drug_strength_id_1;

CREATE INDEX idx_stg_drug_strength_id_2
  ON drug_strength
  USING btree
  (ingredient_concept_id);

-- concept 

CREATE INDEX idx_stg_concept_class_id
  ON concept
  USING btree
  (concept_class_id COLLATE pg_catalog."default");

CREATE INDEX idx_stg_concept_code
  ON concept
  USING btree
  (concept_code COLLATE pg_catalog."default");

CREATE UNIQUE INDEX idx_stg_concept_concept_id
  ON concept
  USING btree
  (concept_id);
ALTER TABLE concept CLUSTER ON idx_stg_concept_concept_id;

CREATE INDEX idx_stg_concept_domain_id
  ON concept
  USING btree
  (domain_id COLLATE pg_catalog."default");

CREATE INDEX idx_stg_concept_vocabluary_id
  ON concept
  USING btree
  (vocabulary_id COLLATE pg_catalog."default");
  
CREATE INDEX idx_stg_concept_varchar_concept_id
  ON concept
  USING btree
  ((concept_id::character varying) COLLATE pg_catalog."default");
  
-- concept relationship
  
CREATE INDEX idx_stg_concept_relationship_id_1
  ON concept_relationship
  USING btree
  (concept_id_1);

CREATE INDEX idx_stg_concept_relationship_id_2
  ON concept_relationship
  USING btree
  (concept_id_2);

CREATE INDEX idx_stg_concept_relationship_id_3
  ON concept_relationship
  USING btree
  (relationship_id COLLATE pg_catalog."default");
  
CREATE INDEX idx_stg_concept_relationship_id_4
  ON concept_relationship
  USING btree
  (concept_id_1, concept_id_2, relationship_id COLLATE pg_catalog."default");
ALTER TABLE concept_relationship CLUSTER ON idx_stg_concept_relationship_id_4;
  
-- concept ancestor

CREATE INDEX idx_stg_concept_ancestor_id_1
  ON concept_ancestor
  USING btree
  (ancestor_concept_id);
ALTER TABLE concept_ancestor CLUSTER ON idx_stg_concept_ancestor_id_1;

CREATE INDEX idx_stg_concept_ancestor_id_2
  ON concept_ancestor
  USING btree
  (descendant_concept_id);  

-- concept synonym 
 
CREATE INDEX idx_stg_concept_synonym_id
  ON concept_synonym
  USING btree
  (concept_id);
ALTER TABLE concept_synonym CLUSTER ON idx_stg_concept_synonym_id;

-- relationship

CREATE UNIQUE INDEX idx_stg_relationship_rel_id
  ON relationship
  USING btree
  (relationship_id COLLATE pg_catalog."default");
ALTER TABLE relationship CLUSTER ON idx_stg_relationship_rel_id;

-- concept class

CREATE UNIQUE INDEX idx_stg_concept_class_class_id
  ON concept_class
  USING btree
  (concept_class_id COLLATE pg_catalog."default");
ALTER TABLE concept_class CLUSTER ON idx_stg_concept_class_class_id;

-- vocabulary

CREATE UNIQUE INDEX idx_stg_vocabulary_vocabulary_id
  ON vocabulary
  USING btree
  (vocabulary_id COLLATE pg_catalog."default");
ALTER TABLE vocabulary CLUSTER ON idx_stg_vocabulary_vocabulary_id;

-- domain

CREATE UNIQUE INDEX idx_stg_domain_domain_id
  ON domain
  USING btree
  (domain_id COLLATE pg_catalog."default");
ALTER TABLE domain CLUSTER ON idx_stg_domain_domain_id;
