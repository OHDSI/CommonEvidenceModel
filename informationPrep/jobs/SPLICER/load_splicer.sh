#!/bin/bash

echo "Reading config file"
. ../secret.config || exit 1

export PGPASSWORD=${CEM_POSTGRES_PASSWORD}

echo "Creating staging_splicer schema"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -f ./sql/create_splicer_table.sql ${CEM_POSTGRES_DATABASE} || exit 1

echo "Loading splicer from tsv"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -c "\COPY STAGING_SPLICER.SPLICER FROM 'splicer.tsv' WITH DELIMITER E'/t' CSV HEADER QUOTE E'\"' NULL ''" ${CEM_POSTGRES_DATABASE}

echo "Finished!"
