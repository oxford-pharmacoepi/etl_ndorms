-- update death from death_ons
With temp1 AS(
	select t1.* 
	from {TARGET_SCHEMA}.death_ons as t1
	join {TARGET_SCHEMA_TO_LINK}.death as t2 on t1.person_id = t2.person_id
), cte as(
	update {TARGET_SCHEMA_TO_LINK}.death as t1
	set death_date =  t2.death_date,
	death_datetime = t2.death_datetime,
	death_type_concept_id = t2.death_type_concept_id,
	cause_concept_id = t2.cause_concept_id,
	cause_source_value = t2.cause_source_value,
	cause_source_concept_id = t2.cause_source_concept_id
	from temp1 as t2 
	where t1.person_id = t2.person_id
	returning t1.*
)
select count(*) from cte;
