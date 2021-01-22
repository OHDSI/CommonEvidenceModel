GRANT USAGE ON SCHEMA staging_medline TO :CEM_POSTGRES_USER;
ALTER DEFAULT PRIVILEGES IN SCHEMA staging_medline GRANT SELECT ON TABLES TO :CEM_POSTGRES_USER;

GRANT SELECT ON medcit_art_authorlist_author_affiliationinfo_identifier TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_art_authorlist_author_affiliationinfo TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_art_authorlist_author_identifier TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_art_authorlist_author TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_art_dblist_db_accessionnumberlist_accessionnumber TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_art_dblist_db TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_art_elocationid TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_art_grantlist_grant TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_art_language TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_art_publicationtypelist_publicationtype TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_chemicallist_chemical TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_citationsubset TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_commentscorrectionslist_commentscorrections TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_generalnote TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_genesymbollist_genesymbol TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_investigatorlist_investigator_affiliationinfo TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_investigatorlist_investigator TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_keywordlist_keyword TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_keywordlist TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_meshheadinglist_meshheading_qualifiername TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_meshheadinglist_meshheading TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_otherabstract_abstracttext TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_otherabstract TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_otherid TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_personalnamesubjectlist_personalnamesubject TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_spaceflightmission TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit_supplmeshlist_supplmeshname TO :CEM_POSTGRES_USER;
GRANT SELECT ON medcit TO :CEM_POSTGRES_USER;
GRANT SELECT ON mesh_ancestor TO :CEM_POSTGRES_USER;
GRANT SELECT ON mesh_relationship TO :CEM_POSTGRES_USER;
GRANT SELECT ON mesh_term TO :CEM_POSTGRES_USER;
GRANT SELECT ON pmid_to_date TO :CEM_POSTGRES_USER;