#!/bin/bash

SOURCE_FILE="SOURCE.csv"

echo "Reading config file"
. ../secret.config || exit 1

export PGPASSWORD=${CEM_POSTGRES_PASSWORD}

echo "Creating staging_audit schema"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -f ./sql/create_audit_tables.sql ${CEM_POSTGRES_DATABASE} || exit 1

echo "Loading source data"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -c "\COPY STAGING_AUDIT.SOURCE FROM '${SOURCE_FILE}' WITH DELIMITER E',' CSV HEADER QUOTE E'\"' NULL ''" "${CEM_POSTGRES_DATABASE}"

echo "Finished!"
