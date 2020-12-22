DROP SCHEMA IF EXISTS STAGING_CTD CASCADE;
CREATE SCHEMA STAGING_CTD;

CREATE TABLE STAGING_CTD.ctd_chemical_disease
(
    ChemicalName        character varying(512),
    ChemicalID          character varying(512),
    CasRN               character varying(255),
    DiseaseName         character varying(512),
    DiseaseID           character varying(255),
    DirectEvidence      character varying(512),
    InferenceGeneSymbol character varying(255),
    InferenceScore      numeric,
    OmimIDs             text,
    PubMedIDs           text
)
    WITH (
        OIDS= FALSE
    );
ALTER TABLE STAGING_CTD.ctd_chemical_disease
    OWNER TO postgres;
