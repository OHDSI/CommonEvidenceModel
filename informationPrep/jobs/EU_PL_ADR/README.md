EU_PL_ADR staging data load process
===================================

Background
----------
This is the European product label staging data load process.

The source data file is available for download at the following website:

[IMI Protect EU](http://www.imi-protect.eu/adverseDrugReactions.shtml "IMI EU PROTECT ADR database")

Table(s) loaded
---------------
staging_eu_pl_adr.eu_product_labels

Instructions
------------

1. Update the DOWNLOAD_URL variable in the load script
2. Run the `load_eu_pl_adr.sh` script.

Notes
-----------
The source data file is known to change format, if the conversion from xls to csv fails please modify the XlsToCsvConverter
to handle the file appropriately.

