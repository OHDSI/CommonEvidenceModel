#!/bin/bash

UMLS_FILE=MRCONSO.RRF

echo "Reading config file"
. ../secret.config || exit 1

echo "Fixing MRCONSO file"
# remove trailing '|' char on every line and fix two lines with invalid '\|' string
perl -pe 's/\|\n/\n/;s/\\\|/\|/;' ${UMLS_FILE} >${UMLS_FILE}.no_pipe_eol || exit 1

export PGPASSWORD=${CEM_POSTGRES_PASSWORD}

echo "Creating staging_vocabulary schema"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -f ./sql/create_staging_umls.sql ${CEM_POSTGRES_DATABASE} || exit 1

echo "Populating staging_umls"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -c "\COPY staging_umls.mrconso FROM '${UMLS_FILE}.no_pipe_eol' WITH DELIMITER '|' CSV QUOTE E'\b'" ${CEM_POSTGRES_DATABASE}

echo "Creating indexes"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -f ./sql/create_umls_mrconso_indexes.sql ${CEM_POSTGRES_DATABASE} || exit 1

echo "All done!"
