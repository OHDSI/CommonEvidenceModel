/*in the event that a user does not have patient level information we will use
a static patient count provided by a large US claims database
this table will be a mix of drugs (ingredients) and conditions*/

WITH CTE_RC AS (
	select t1.drug_concept_id, t1.condition_concept_id as condition_concept_id, sum(t1.num_persons) as PERSON_COUNT_ESTIMATE_RC
	from (
		select de1.drug_concept_id, ce1.condition_concept_id, count(de1.person_id) as num_persons
		from (
			select person_id, drug_concept_id, min(drug_era_start_date) as index_date
			from @schemaRaw1.drug_era
			group by person_id, drug_concept_id
		) de1
			inner join (
				select person_id, condition_concept_id, min(condition_era_start_date) as condition_date
				from @schemaRaw1.condition_era
				group by person_id, condition_concept_id
			) ce1
				on de1.person_id = ce1.person_id
				and de1.index_date < ce1.condition_date
		group by de1.drug_concept_id, ce1.condition_concept_id
		/*UNION ALL
		select de1.drug_concept_id, ce1.condition_concept_id, count(de1.person_id) as num_persons
		from (
			select person_id, drug_concept_id, min(drug_era_start_date) as index_date
			from @schemaRaw2.drug_era
			group by person_id, drug_concept_id
		) de1
			inner join (
				select person_id, condition_concept_id, min(condition_era_start_date) as condition_date
				from @schemaRaw2.condition_era
				group by person_id, condition_concept_id
			) ce1
				on de1.person_id = ce1.person_id
				and de1.index_date < ce1.condition_date
		group by de1.drug_concept_id, ce1.condition_concept_id
		UNION ALL
		select de1.drug_concept_id, ce1.condition_concept_id, count(de1.person_id) as num_persons
		from (
			select person_id, drug_concept_id, min(drug_era_start_date) as index_date
			from @schemaRaw3.drug_era
			group by person_id, drug_concept_id
		) de1
			inner join (
				select person_id, condition_concept_id, min(condition_era_start_date) as condition_date
				from @schemaRaw3.condition_era
				group by person_id, condition_concept_id
			) ce1
				on de1.person_id = ce1.person_id
				and de1.index_date < ce1.condition_date
		group by de1.drug_concept_id, ce1.condition_concept_id*/
	) t1
	group by t1.drug_concept_id, t1.condition_concept_id
)
SELECT DRUG_CONCEPT_ID, CONDITION_CONCEPT_ID,
	ROW_NUMBER() OVER(ORDER BY PERSON_COUNT_ESTIMATE_RC DESC, DRUG_CONCEPT_ID, CONDITION_CONCEPT_ID) AS SORT_ORDER
FROM CTE_RC r
WHERE PERSON_COUNT_ESTIMATE_RC >= 10;
