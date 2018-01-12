/*in the event that a user does not have patient level information we will use
a static patient count provided by a large US claims database
this table will be a mix of drugs (ingredients) and conditions*/

/*
SELECT c.CONCEPT_ID, c.CONCEPT_NAME,
	z.PERSON_COUNT_DC,
	z.PERSON_COUNT_RC
FROM (
	SELECT z.CONCEPT_ID,
		z.PERSON_COUNT_DC,
		CASE WHEN y.PERSON_COUNT_RC IS NULL THEN 0 ELSE y.PERSON_COUNT_RC END AS PERSON_COUNT_RC
	FROM (
		SELECT ca.ANCESTOR_CONCEPT_ID AS CONCEPT_ID,
			COUNT(DISTINCT co.PERSON_ID) AS PERSON_COUNT_DC
		FROM @schemaRaw.CONDITION_OCCURRENCE co
			JOIN @schemaRaw.CONCEPT_ANCESTOR ca
				ON ca.DESCENDANT_CONCEPT_ID = co.CONDITION_CONCEPT_ID
		WHERE CONDITION_CONCEPT_ID != 0
		AND YEAR(CONDITION_START_DATE) = YEAR(GETDATE())-2
		GROUP BY ca.ANCESTOR_CONCEPT_ID
		HAVING COUNT(DISTINCT co.PERSON_ID) >= @filter
	) z
		LEFT OUTER JOIN	(
			SELECT CONDITION_CONCEPT_ID AS CONCEPT_ID,
			  COUNT_BIG(DISTINCT PERSON_ID) AS PERSON_COUNT_RC
			FROM @schemaRaw.CONDITION_OCCURRENCE
			WHERE CONDITION_CONCEPT_ID != 0
			AND YEAR(CONDITION_START_DATE) = YEAR(GETDATE())-2
			GROUP BY CONDITION_CONCEPT_ID
		) y
			ON z.CONCEPT_ID = y.CONCEPT_ID

	UNION ALL

  /*Since we are using ingredients the RC/DC split doesn't make sense here,
  both will be set to the same number
	SELECT DRUG_CONCEPT_ID AS CONCEPT_ID,
		COUNT_BIG(DISTINCT PERSON_ID) AS PERSON_COUNT_RC,
		COUNT_BIG(DISTINCT PERSON_ID) AS PERSON_COUNT_DC
	FROM @schemaRaw.DRUG_ERA
	GROUP BY DRUG_CONCEPT_ID
	HAVING COUNT_BIG(DISTINCT PERSON_ID) >= @filter
) z
	JOIN @schemaRaw.CONCEPT c
		ON c.CONCEPT_ID = z.CONCEPT_ID
*/
WITH CTE_DC AS (
	select t1.drug_concept_id, ca1.ancestor_concept_id as condition_concept_id, sum(t1.num_persons) as PERSON_COUNT_ESTIMATE_DC
	from (
		select de1.drug_concept_id, ce1.condition_concept_id, count(de1.person_id) as num_persons
		from (
			select person_id, drug_concept_id, min(drug_era_start_date) as index_date
			from @schemaRaw.drug_era
			group by person_id, drug_concept_id
		) de1
			inner join (
				select person_id, condition_concept_id, min(condition_era_start_date) as condition_date
				from @schemaRaw.condition_era
				group by person_id, condition_concept_id
			) ce1
				on de1.person_id = ce1.person_id
				and de1.index_date < ce1.condition_date
		group by de1.drug_concept_id, ce1.condition_concept_id
	) t1
		inner join @schemaRaw.concept_ancestor ca1
			on t1.condition_concept_id = ca1.descendant_concept_id
	group by t1.drug_concept_id, ca1.ancestor_concept_id
	HAVING sum(t1.num_persons) > 100
),
CTE_RC AS (
	select t1.drug_concept_id, t1.condition_concept_id as condition_concept_id, sum(t1.num_persons) as PERSON_COUNT_ESTIMATE_RC
	from (
		select de1.drug_concept_id, ce1.condition_concept_id, count(de1.person_id) as num_persons
		from (
			select person_id, drug_concept_id, min(drug_era_start_date) as index_date
			from @schemaRaw.drug_era
			group by person_id, drug_concept_id
		) de1
			inner join (
				select person_id, condition_concept_id, min(condition_era_start_date) as condition_date
				from @schemaRaw.condition_era
				group by person_id, condition_concept_id
			) ce1
				on de1.person_id = ce1.person_id
				and de1.index_date < ce1.condition_date
		group by de1.drug_concept_id, ce1.condition_concept_id
	) t1
	group by t1.drug_concept_id, t1.condition_concept_id
)
SELECT 'NO NAME' AS DB_NAME, d.DRUG_CONCEPT_ID, d.CONDITION_CONCEPT_ID,
	CASE WHEN r.PERSON_COUNT_ESTIMATE_RC IS NULL THEN 0 ELSE r.PERSON_COUNT_ESTIMATE_RC END AS PERSON_COUNT_ESTIMATE_RC,
	d.PERSON_COUNT_ESTIMATE_DC
FROM CTE_DC d
	LEFT OUTER JOIN CTE_RC r
		ON r.DRUG_CONCEPT_ID = d.DRUG_CONCEPT_ID
		AND r.CONDITION_CONCEPT_ID = d.CONDITION_CONCEPT_ID;

