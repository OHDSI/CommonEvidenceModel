#!/bin/bash

SDO_STATS=standard_drug_outcome_statistics.csv
SDO_CONTINGENCY=standard_drug_outcome_contingency_table.csv

echo "Reading config file"
. ../secret.config || exit 1

export PGPASSWORD=${CEM_POSTGRES_PASSWORD}

psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -c "\COPY staging_aeolus.standard_drug_outcome_statistics FROM '${SDO_STATS}' WITH DELIMITER E',' HEADER CSV" ${CEM_POSTGRES_DATABASE}

psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -c "\COPY staging_aeolus.standard_drug_outcome_contingency_table FROM '${SDO_CONTINGENCY}' WITH DELIMITER E',' HEADER CSV" ${CEM_POSTGRES_DATABASE}

psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -f create_AEOLUS_indexes.sql ${CEM_POSTGRES_DATABASE} || exit 1

echo "Finished!"
