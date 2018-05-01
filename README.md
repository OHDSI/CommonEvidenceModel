# CommonEvidenceModel

## Introduction
The CommonEvidenceModel (CEM) leverages work previously performed within LAERTES, also known as the OHDSI Knowledgebase.  However, the focus here is building infrastructure to update the incoming raw sources as well as the post processing of finding Negative Controls.

 ![CEM Process Flow](src/img/CEM_PROCESS.png)

This project is an offshoot of the OHDSI Knowledgebase which more information can be found here:
* [https://github.com/OHDSI/KnowledgeBase](https://github.com/OHDSI/KnowledgeBase)
* Boyce RD, Ryan PB, Norén GN, Schuemie MJ, Reich C, Duke J, Tatonetti NP, Trifirò G, Harpaz R, Overhage JM, Hartzema AG, Khayter M, Voss EA, Lambert CG, Huser V, Dumontier M. Bridging islands of information to establish an integrated knowledge base of drugs and health outcomes of interest. Drug Saf. 2014 Aug;37(8):557-67. doi: 10.1007/s40264-014-0189-0. [PubMed PMID: 24985530](https://www.ncbi.nlm.nih.gov/pubmed/24985530); PubMed Central PMCID: PMC4134480.
* Voss EA, Boyce RD, Ryan PB, van der Lei J, Rijnbeek PR, Schuemie MJ. Accuracy of an automated knowledge base for identifying drug adverse reactions. J Biomed Inform. 2017 Feb;66:72-81. doi: 10.1016/j.jbi.2016.12.005. Epub 2016 Dec 16. [PubMed PMID: 27993747](https://www.ncbi.nlm.nih.gov/pubmed/27993747); PubMed Central PMCID: PMC5316295.
* Knowledge Base workgroup of the Observational Health Data Sciences and Informatics (OHDSI) collaborative. Large-scale adverse effects related to treatment evidence standardization (LAERTES): an open scalable system for linking pharmacovigilance evidence sources with clinical data. J Biomed Semantics. 2017 Mar 7;8(1):11. doi: 10.1186/s13326-017-0115-3. PubMed PMID: 28270198; [PubMed Central PMCID: PMC5341176](https://www.ncbi.nlm.nih.gov/pubmed/28270198).

## Data Status

| source_id|description|provenance|contributor_organization|contact_name|creation_date|coverage_start_date|coverage_end_date|version_identifier |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AEOLUS|Spontaneous reports and signals from FDA Adverse Event Reporting System (FAERS) based on the paper Banda, J. M. et al. A curated and standardized adverse drug event resource to accelerate drug safety research. Sci. Data 3:160026 doi: 10.1038/sdata.2016.26 (2016).|AEOLUS|Center for Biomedical Informatics Research, Stanford University|Lee Evans (LTS Computing LLC)|2016-04-22|2004-01-01|2015-06-01|V1 |
| MEDLINE_COOCCURRENCE|Co-occurrence of a drug and condition MeSH tag on a publication pulled from MEDLINE.|MEDLINE|Janssen R&D|Erica Voss|1900-01-01|1900-01-01|1900-01-01|V1 |
| MEDLINE_AVILLACH|Co-occurrence of a drug and condition MeSH tag on a publication with the qualifiers adverse effects and chemically induced respectively.  Based on publication Avillach P, Dufour JC, Diallo G, Salvo F, Joubert M, Thiessard F, Mougin F, Trifiro G, Fourrier-Reglat A, Pariente A, Fieschi M. Design and validation of an automated method to detect known adverse drug reactions in MEDLINE: a contribution from the EU-ADR project. J Am Med Inform Assoc. 2013 May 1;20(3):446-52. doi: 10.1136/amiajnl-2012-001083. Epub 2012 Nov 29. PubMed PMID: 23195749; PubMed Central PMCID: PMC3628051.|MEDLINE|Janssen R&D|Erica Voss|1900-01-01|1900-01-01|1900-01-01|V1 |
| MEDLINE_PUBMED|Co-occurrence of a drug and condition MeSH tag or found in the Title of Abstract of a publication.  Leverages Pubmed.|PUBMED|Janssen R&D|Erica Voss|1900-01-01|1900-01-01|1900-01-01|V1 |
| MEDLINE_WINNENBURG|Winnenburg R, Sorbello A, Ripple A, Harpaz R, Tonning J, Szarfman A, Francis H, Bodenreider O. Leveraging MEDLINE indexing for pharmacovigilance - Inherent limitations and mitigation strategies. J Biomed Inform. 2015 Oct;57:425-35. doi: 10.1016/j.jbi.2015.08.022. Epub 2015 Sep 2. PubMed PMID: 26342964; PubMed Central PMCID: PMC4775467.|MEDLINE|Janssen R&D|Erica Voss|1900-01-01|1900-01-01|1900-01-01|V1 |
| SEMMEDDB|Semantic Medline uses natural language processing to extract semantic predictions from titles and text.  H. Kilicoglu et al., Constructing a semantic predication gold standard from the biomedical literature, BMC Bioinformatics 12 (2011) 486.|SEMMEDDB|National Institutes of Health|National Institutes of Health|2016-12-31|1865-01-01|2016-12-31|V30 |
| SPLICER|Adverse drug reactions extracted from the Adverse Reactions or Post Marketing section of United States product labeling. Based on publication J. Duke, J. Friedlin, X. Li, Consistency in the safety labeling of bioequivalent medications, Pharmacoepidemiol. Drug Saf. 22 (3) (2013) 294?301.|SPLICER|Regenstrief Institute|Jon Duke|1900-01-01|1900-01-01|1900-01-01|V |
| EU_PL_ADR|From the PROTECT ADR database, this provided a list of ADRS on Summary of Product Characteristics (SPC) of products authorized in the European Union.  Pharmacoepidemiological Research on Outcomes of Therapeutics by a European Consortium (PROTECT), Adverse Drug Reactions Database, [webpage] (2015.05.07), Available from: <http://www.imi-protect.eu/adverseDrugReactions.shtml>|EU_PL_ADR|PROTECT|PROTECT|2015-05-30|1900-01-01|2015-05-30|20150630 |

## Features

### Post Processing - Negative Controls

#### What is a Negative Control

Exposure-outcome pairs for which there is no known causal relationship [1].  They are used to identify, estimate, and resolve residual confounding [2]. There are two types of negative controls: (1) negative control exposures are exposures known to have no association with the outcome of interest and (2) negative control outcomes are outcomes known to have no association with the exposures of interest.

#### Motivation for Negative Controls

Often epidemiologic studies on observational data declare results statistically significant when the “p < 0.05” saying that there is only a 5% probability that the observed effect is by chance alone.  However, observational data is vulnerable to systematic error such as bias and confounding [2].  In 2013, the OHDSI community published work showing that empirical calibration “reduced spurious results to the desired 5% level” [2].  The empirical calibration framework is based on modeling the observed null distribution of negative controls.  “Using the empirical distributions of negative controls, we can compute a better estimate of the probability that a value at least as extreme as a certain effect estimate could have been observed under the null hypothesis” [2].  The OHDSI community recommends that observational study always include negative controls to derive the empirical null distribution and use these to calibrate p-values.

#### Common Evidence Model Information

The CommonEvidenceModel (CEM) leverages work previously performed within LAERTES, also known as the OHDSI Knowledgebase [3]. However, the focus of CEM was building infrastructure to update the incoming raw sources as well as the post processing of finding Negative Controls.

##### Prep for Building Negative Controls

Typically, negative controls are processed for a user given a set of concepts of interest.  However, some data processing can occur prior to a given user’s request for negative controls.  Find detailed documentation here on the preparatory processing.

[Negative Controls Prep](https://github.com/OHDSI/CommonEvidenceModel/blob/master/postProcessingNegativeControlsPrep/README.md)

##### Where to Obtain Negative Controls

OHDSI has built a tool called ATLAS where negative controls can be processed calling evidence from the CommonEvidenceModel.  See detailed information here on how to perform this process.

[Getting Negative Controls from ATLAS](https://github.com/OHDSI/CommonEvidenceModel/blob/master/postProcessingNegativeControls/README-ATLAS.md)

##### Best Practices of Obtaining Negative Controls

1.	For your given study, generate one concept set with all drugs or conditions that you are trying to study.  We recommend when choosing negative controls for drugs, using the classes of target and comparator drug.  
2.	Via ATLAS generate and view evidence based on that one concept set.
3.	Export concept set to CSV.
4.	Reviewing in the “Sort Order” (smallest to largest) review concepts till you get between 50 and 60 concepts.  50 negative controls are recommended for calibration so shooting for 60 gives you a few additional concepts if it is determined later that they should not be included.  If you are reviewing conditions for a set of drugs, open the drug labels to help in your review.
5.	Once you have a subset of believed negative controls, submit the list for clinical review.

Some notes to think about when generating a list of negative controls:
 - Negative controls do not preclude an expected association between exposure and outcome. For example, when studying celecoxib, a good negative control outcome would be ingrown nails. We do expect an association, because celecoxib tends to be given to older people, who are also more at risk of ingrown nails, but there is no causal association.  One way to think about causation is whether an intervention would have an effect. If we were to intervene and switch all people on celecoxib to another medication, would we expect a difference in the number of ingrown nails? If the answer is no, then it is likely a good negative control.
 - A causal relationship can be positive or negative. If a drug causes an outcome to happen, then it cannot be a negative control. Also, if a drug is known to prevent an outcome, it cannot be used as a negative control. For a negative control we expect the true relative risk to be exactly 1, not bigger but also not smaller.
 - Comparative effect study: we define negative controls as target-comparator-outcome triplets where neither target nor comparator is believed to cause the outcome.

##### Description of Process

If you would like to describe the process of selecting negative controls from the CommonEvidenceModel in published literature, please feel free to use this verbiage:

> Negative controls are concepts known to not be associated with the target or comparator cohorts, such that we can assume the true relative risk between the two cohorts is 1. Negative controls are selected using a similar process to that outlined by Voss et al [3]. Person counts of all potential drug-condition pairs are reviewed in a diverse set observational data; this person count data helps determine which pairs are even probable for use in calibration as well as provide a priority for which pairs should be reviewed first. Given the list of potential drug-condition pairs, the concepts in the pairs must meet the following requirements to be considered as negative controls: (1) have no published literature association between the drug-condition pair of interest, either exactly as the evidence was mapped, a lower lever concept contained evidence, a direct parent concept contained evidence, or an ancestor contained evidence, (2) not existing on the US product label in the “Adverse Drug Reactions” or “Postmarketing” section, either exactly as the evidence was mapped, a lower lever concept contained evidence, a direct parent concept contained evidence, or an ancestor contained evidence, (3) not considered a FAERS signal [4], either exactly as the evidence was mapped, a lower lever concept contained evidence, a direct parent concept contained evidence, or an ancestor contained evidence, (4) have no indication or contraindication listed in the OMOP Vocabulary for the pair, (5) are not considered a broad concepts, (6) are not considered a drug induced concept, or (7) not considered a pregnancy related concept.  The remaining concepts are “optimized”, meaning parent concepts remove children as defined by the OMOP Vocabulary (e.g. if both “Non-Hodgkin’s Lymphoma” and “B-Cell Lymphoma” we selected, child concept “B-Cell Lymphoma would be removed for its parent “Non-Hodgkin’s Lymphoma”). Once potential negative control candidates were selected, manual clinical review to exclude any pairs that may still be in a causal relationship or similar to the study outcome was be performed to select the top concepts by patient exposure.

#### References

1.	Lipsitch, M., E. Tchetgen Tchetgen, and T. Cohen, Negative controls: a tool for detecting confounding and bias in observational studies. Epidemiology, 2010. 21(3): p. 383-8.
2.	Schuemie, M.J., et al., Interpreting observational studies: why empirical calibration is needed to correct p-values. Stat Med, 2014. 33(2): p. 209-18.
3.	Voss, E.A., et al., Accuracy of an automated knowledge base for identifying drug adverse reactions. J Biomed Inform, 2017. 66: p. 72-81.
4.	Evans, S.J., P.C. Waller, and S. Davis, Use of proportional reporting ratios (PRRs) for signal generation from spontaneous adverse drug reaction reports. Pharmacoepidemiol Drug Saf, 2001. 10(6): p. 483-6.

## Technology

## System Requirements

## Dependencies

## Getting Started

## Getting Involved
* Join the [Working Group](http://www.ohdsi.org/web/wiki/doku.php?id=projects:workgroups:kb-wg) 
* Developer questions/comments/feedback: <a href="http://forums.ohdsi.org/c/developers">OHDSI Forum</a>
* We use the <a href="../../issues">GitHub issue tracker</a> for all bugs/issues/enhancements

## License

## Development
