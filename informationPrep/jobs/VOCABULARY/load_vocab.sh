#!/bin/bash

OMOP_FILES_FOLDER="omop_files"

echo "Reading config file"
. ../secret.config

echo "Unzipping vocabulary"
mkdir ${OMOP_FILES_FOLDER}
unzip ./*.zip -d ${OMOP_FILES_FOLDER} || exit 1

export PGPASSWORD=${CEM_POSTGRES_PASSWORD}

echo "Creating staging_vocabulary schema"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -f ./sql/create_vocabulary_schema.sql ${CEM_POSTGRES_DATABASE} || exit 1

echo "Populating domain"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -c "\COPY staging_vocabulary.domain FROM './${OMOP_FILES_FOLDER}/DOMAIN.csv' WITH DELIMITER E'\t' CSV HEADER QUOTE E'\b'" ${CEM_POSTGRES_DATABASE} || exit 1

echo "Populating vocabulary"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -c "\COPY staging_vocabulary.vocabulary FROM './${OMOP_FILES_FOLDER}/VOCABULARY.csv' WITH DELIMITER E'\t' CSV HEADER QUOTE E'\b'" ${CEM_POSTGRES_DATABASE} || exit 1

echo "Populating concept_class"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -c "\COPY staging_vocabulary.concept_class FROM './${OMOP_FILES_FOLDER}/CONCEPT_CLASS.csv' WITH DELIMITER E'\t' CSV HEADER QUOTE E'\b'" ${CEM_POSTGRES_DATABASE} || exit 1

echo "Populating relationship"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -c "\COPY staging_vocabulary.relationship FROM './${OMOP_FILES_FOLDER}/RELATIONSHIP.csv' WITH DELIMITER E'\t' CSV HEADER QUOTE E'\b'" ${CEM_POSTGRES_DATABASE} || exit 1

echo "Populating drug_strength"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -c "\COPY staging_vocabulary.drug_strength FROM './${OMOP_FILES_FOLDER}/DRUG_STRENGTH.csv' WITH DELIMITER E'\t' CSV HEADER QUOTE E'\b'" ${CEM_POSTGRES_DATABASE} || exit 1

echo "Populating concept_synonym"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -c "\COPY staging_vocabulary.concept_synonym FROM './${OMOP_FILES_FOLDER}/CONCEPT_SYNONYM.csv' WITH DELIMITER E'\t' CSV HEADER QUOTE E'\b'" ${CEM_POSTGRES_DATABASE} || exit 1

echo "Populating concept_relationship"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -c "\COPY staging_vocabulary.concept_relationship FROM './${OMOP_FILES_FOLDER}/CONCEPT_RELATIONSHIP.csv' WITH DELIMITER E'\t' CSV HEADER QUOTE E'\b'" ${CEM_POSTGRES_DATABASE} || exit 1

echo "Populating concept_ancestor"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -c "\COPY staging_vocabulary.concept_ancestor FROM './${OMOP_FILES_FOLDER}/CONCEPT_ANCESTOR.csv' WITH DELIMITER E'\t' CSV HEADER QUOTE E'\b'" ${CEM_POSTGRES_DATABASE} || exit 1

echo "Populating concept"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -c "\COPY staging_vocabulary.concept FROM './${OMOP_FILES_FOLDER}/CONCEPT.csv' WITH DELIMITER E'\t' CSV HEADER" ${CEM_POSTGRES_DATABASE} || exit 1

echo "Creating indexes"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -f ./sql/create_vocabulary_indexes.sql ${CEM_POSTGRES_DATABASE} || exit 1

echo "Getting record count"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -f ./sql/show_vocabulary_record_counts.sql ${CEM_POSTGRES_DATABASE} || exit 1

echo "Removing unzipped omop files"
rm -r ${OMOP_FILES_FOLDER}

echo "All done!"
