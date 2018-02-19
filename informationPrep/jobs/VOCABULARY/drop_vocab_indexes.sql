SET SEARCH_PATH TO STAGING_VOCABULARY;

-- DROP INDEXES ON OMOP STAGING_VOCABULARY TABLES --

-- drug strength

DROP INDEX IF EXISTS idx_stg_drug_strength_id_1;
DROP INDEX IF EXISTS idx_stg_drug_strength_id_2;

-- concept

DROP INDEX IF EXISTS idx_stg_concept_class_id;
DROP INDEX IF EXISTS idx_stg_concept_code;
DROP INDEX IF EXISTS idx_stg_concept_concept_id;
DROP INDEX IF EXISTS idx_stg_concept_domain_id;
DROP INDEX IF EXISTS idx_stg_concept_vocabluary_id;
DROP INDEX IF EXISTS idx_stg_concept_varchar_concept_id;

-- concept relationship

DROP INDEX IF EXISTS idx_stg_concept_relationship_id_1;
DROP INDEX IF EXISTS idx_stg_concept_relationship_id_2;
DROP INDEX IF EXISTS idx_stg_concept_relationship_id_3;
DROP INDEX IF EXISTS idx_stg_concept_relationship_id_4;

-- concept ancestor

DROP INDEX IF EXISTS idx_stg_concept_ancestor_id_1;
DROP INDEX IF EXISTS idx_stg_concept_ancestor_id_2;

-- concept synonym

DROP INDEX IF EXISTS idx_stg_concept_synonym_id;

-- vocabulary

DROP INDEX IF EXISTS idx_stg_vocabulary_vocabulary_id;

-- relationship

DROP INDEX IF EXISTS idx_stg_relationship_rel_id;

-- concept class

DROP INDEX IF EXISTS idx_stg_concept_class_class_id;

-- domain

DROP INDEX IF EXISTS idx_stg_domain_domain_id;


