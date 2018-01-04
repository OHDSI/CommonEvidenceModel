Post Processing - Negative Controls - PREP
====================
Typically when processing negative controls it is performed given a input of of concept of interest requesting outcomes of interest.  However there are a few steps that can be performed regardless of the users inputs.  This package handles those steps.

## Concept Universe
Given a situation where a user does not have access to person level data when building negative controls, a concept universe will be constructed using person counts from a large US claims database.  Utilization of concepts within the database define potential concepts that can be used for negative controls and give a user a sense of how prevelant the concept is.  The list of concepts consists of both drug (at the ingredient level) and condition concepts and provide both a person count for how many people had the exact concept or the exact concept and its descendants.

## Broad Concepts
We use patient level data and the OMOP Vocabulary to help us find "Too Broad" concepts to eliminate from our Negative Controls map.  Something "Too Broad" does not describe something in enough detail to be useful for a negative control.  For example, "clinical finding" is too vague and would be impossible to understand the relationship between a drug and that condition concept.  Our method for finding broad concepts is as follows:
1) Concepts together with their descendant concepts that have more than 1,000,000 people with it in a large claims database.
2) Concepts that contain certain word patterns (e.g. "FINDING", "DISORDER OF", "DISEASE OF", etc.).
3) Condition concepts that have more than 45 relationships to other condition concepts.
4) Concepts that are directly below the most top SNOMED concept 4008453-SNOMED CT Concept
5) Any concepts that were found outside the above, that are still deemed too broad are cherry-picked and added to the list (e.g. "ILLNESS") 

## Drug Related
Concepts that are related to a drug adverse reaction do not make for good negative controls.

## Pregnancy Conditions
Pregnancy related concepts.