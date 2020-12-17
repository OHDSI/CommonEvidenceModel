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

The vocabulary load process should be the first information preparation process run. The other information preparation
processes can be run in any order.

Infrastructure and middleware required
--------------------------------------

1. Linux server - Ubuntu OS 14.04
2. Java 1.8 (At the time of writing (december 2020) PDI it is not compatible with Java 11!)
3. PostgreSQL psql client - version 9.5.11
4. Pentaho Data Integration server (PDI) - version 7.1
5. A PostgreSQL database to store the CEM data - version 9.6.2

Deployment Instructions
-----------------------

1. Install the psql client on the Linux server
2. Download the Community Edition of PDI from the Pentaho website and install it on the Linux server.
3. Edit the base (inbound) files directory path, CEM database host, userid and password values in the
   secret.config.template file within the jobs folder and rename it to secret.config.
4. Setup a PDI simple-JNDI database connection for the CEM database:
    - Update the provided "Connection-CEM-PROD" database host, userid and password in the example jdbc.properties file
      and copy it to the PDI simple-JNDI folder. 
    - In the Spoon client create a new database connection called "cem", specifying jdbc and the "Connection-CEM-PROD"
      JNDI database connection.

Notes
-----

1. The database connection info in the secret.config is needed by the psql client scripts because they cannot use a PDI JNDI database connection.
2. The psql client is needed because PostgreSQL only allows bulk data loading using the psql '\COPY' command when the database user is not a database administrator.
