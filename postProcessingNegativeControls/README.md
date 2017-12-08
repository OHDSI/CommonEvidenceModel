Post Processing - Negative Controls
====================
Negative controls are designed to detect both suspected and unsuspected sources of spurious causal inference.  For example, biologists employ "negative controls" as a means of ruling out possible noncausal interpretations of their results.  The essential purpose of a negative control is to reproduce a condition that cannot involve the hypothesized causal mechanism but is very likely to invole the same sources of bias that may have been present in the original association [<a href="#1">1</a>].  Martijn et al. have set the motivation for negative controls in the OHDSI community within the paper "Interpreting observational studies: why empirical calibration is needed to correct p-values" [<a href"#2">2</a>].

Once the CommonEvidenceModel is processed by the OHDSI team, one could use this Post Processing Package to find Negative Controls.  The entire program must be run on a case by case basis, i.e. for every negative control set you want to run the entire process needs to be run.  One must provide OMOP Concept IDs to identify the item you trying to study, these are the "concepts of interest".  The program will export an Excel document that reports:
1. What were the users settings were for the run (like the concepts of interest)
2. All potential "outcomes of interst" or potential negative controls evaluated and the scores for each
3. A generated list of what the process thinks are the best negative controls in order of prevalence
4. A list of Pubmed articles associated to the evidence found as a reason for removing concepts of interest

OHDSI's first attempt at producing negative controls can be found in the paper "Accuracy of an automated knowledge base for identifying drug adverse reactions" [<a href="#3">3</a>] however the process currently here is slightly different.  The Negative Controls tab selects negative controls by the following process:
1. Finds all potential concepts that are even possible for consideration.  This is done by finding the "concepts of interest" within patient data and finding "outcomes of interest" that occur after the "concepts of interest".  This is our "concept universe".  Using patient level data helps the program know if the concepts will even be viable for use as negative controls (i.e. a concepts may be a good negative control, however if it never occurs in data it will not be much use in quantifying bias).  While finding these concepts the program will additionally find patient counts as row counts (RC) which means how many persons had this exact concept and descendant counts (DC) which means how many persons had this exact cocnept and one of its descendants.
2. Find all concept that are known not to be good choices.
 - Broad Concepts - there are some concepts that are considered too broad for use.  For example "441840-clinical finding" is too broad to be meaningful as a negative control.
 - Drug Related - concepts that are related to a drug adverse reaction do not make for good negative controls.
 - Pregnancy - exclude pregnancy related concepts.
 - Splicer - the US product labels are parsed via the tool SPLICER and reviews the "Adverse Drug Reactions" and "Postmarketing" section to find associated concepts.  Finding concepts on the label in this manner suggests there is already an association between the concepts and therefore are not good negative controls.
 - Drug Indication - the OMOP Vocabulary suggests concepts that are the indications for drugs, which means there is an association between the concepts.
 - FAERS - exclude concepts that US spontaneous reports suggest are in an adverse drug reaction relationship [<a href="">4</a>].
 - User Identified Concepts to Exclude - if the user provides a list of concepts that should be exclude, the program will remove those found
 - User Identified Concepts to Include - while not forcing the concept to participate as a negative control, if they are found it will be highlighted for the user on the "Negative Controls" tab
