#!/bin/bash

FTP_USER=anonymous
FTP_PASSWORD=secret-password

FTP_MESH_SERVER=nlmpubs.nlm.nih.gov
FTP_MESH_PATH=/online/mesh/MESH_FILES/xmlmesh

FTP_PUBMED_SERVER=ftp.ncbi.nlm.nih.gov
FTP_PUBMED_PATH_BASELINE=/pubmed/baseline
FTP_PUBMED_PATH_DAILY=/pubmed/updatefiles

FILES_FOLDER=files
FILES_FOLDER_PATH=$(pwd)/${FILES_FOLDER}

INI_FILE_NAME=medline_load.ini

echo "Reading config file"
. ../secret.config || exit 1

echo "Downloading pubmed baseline files"
wget -r --no-parent -nH -l1 -A '*.gz' --user=${FTP_USER} --password=${FTP_PASSWORD} ftp://${FTP_PUBMED_SERVER}${FTP_PUBMED_PATH_BASELINE} || exit 1

echo "Downloading pubmed update files"
wget -r --no-parent -nH -l1 -A '*.gz' --user=${FTP_USER} --password=${FTP_PASSWORD} ftp://${FTP_PUBMED_SERVER}${FTP_PUBMED_PATH_DAILY} || exit 1

echo "Downloading mesh files"
wget -r --no-parent -nH -l1 -A '*.gz' --user=${FTP_USER} --password=${FTP_PASSWORD} ftp://${FTP_MESH_SERVER}${FTP_MESH_PATH}

echo "Moving all downloaded files to one folder"
mkdir ${FILES_FOLDER}
mv .${FTP_MESH_PATH}/* "${FILES_FOLDER_PATH}"
mv .${FTP_PUBMED_PATH_DAILY}/* "${FILES_FOLDER_PATH}"
mv .${FTP_PUBMED_PATH_BASELINE}/* "${FILES_FOLDER_PATH}"

echo "creating ini file for java app"
cat >${INI_FILE_NAME} <<EOF
DATA_SOURCE_TYPE = POSTGRESQL
USER = $CEM_POSTGRES_USER
PASSWORD = $CEM_POSTGRES_PASSWORD
SCHEMA = staging_medline
CREATE_SCHEMA = true
SERVER = ${CEM_POSTGRES_HOST}:5432/${CEM_POSTGRES_DATABASE}
XML_FOLDER = $FILES_FOLDER
MESH_XML_FOLDER = $FILES_FOLDER_PATH
EOF

echo "Loading pubmed xml files into db ... hold tight ... this will take about 6 days ..."
java -Xmx12G -jar MedlineXmlToDatabase.jar -parse -ini ${INI_FILE_NAME} || exit 1

echo "Loading mesh"
java -Xmx12G -jar MedlineXmlToDatabase.jar -parse_mesh -ini ${INI_FILE_NAME} || exit 1

export PGPASSWORD=${CEM_POSTGRES_PASSWORD}

echo "Creating indexes"
psql -h "${CEM_POSTGRES_HOST}" -U "${CEM_POSTGRES_USER}" -f ./sql/create_indexes.sql -d "${CEM_POSTGRES_DATABASE}" || exit 1

echo "Granting permissions to ${CEM_POSTGRES_USER}"
psql -h "${CEM_POSTGRES_HOST}" -U "${CEM_POSTGRES_USER}" -f ./sql/grant_permissions.sql -d "${CEM_POSTGRES_DATABASE}" -v CEM_POSTGRES_USER="${CEM_POSTGRES_USER}" || exit 1

echo "Finished!"
