Post Processing - Negative Controls - PREP
====================
Typically, when processing negative controls it is performed given a input of concept of interest requesting outcomes of interest.  However, there are a few steps that can be performed regardless of the users inputs.  This package handles those steps.

## Concept Universe
Not all drug-condition pairs are considered for evaluation, instead patient level data is used to select meaningful pairs as well as prevalent pairs.  Using a combination of US commercial claims, US Medicare claims, and Japanese data, set of drug-condition pairs are selected as a person total (across all three data sets) of individuals who experience the condition any time after exposure to the drug of interest (reviewed at the ingredient level only).  The sum of people across the datasets for a given drug-condition pair needs to be greater than 1000 individuals to be considered for evaluation of evidence.  Additionally, the sum of persons is used to give the data a sort order to the data, 1 being the most common drug-condition pair to N being the least common pair.  This sort order can help a user prioritize which pairs to review first (i.e. start from the smallest number and work your way down until you have enough pairs).

## Broad Concepts
Concepts that are "Too Broad" do not describe something in enough detail to be useful for a negative control.  For example, "clinical finding" is too vague and would be impossible to understand the relationship between a drug and that condition concept.  Our method for finding broad concepts is as follows:
1) Concepts that contain certain word patterns (e.g. "FINDING", "DISORDER OF", "DISEASE OF", etc.).
2) Drug concepts that associated to the following ATC codes:
 - A02AA, A02AB, A02AC, A02AD - salt compounds
 - B05XA - Electrolyte Solutions
 - A06AC - Bulk-Forming Laxatives
 - A07B - Intestinal Adsorbents
3) Condition concepts that have more than 45 relationships to other condition concepts.
4) Concepts that are directly below the most top SNOMED concept 4008453-SNOMED CT Concept
5) Any concepts that were found outside the above, that are still deemed too broad are cherry-picked and added to the list (e.g. "ILLNESS") 

## Drug Related
Concepts that are related to a drug adverse reaction do not make for good negative controls (e.g.  4168644-Propensity to adverse reactions to substance).

## Pregnancy Conditions
Pregnancy related concepts (e.g. 314099-Abnormal fetal heart rate).