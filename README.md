# CommonEvidenceModel

For more information about the CommonEvidenceModel, post processing steps like generating negative controls, or learning out to get involved, please visit our wiki.

[https://github.com/OHDSI/CommonEvidenceModel/wiki](https://github.com/OHDSI/CommonEvidenceModel/wiki)

Run Order:
1. Information Prep (to load native data needed for CEM)
2. MeSHTags (preps a MeSH Vocabulary Patch)
 --Before processing update the config_patient_data.csv
 --After running, place updated MeSHTags.csv in "evidenceProcessingClean\inst\csv" 
3. Run evidenceProcessingClean (this is a long running process, it may take up to a week)
4. Run evidenceProcessingTranslated (currently not running Medline_Cooccurrence for extra long processing time)
5. Run postProcessingEvidenceUnify 
6. Run postProcessingNegativeControlsPrep
 --This process generates a CSV file on an FTP that needs to be loaded by a separate process
7. Run postProcessing
