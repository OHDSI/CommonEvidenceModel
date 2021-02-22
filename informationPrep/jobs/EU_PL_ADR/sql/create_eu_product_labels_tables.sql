DROP SCHEMA IF EXISTS staging_eu_pl_adr CASCADE;
CREATE SCHEMA staging_eu_pl_adr;

set search_path = staging_eu_pl_adr;

CREATE TABLE staging_eu_pl_adr.eu_product_labels_original
(
  product character varying(512),
  substance character varying(512),
  spc_date character varying(512), 
  adr character varying(512),
  soc character varying(512),
  hlgt character varying(512),
  hlt character varying(512),
  llt character varying(512),
  meddra_pt character varying(512),
  pt_code character varying(512),
  soc_code character varying(512),
  age_group character varying(512),
  gender character varying(512),
  causality character varying(512),
  frequency character varying(512),
  class_warning character varying(512),
  clinical_trials character varying(512),
  post_marketing character varying(512),
  comment character varying(2000)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE staging_eu_pl_adr.eu_product_labels_original
    OWNER TO rw_grp;


CREATE TABLE staging_eu_pl_adr.eu_product_labels
(
  product character varying(512),
  substance character varying(512),
  spc_date date, 
  adr character varying(512),
  soc character varying(512),
  hlgt character varying(512),
  hlt character varying(512),
  llt character varying(512),
  meddra_pt character varying(512),
  pt_code character varying(512),
  soc_code character varying(512),
  age_group integer,
  gender integer,
  causality integer,
  frequency integer,
  class_warning integer,
  clinical_trials integer,
  post_marketing integer,
  comment character varying(2000)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE staging_eu_pl_adr.eu_product_labels_original
    OWNER TO rw_grp;
