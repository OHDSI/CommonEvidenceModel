Post Processing - Negative Controls
====================
Negative controls are designed to detect both suspected and unsuspected sources of spurious causal inference.  For example, biologists employ "negative controls" as a means of ruling out possible noncausal interpretations of their results.  The essential purpose of a negative control is to reproduce a condition that cannot involve the hypothesized causal mechanism but is very likely to invole the same sources of bias that may have been present in the original association [<a name="1">1</a>].  Martijn et al. have set the motivation for negative controls in the OHDSI community within the paper "Interpreting observational studies: why empirical calibration is needed to correct p-values" [<a name="2">2</a>].

OHDSI's first attempt at producing negative controls can be found in the paper "Accuracy of an automated knowledge base for identifying drug adverse reactions" [<a name="3">3</a>] however the underlying data and process have been updated to run on the CommonEvidenceModel.  Once the CommonEvidenceModel is processed by the OHDSI team, one could use this Post Processing Package to find Negative Controls.  The entire program must be run on a case by case basis, i.e. for every negative control set you want to run the entire process needs to be run.  One must provide OMOP Concept IDs to identify the item you trying to study, these are the "concepts of interest".  The program will export an Excel document that reports:
1. What were the users settings were for the run (like the concepts of interest)
2. All potential "outcomes of interst" or potential negative controls evaluated and the scores for each
3. A generated list of what the process thinks are the best negative controls in order of prevalence
4. A list of Pubmed articles associated to the evidence found as a reason for removing concepts of interest

However the preferred method is not to use this R script but to generate negative controls directly from OHDSI's ATLAS (starting in V2.4.0+); ATLAS allows you to use a web site to generate lists of negative controls without having to go through the hassel of running the R package.  See this [ReadMe](https://github.com/OHDSI/CommonEvidenceModel/blob/negativeControlReadMe/postProcessingNegativeControls/README-ATLAS.md) for more information on getting negative controls from ATLAS.

## Suggested Negative Controls Process
1. Generate potential list of negative controls using this [ReadMe](https://github.com/OHDSI/CommonEvidenceModel/blob/negativeControlReadMe/postProcessingNegativeControls/README-ATLAS.md).
2. Filter list by "Suggested Negative Control" = "Yes", sort the data by "Sort Order" (smallest to largest), and export the list of controls to a CSV.
3. In Excel review the list until you get at least 50 negative controls.  It is recommended to pull about 10 extra incase further review of the list eliminates some of the selected negative controls.  
	- If you are generating condition negative controls it is suggested to open the drug labels used to generate the list from [DailyMed](https://dailymed.nlm.nih.gov/dailymed/) and review boxed warning, warning and precautions, and adverse reactions sections.

## Features


## Technology
 - R
 - RStudio
 - RTools
 
## System Requirements
 - Access to the CommonEvidenceModel data
 - Access to patient level data

## Dependencies
- On Windows, make sure <a href="https://cran.r-project.org/bin/windows/Rtools/">RTools</a> is installed.  This is used for the export to Excel, it needs Zip.  Additionally you may have to set the <a href="https://stackoverflow.com/questions/27952451/error-zipping-up-workbook-failed-when-trying-to-write-xlsx">default zip package</a> to point to where your "RTools\bin"" reside (Sys.setenv(R_ZIPCMD= "C:/Rtools/bin")) and add it to the search path (in Win 7, Go to Control Panel > System > Advanced system settings > Environment variables... then under System variables, find Path, Edit... add to the end ";C:\Rtools\bin;C:\Rtools\gcc-4.6.3\bin" restart RStudio and go).    

## Getting Started
1. Under extras/ set up your config.csv.  There is an example found <a href="extras/config.example.csv">here</a>.  
 - evidenceProcessingClean = "clean"
 - evidenceProcessingTranslated = "translated"
 - postProcessing = "evidence"
 
2. Under extras/ set up your config_patient_data.csv.  There is an example found <a href="extras/config_patient_data.example.csv">here</a>.  It is best to select a database that you are using for your study or a database that is fairly representative of the databases being used.  

3. Under extras/ open the codeToRun.R file.  The parameters that need to be set to run under <a href="extras/codeToRun.R#L87">Config</a>:
 - outcomeOfInterest - are you looking for "condition" or "drug" negative controls
 - conceptsOfInterest - the concepts that you want to build negative controls for, you can add them in a comma delimted list here
 - conceptsToExclude - if you already know some concepts that you do not want include, you can add them in a comma delimted list here
 - conceptsToInclude - if you know concepts that you think are good negative controls add them here in a comma delimted list.  This will not force the concepts into the negative control list however highlight it for you in the output.
 - fileName - change the filename if you desire
 
4. In RStudio, build the package.

5. Run codeToRun.R from top to bottom.

6. Results will be exported to package folder.

7. Review "Negative Controls" tab until you are comfortable you have between 50 and 100 negative controls.  Start the review from the top of the list down.

## Getting Involved
Refer <a href="../../../#getting-involved">here</a>.

## License

## Development

## Refereces
[1](#1) Lipsitch M, Tchetgen Tchetgen E, Cohen T. Negative controls: a tool for detecting confounding and bias in observational studies. Epidemiology. 2010 May;21(3):383-8. doi: 10.1097/EDE.0b013e3181d61eeb. Erratum in: Epidemiology. 2010 Jul;21(4):589. PubMed PMID: 20335814; PubMed Central PMCID: PMC3053408.

[2](#2) Schuemie MJ, Ryan PB, DuMouchel W, Suchard MA, Madigan D. Interpreting observational studies: why empirical calibration is needed to correct p-values. Stat Med. 2014 Jan 30;33(2):209-18. doi: 10.1002/sim.5925. Epub 2013 Jul 30. PubMed PMID: 23900808; PubMed Central PMCID: PMC4285234.

[3](#3) Voss EA, Boyce RD, Ryan PB, van der Lei J, Rijnbeek PR, Schuemie MJ. Accuracy of an automated knowledge base for identifying drug adverse reactions. J Biomed Inform. 2017 Feb;66:72-81. doi: 10.1016/j.jbi.2016.12.005. Epub 2016 Dec 16. PubMed PMID: 27993747; PubMed Central PMCID: PMC5316295.

[4](#4) Evans SJ, Waller PC, Davis S. Use of proportional reporting ratios (PRRs) for signal generation from spontaneous adverse drug reaction reports. Pharmacoepidemiol Drug Saf. 2001 Oct-Nov;10(6):483-6. PubMed PMID: 11828828.

[5](#5) Winnenburg R, Sorbello A, Ripple A, Harpaz R, Tonning J, Szarfman A, Francis H, Bodenreider O. Leveraging MEDLINE indexing for pharmacovigilance - Inherent limitations and mitigation strategies. J Biomed Inform. 2015 Oct;57:425-35. doi: 10.1016/j.jbi.2015.08.022. Epub 2015 Sep 2. PubMed PMID: 26342964; PubMed Central PMCID: PMC4775467.
