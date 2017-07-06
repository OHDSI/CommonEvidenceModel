WITH CTE_BAD_MESH AS (
	/*MESH TERMS WE DON'T WANT*/
	SELECT ma.DESCENDANT_UI
	FROM @sourceSchema.dbo.MESH_ANCESTOR ma
	WHERE ma.ANCESTOR_UI IN (
		'D000818', /*Animals*/
		'D023421', /*Models, Animal*/
		'D000820' /*Animal Diseasess*/
	)
	AND ma.DESCENDANT_UI NOT IN (
		SELECT ma.DESCENDANT_UI
		FROM @sourceSchema.dbo.MESH_ANCESTOR ma
		WHERE ma.ANCESTOR_UI IN (
		'D006801' /*Humans*/
		)
	)
),
CTE_BAD_PMID AS (
	SELECT DISTINCT mh.PMID
	FROM @sourceSchema.dbo.medcit_meshheadinglist_meshheading mh
	WHERE mh.descriptorname_ui IN (
		SELECT DISTINCT DESCENDANT_UI FROM CTE_BAD_MESH
	)
),
CTE_PULL_RECORDS AS (
	SELECT *
	FROM (
		SELECT mh.DESCRIPTORNAME_UI AS MESH_SOURCE_CODE, mh.descriptorname AS MESH_SOURCE_NAME,
			mh.PMID
		FROM @sourceSchema.dbo.medcit_meshheadinglist_meshheading mh
			JOIN @sourceSchema.dbo.medcit_meshheadinglist_meshheading_qualifiername q
				ON q.pmid = mh.pmid
				AND q.medcit_meshheadinglist_meshheading_order = mh.medcit_meshheadinglist_meshheading_order
				AND q.[value] = 'chemically induced'
	) z
	WHERE PMID NOT IN (SELECT PMID FROM CTE_BAD_PMID)
)
SELECT 'CONDITION' AS MESH_TYPE, MESH_SOURCE_CODE, MESH_SOURCE_NAME,
  COUNT(DISTINCT PMID) AS RECORD_COUNT, 'DISTINCT PMID' AS RECORD_TYPE
FROM CTE_PULL_RECORDS
WHERE MESH_SOURCE_CODE NOT IN (SELECT DISTINCT DESCENDANT_UI FROM CTE_BAD_MESH)
GROUP BY MESH_SOURCE_CODE, MESH_SOURCE_NAME
HAVING COUNT(DISTINCT PMID) >= @filter
ORDER BY MESH_SOURCE_CODE, MESH_SOURCE_NAME;
