SEMMEDDB staging data load process
==================================

Background
----------
This is the SEMMEDDB staging data load process.

The source data file is available as a mySQL database dump file for download at the following website:

[SEMMEDDB website](https://skr3.nlm.nih.gov/SemMedDB/download/download.html)

Table(s) loaded
---------------
staging_semmeddb tables

Dependencies
------------
1. mySQL database
2. mySQL client software


Instructions
------------
1. Download the latest available version of the semmeddb 'Entire database' mySQL database dump file from the SEMMEDDB website.
2. Load the Pentaho job in the Pentaho Spoon client.
3. Update the file name variable in the job variables.
4. Save the job.
5. Run the job. (It copies the semmeddb tables from the mysql database to the cem database staging_semmeddb schema tables). Note the PREDICTION_AUX and GENERIC_CONCEPT tables are not required for CEM processes so they are not copied.





