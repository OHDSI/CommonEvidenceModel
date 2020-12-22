SEMMEDDB staging data load process
==================================

Background
----------
This is the SEMMEDDB staging data load process.

The source data file is available as a mySQL database dump file for download at the following website:

[SEMMEDDB website](https://ii.nlm.nih.gov/SemRep_SemMedDB_SKR/SemMedDB/SemMedDB_download.shtml)

To run the job you need to point the script to the url where it can find the latest version

Table(s) loaded
---------------
staging_semmeddb tables

Dependencies
------------

1. MySQL database
2. pgloader (if you don't have the script will install it for you)

Instructions
------------

1. Check you have your MySQL variables configured in the secret.config file
2. Update the DOWNLOAD_URL variable in the load_semmed.sh script
3. Run the `load_semmed.sh` script.

Notes
---------
The SemMedDB is approxiamtly 20GB in size, downloading, loading into mysql, and porting to postgres will take some time.




