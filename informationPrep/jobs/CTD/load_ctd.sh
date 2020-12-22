#!/bin/bash

CHEMICALS_URL="http://ctdbase.org/reports/CTD_chemicals_diseases.tsv.gz"
CHEMICALS_FILE="CTD_chemicals_diseases.tsv"

echo "Reading config file"
. ../secret.config || exit 1

echo "Downloading ${CHEMICALS_FILE}.gz from ${CHEMICALS_URL}"
wget -O ${CHEMICALS_FILE}.gz ${CHEMICALS_URL} || exit 1

echo "Unzipping ${CHEMICALS_FILE}.gz"
gunzip ${CHEMICALS_FILE}.gz || exit 1

export PGPASSWORD=${CEM_POSTGRES_PASSWORD}

echo "Creating STAGING_CTD schema"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -f ./sql/create_ctd_tables.sql ${CEM_POSTGRES_DATABASE}

echo "Populating STAGING_CTD with ${CHEMICALS_FILE} ..."
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -c "\COPY STAGING_CTD.CTD_CHEMICAL_DISEASE FROM PROGRAM 'tail -n +30  ${CHEMICALS_FILE}' WITH DELIMITER E'	' CSV HEADER QUOTE E'\"' NULL ''" ${CEM_POSTGRES_DATABASE}

echo "Creating indexes"
psql -h "${CEM_POSTGRES_HOST}" -U "${CEM_POSTGRES_USER}" -f ./sql/create_ctd_indexes.sql -d "${CEM_POSTGRES_DATABASE}" || exit 1

echo "Deleting source file"
rm ${CHEMICALS_FILE}

echo "Finished!"
