*******************************************************************************
* Common Evidence Model (CEM):  Data Prep
*******************************************************************************
This package is for loading data that will be used in the CEM to generate 
evidence.  The goal is to just load the data as is, to not perform specific
CEM processing at this point.

***MEDLINE***
Published literature data.
Martijn Schuemie has written this package and currently runs to load Medline to
a database.
https://github.com/OHDSI/MedlineXmlToDatabase

***SemMedDB***
Published literature data.
Instructions for download and information about the datasource can be found here:
https://skr3.nlm.nih.gov/SemMedDB/

***AEOLUS***
Spontaneous reporting data.
Current copy of the DB can be downloaded off this citation:
Banda JM, Evans L, Vanguri RS, Tatonetti NP, Ryan PB, Shah NH. A curated and
standardized adverse drug event resource to accelerate drug safety research. Sci 
Data. 2016 May 10;3:160026. doi: 10.1038/sdata.2016.26. PubMed PMID: 27193236;
PubMed Central PMCID: PMC4872271.

***SPLICER***
US Product label data.
Labels are parsed and associated to conditions found in the Adverse Drug 
Reactions of Postmarketing sections.  The parsed labels are supplied and loaded
into a database.
Based on work by Jon Duke found within this publication:
Duke J, Friedlin J, Li X. Consistency in the safety labeling of bioequivalent 
medications. Pharmacoepidemiol Drug Saf. 2013 Mar;22(3):294-301. doi:
10.1002/pds.3351. Epub 2012 Oct 8. PubMed PMID: 23042584.

***EU Product Labels***
1) Download file from http://www.imi-protect.eu/adverseDrugReactions.shtml

2) Save the file docs/euProductLabels folder the file. Name it 
euProductLabel_LOCKDATE.xlsx (e.g. euProducLabels_20150530.xlsx).  The lock
date will be within the Excel download.  Save as XLSX.

3) Additionally, once the raw data is loaded the substances need to be translated 
into CONCEPT_IDs.  There is a step to export the information needed from the 
data into Excel to then be used with Usagi.  

4) Leverage USAGI (https://github.com/OHDSI/Usagi) to map the substances to 
concepts.  Instructions on how to use the tool can be found on GitHub as well.