3. Given the concept universe found in Step 1, evidence from the CommonEvidenceModel is pulled, specifically using Medline to find publications with a co-occurrence of MeSH terms in an adverse relationship [<a href="#5">5</a>].  If you have more than one "concept of interest" the program summarizes evidence across all "concepts of interest" provided.  This produces a list of Pubmed article IDs which can be found on the "PubMed Article" tab of the export for your information.
4. The evidence is then summarized, which pulls together information from Step 2 and Step 3.
5. Given the summarized data, the following is used to select the negative controls for the "Negative Controls" tab in the export:
 - Patient level data of a person row count >= 1000
 - No published literature evidence found as defined by the co-occurrence of MeSH terms with drug adverse event qualifiers [<a href="">4</a>]
 - Not associated via drug indication
 - Not considered too broad
 - Not associated with "drug induced" concepts
 - Not a pregnancy related concept
 - The US drug label does not suggest the concept is in an adverse event relationship
 - No spontaneous reports found (Currently Under Construction - <a href="../issues/3">Issue #3</a>)
 - The user has not suggested to exclude this concept
 - Finally, all remaining concepts are then "optimized", meaning parent concepts remove children concepts as defined by the OMOP Vocabulary

Features
====================

Technology
====================
 - R
 - RStudio
 - RTools
 
Sytem Requirements
====================
 - Access to the CommonEvidenceModel data
 - Access to patient level data

Dependencies
====================
- On Windows, make sure <a href="https://cran.r-project.org/bin/windows/Rtools/">RTools</a> is installed.  This is used for the export to Excel, it needs Zip.  Additionally you may have to set the <a href="https://stackoverflow.com/questions/27952451/error-zipping-up-workbook-failed-when-trying-to-write-xlsx">default zip package</a> to point to where your "RTools\bin"" reside (Sys.setenv(R_ZIPCMD= "C:/Rtools/bin")) and add it to the search path (in Win 7, Go to Control Panel > System > Advanced system settings > Environment variables... then under System variables, find Path, Edit... add to the end ";C:\Rtools\bin;C:\Rtools\gcc-4.6.3\bin" restart RStudio and go).    

Getting Started
====================
1. Under extras/ set up your config.csv.  There is an example found <a href="/extras/config.example.csv">here</a>.  
 - evidenceProcessingClean = "clean"
 - evidenceProcessingTranslated = "translated"
 - postProcessing = "evidence"
 
2. Under extras/ set up your config_patient_data.csv.  There is an exmample found <a href="extras/config_patient_data.example.csv">here</a>.  It is best to select a database that you are using for your study or a database that is fairly representative of the databases being used.  

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

Getting Involved
====================
Refer <a href="../CommonEvidenceModel#getting-involved">here</a>.

Contact Erica Voss and Lee Evans for access to the CommonEvidenceModel.

License
====================

Development
====================

Refereces
====================
[<a href="#1">1</a>] Lipsitch M, Tchetgen Tchetgen E, Cohen T. Negative controls: a tool for detecting confounding and bias in observational studies. Epidemiology. 2010 May;21(3):383-8. doi: 10.1097/EDE.0b013e3181d61eeb. Erratum in: Epidemiology. 2010 Jul;21(4):589. PubMed PMID: 20335814; PubMed Central PMCID: PMC3053408.

[<a href="#2">2</a>] Schuemie MJ, Ryan PB, DuMouchel W, Suchard MA, Madigan D. Interpreting observational studies: why empirical calibration is needed to correct p-values. Stat Med. 2014 Jan 30;33(2):209-18. doi: 10.1002/sim.5925. Epub 2013 Jul 30. PubMed PMID: 23900808; PubMed Central PMCID: PMC4285234.

[<a href="#3">3</a>] Voss EA, Boyce RD, Ryan PB, van der Lei J, Rijnbeek PR, Schuemie MJ. Accuracy of an automated knowledge base for identifying drug adverse reactions. J Biomed Inform. 2017 Feb;66:72-81. doi: 10.1016/j.jbi.2016.12.005. Epub 2016 Dec 16. PubMed PMID: 27993747; PubMed Central PMCID: PMC5316295.

[<a href="#4">4</a>] Evans SJ, Waller PC, Davis S. Use of proportional reporting ratios (PRRs) for signal generation from spontaneous adverse drug reaction reports. Pharmacoepidemiol Drug Saf. 2001 Oct-Nov;10(6):483-6. PubMed PMID: 11828828.

[<a href="#5">5</a>] Avillach P, Dufour JC, Diallo G, Salvo F, Joubert M, Thiessard F, Mougin F, Trifirò G, Fourrier-Réglat A, Pariente A, Fieschi M. Design and validation of an automated method to detect known adverse drug reactions in MEDLINE: a contribution from the EU-ADR project. J Am Med Inform Assoc. 2013 May 1;20(3):446-52. doi: 10.1136/amiajnl-2012-001083. Epub 2012 Nov 29. PubMed PMID: 23195749; PubMed Central PMCID: PMC3628051.
