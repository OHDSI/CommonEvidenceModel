#!/bin/bash

DOWNLOAD_URL="https://ii.nlm.nih.gov/SemRep_SemMedDB_SKR/SemMedDB/download/semmedVER43_2020_R_WHOLEDB.sql.gz"
SEMMED_MYSQL_DUMP=semmed_wholedb.sql

echo "Reading config file"
. ../secret.config || exit 1

echo "The following steps may take up to several hours each, don't panic, get busy with something else."

echo "Downloading complete db dump... "
wget -O ${SEMMED_MYSQL_DUMP}.gz ${DOWNLOAD_URL} || exit 1

echo "Unzipping source file (may take a while)"
gunzip ${SEMMED_MYSQL_DUMP}.gz || exit 1

echo "Loading MySQL db from dump ..."
mysql -h "${SEMMED_MYSQL_HOST}" -u "${SEMMEDDB_MYSQL_USER}" --password="${SEMMEDDB_MYSQL_PASSWORD}" "${SEMMED_MYSQL_DB_NAME}" <"${SEMMED_MYSQL_DUMP}" || exit 1

if ! command -v pgloader &>/dev/null; then
  echo "Installing pgloader"
  sudo apt install -y pgloader
fi

echo "Copying MySQL to Postgres ..."
pgloader mysql://"${SEMMEDDB_MYSQL_USER}":"${SEMMEDDB_MYSQL_PASSWORD}"@"${SEMMED_MYSQL_HOST}"/"${SEMMED_MYSQL_DB_NAME}" \
  postgresql://"${CEM_POSTGRES_USER}":"${CEM_POSTGRES_PASSWORD}"@"${CEM_POSTGRES_HOST}"/"${CEM_POSTGRES_DATABASE}" || exit 1

echo "Finished!"
