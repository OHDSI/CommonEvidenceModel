#!/bin/bash

DOWNLOAD_URL="http://www.imi-protect.eu/documents/ADRdatabase_DLP30Jun2017.xls"
ADR_FILE="ADRdatabase"

echo "Reading config file"
. ../secret.config || exit 1

echo "Downloading file"
wget -O ${ADR_FILE}.xls ${DOWNLOAD_URL} || exit 1

echo "Converting XLS to CSV"
java -jar XlsToCsv.jar ${ADR_FILE}.xls || exit 1

export PGPASSWORD=${CEM_POSTGRES_PASSWORD}

echo "Creating staging_eu_pl_adr schema"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -f ./sql/create_eu_product_labels_tables.sql ${CEM_POSTGRES_DATABASE} || exit 1

echo "Loading intermediary table from csv"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -c "\COPY STAGING_EU_PL_ADR.EU_PRODUCT_LABELS_ORIGINAL FROM '${ADR_FILE}.csv' WITH DELIMITER E',' CSV HEADER QUOTE E'\"' NULL ''" ${CEM_POSTGRES_DATABASE}

echo "Copy from intermediary table to staging table"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -f ./sql/populate_eu_product_labels.sql ${CEM_POSTGRES_DATABASE} || exit 1

echo "Creating indexes"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -f ./sql/create_eu_product_labels_indexes.sql ${CEM_POSTGRES_DATABASE} || exit 1

echo "Finished!"
