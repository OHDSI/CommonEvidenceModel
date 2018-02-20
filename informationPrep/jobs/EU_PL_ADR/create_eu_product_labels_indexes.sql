SET SEARCH_PATH TO STAGING_EU_PL_ADR;

-- CREATE INDEXES ON STAGING EU_PL_ADR TABLES --

CREATE INDEX idx_stg_eu_product_labels_product_1
  ON eu_product_labels
  USING btree
  (product);
ALTER TABLE eu_product_labels CLUSTER ON idx_stg_eu_product_labels_product_1;