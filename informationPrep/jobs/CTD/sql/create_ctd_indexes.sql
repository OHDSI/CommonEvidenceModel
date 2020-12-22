-- CREATE INDEXES ON  STAGING_CTD TABLES --
SET SEARCH_PATH = STAGING_CTD;
CREATE INDEX idx_staging_ctd_chemical_disease_chem_id
  ON ctd_chemical_disease
  USING btree
  (ChemicalID);
ALTER TABLE ctd_chemical_disease CLUSTER ON idx_staging_ctd_chemical_disease_chem_id;

CREATE INDEX idx_staging_ctd_chemical_disease_disease_id
  ON ctd_chemical_disease
  USING btree
  (DiseaseID);
ALTER TABLE ctd_chemical_disease CLUSTER ON idx_staging_ctd_chemical_disease_disease_id;
