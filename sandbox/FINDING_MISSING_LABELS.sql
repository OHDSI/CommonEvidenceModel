/*################################################################################
# FINDING MISSING LABELS
################################################################################*/
--We want to be able to tell the user what labels we are missing from US SPLs

--When OUTCOME of Interest = "CONDITIONS"
--Given the concepts of interest, find if they exist in US SPLs

--When OUTCOME of Interest = "DRUGS" you could perform this for each item
WITH CTE_DRUGS AS (
	SELECT DISTINCT c2.CONCEPT_ID, c2.CONCEPT_NAME
	FROM VOCABULARY.CONCEPT c
		JOIN VOCABULARY.CONCEPT_ANCESTOR ca
			ON ca.DESCENDANT_CONCEPT_ID = c.CONCEPT_ID
			AND c.CONCEPT_ID IN (
				--USER DEFINED DRUGS
				42904205,1119119,1151789
			)
		JOIN VOCABULARY.CONCEPT c2
			ON c2.CONCEPT_ID = ca.DESCENDANT_CONCEPT_ID
			WHERE c2.CONCEPT_CLASS_ID = 'Ingredient'
), 
CTE_LABELS_FOUND AS (
	SELECT DISTINCT c.CONCEPT_ID, c.CONCEPT_NAME
	FROM EVIDENCE.CEM_UNIFIED s
		JOIN VOCABULARY.CONCEPT_ANCESTOR ca
			ON ca.DESCENDANT_CONCEPT_ID = s.CONCEPT_ID_1
		JOIN VOCABULARY.CONCEPT c
			ON c.CONCEPT_ID = ca.ANCESTOR_CONCEPT_ID
			AND c.CONCEPT_CLASS_ID = 'Ingredient'
			AND c.CONCEPT_ID IN (
				SELECT CONCEPT_ID FROM CTE_DRUGS
			)
	WHERE s.SOURCE_ID = 'splicer' 
)
SELECT d.CONCEPT_ID, d.CONCEPT_NAME, 
	CASE WHEN f.CONCEPT_ID IS NULL THEN 0 ELSE 1 END US_SPL_LABEL
FROM CTE_DRUGS d
	LEFT OUTER JOIN CTE_LABELS_FOUND f
		ON f.CONCEPT_ID = d.CONCEPT_ID
