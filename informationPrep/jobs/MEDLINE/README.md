MEDLINE staging data load process
===================================

Background
----------
This is the MEDLINE staging data load process.

The ETL job downloads the source data files from the following ftp sites:


[PUBMED ftp site](ftp://ftp.ncbi.nlm.gov/pubmed)
[MESH ftp site](ftp://nlmpubs.nlm.nih.gov)

Table(s) loaded
---------------
staging_medline tables

Dependencies
------------
1. Java JDK (e.g. openjdk).
2. MedlineXmlToDatabase java executable and lib, as well as the .ini file - see the below GitHub repo for installation and usage details:

[MedlineXMLToDatabase GitHub repository](https://github.com/OHDSI/MedlineXmlToDatabase)

Install the MedlineXmlToDatabase.jar and MedlineXmlToDatabase_lib folder in the same directory as the Pentaho job.

Instructions
------------
1. Load the Pentaho job in the Pentaho Spoon client.
2. Run the job.



