#!/bin/bash

FILES_FOLDER="./SherlockExport-2021-01-07/data"

echo "Reading config file"
. ../secret.config

export PGPASSWORD=${CEM_POSTGRES_PASSWORD}

# psql -h ${CEM_POSTGRES_HOST} -U ${CEM_POSTGRES_USER} -f ./sql/create_sherlock_tables.sql ${CEM_POSTGRES_DATABASE} || exit 1

# The data files provided in january 2021 contained '~*~' delimiters, returns in columns and a '~*~|' new line
# Postgres can not cope loading such a sophisticated file so here we convert it to a tab delimiter
# Using a bunch of ways to edit the file because they were giving me a hard time, if you can fix it to a neat onliner, please do.
# Here we loop over the files clean them and insert the in the db.
for FILE in "${FILES_FOLDER}"/*.txt; do
  echo "formatting ${FILE}"
  # First remove all the new lines, tabs and returns
  tr '\n' ' ' <"${FILE}" >nonewlines.txt
  tr -d '\r' <nonewlines.txt >noreturns.txt
  tr -d '"' <noreturns.txt >noquotes.txt
  tr -d '\000' <noquotes.txt >nonulls.txt

  # add a quote to the first line
  sed -i '1s/^/"/' nonulls.txt

  # Replace the ~*~| new line indicator with a new line
  perl -p -e 's/~\*~\|\s/"\n"/g' nonulls.txt >withreturns.txt

  # Use quoted comma separation
  perl -p -e 's/~\*~/","/g' withreturns.txt >commaseperated.txt

  # Remove quoted nulls otherwise numbers will fail
  perl -p -e 's/""//g' commaseperated.txt >almostdone.txt

  # Remove an additional line at the end of the file don't know how that got there
  head -n -1 almostdone.txt >"${FILE}"_clean

  # Get table name an insert...
  TABLE_NAME=$(echo "${FILE:33}" | cut -f 1 -d '.')
  echo "Populating ${TABLE_NAME}"
  psql -h "${CEM_POSTGRES_HOST}" -U "${CEM_POSTGRES_USER}" -c "TRUNCATE TABLE staging_sherlock.${TABLE_NAME}" "${CEM_POSTGRES_DATABASE}"
  psql -h "${CEM_POSTGRES_HOST}" -U "${CEM_POSTGRES_USER}" -c "\COPY staging_sherlock.${TABLE_NAME} FROM '${FILE}_clean' WITH DELIMITER ',' CSV" "${CEM_POSTGRES_DATABASE}"
done

echo "All done!"
