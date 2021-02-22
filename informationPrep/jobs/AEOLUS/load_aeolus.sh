#!/bin/bash

SDO_STATS=standard_drug_outcome_statistics.csv
SDO_CONTINGENCY=standard_drug_outcome_contingency_table.csv

echo "Reading config file"
. ../secret.config || exit 1

export PGPASSWORD=${CEM_POSTGRES_PASSWORD}

echo "Creating AEOLUS tables"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -f sql/create_AEOLUS_tables.sql ${CEM_POSTGRES_DATABASE} || exit 1

echo "Copying data standard_drug_outcome_statistics"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -c "\COPY staging_aeolus.standard_drug_outcome_statistics FROM '${SDO_STATS}' WITH DELIMITER E',' HEADER CSV" ${CEM_POSTGRES_DATABASE}

echo "Copying data standard_drug_outcome_contingency_table"
psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -c "\COPY staging_aeolus.standard_drug_outcome_contingency_table FROM '${SDO_CONTINGENCY}' WITH DELIMITER E',' HEADER CSV" ${CEM_POSTGRES_DATABASE}

echo "Finished!"
