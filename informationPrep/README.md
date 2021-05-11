Information Preparation Processes
=================================

Background
----------
These processes load the source data files into the Common Evidence Model (CEM) staging tables.

They load the source data for the following data sources which will be leveraged by the Common Evidence Model.

- OMOP Vocabulary
- AEOLUS
- MEDLINE
- SemMedDB
- SPLICER
- EU PL ADR
- UMLS
- CTD (TODO: CTD is not used downstream)

The vocabulary load process should be the first information preparation process run. The other information preparation
processes can be run in any order.

After loading a data source update the source.csv in the SOURCE folder and run the load_source script when all sources
are done.

Infrastructure and middleware required
--------------------------------------

1. Linux server - Ubuntu OS 14.04 or higher (last run on 18.04.5)
2. Java
3. PostgreSQL psql client - version 9.5.11 or higher (last ran un 13.1)
4. A PostgreSQL database to store the CEM data - version 9.6.2 or higher (last ran un 13)
5. A MySQL db to temporarily store the SemMedDB
6. Approx 300 GB of disk space

Deployment Instructions
-----------------------

1. Install Postgres on the Linux server, create a db and a user
2. Configure the values in the secret.config.template file within the jobs folder and rename it to secret.config.
3. Run the load scripts.

Notes
-----

1. The psql client is needed because PostgreSQL only allows bulk data loading using the psql '\COPY' command when the
   database user is not a database administrator.
