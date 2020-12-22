UMLS staging data load process
==================================

Background
----------
This is the UMLS staging data load process.

The source data file is available for download at the following website:

[UMLS knowledge soures website](https://www.nlm.nih.gov/research/umls/licensedcontent/umlsknowledgesources.html)

Table(s) loaded
---------------
staging_umls.mrconso table

Dependencies
------------
1. Java JDK (e.g. openJDK)
2. UMLS account/license
3. Perl (required for file changes made through a regular expression in script)


Instructions
------------
1. Download the latest full umls zip file (e.g. current year plus AA or AB file suffix depending on whether the latest file is "end of year" or "middle of year").
2. Use the provided metamorphosys java app to export the english language UMLS vocabularies. Only the exported MRCONSO.RRF file is needed for the CEM UMLS data processing.
3) Add the MRCONSO.RRF file to this folder
4) Run the `load_umls.sh` script
