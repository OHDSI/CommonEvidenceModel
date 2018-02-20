SET search_path = vocabulary;

with new_rowcounts as (
select 'concept'::varchar as table_name, count(*)  as new_rowcount from staging_vocabulary.concept
union all
select 'concept_ancestor'::varchar as table_name, count(*) as new_rowcount from staging_vocabulary.concept_ancestor
union all
select 'concept_class'::varchar as table_name, count(*) as new_rowcount from staging_vocabulary.concept_class
union all
select 'concept_relationship'::varchar as table_name, count(*) as new_rowcount from staging_vocabulary.concept_relationship
union all
select 'concept_synonym'::varchar as table_name, count(*) as new_rowcount from staging_vocabulary.concept_synonym
union all
select 'domain'::varchar as table_name, count(*) as new_rowcount from staging_vocabulary.domain
union all
select 'drug_strength'::varchar as table_name, count(*) as new_rowcount from staging_vocabulary.drug_strength
union all
select 'relationship'::varchar as table_name, count(*) as new_rowcount from staging_vocabulary.relationship
union all
select 'vocabulary'::varchar as table_name, count(*) as new_rowcount from staging_vocabulary.vocabulary
),
current_rowcounts as (
select 'concept'::varchar as table_name, count(*)  as current_rowcount from concept
union all
select 'concept_ancestor'::varchar as table_name, count(*) as current_rowcount from concept_ancestor
union all
select 'concept_class'::varchar as table_name, count(*) as current_rowcount from concept_class
union all
select 'concept_relationship'::varchar as table_name, count(*) as current_rowcount from concept_relationship
union all
select 'concept_synonym'::varchar as table_name, count(*) as current_rowcount from concept_synonym
union all
select 'domain'::varchar as table_name, count(*) as current_rowcount from domain
union all
select 'drug_strength'::varchar as table_name, count(*) as current_rowcount from drug_strength
union all
select 'relationship'::varchar as table_name, count(*) as current_rowcount from relationship
union all
select 'vocabulary'::varchar as table_name, count(*) as current_rowcount from vocabulary
)
select 	nr.table_name || '_new record count = ' || ltrim(to_char(new_rowcount, '999G999G999G999')) || 
	', difference from current count = ' || 
	ltrim(to_char((new_rowcount - current_rowcount),'999G999G999G999')) as table_load_log
from new_rowcounts nr
inner join current_rowcounts cr on nr.table_name = cr.table_name;
 