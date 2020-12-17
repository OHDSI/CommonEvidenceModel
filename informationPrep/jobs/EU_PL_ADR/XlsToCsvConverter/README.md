EU PL ADR Xls to Csv Converter
===================================

Basics
----------
The European product label source data file which is available for download at the following website:

[IMI Protect EU](http://www.imi-protect.eu/adverseDrugReactions.shtml "IMI EU PROTECT ADR database")

is an xls file with some unfortunate inconsistancies. This small app takes the file and produces a Csv that can be used
to populate the db.

This app was written for the file that `ADRdatabase_DLP30Jun2017.xls` file as was available in 2020, it is likely that newer versions of the db are formatted differently, so the code might need to be adjusted.

Requirements
---------------
Java 8 \
Maven

Instructions
------------

1. run `mvn clean package assembly:single`
2. use the generated jar file with dependencies, rename it to XlsToCsv.jar and place it in the EU_PL_ADR folder.
3. It is run with `java -jar XlsToCsv.jar <the source file>`

