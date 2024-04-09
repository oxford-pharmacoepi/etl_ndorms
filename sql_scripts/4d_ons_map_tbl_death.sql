-- insert death_ons to death
insert into {TARGET_SCHEMA_TO_LINK}.death
select t1.* 
from {TARGET_SCHEMA}.death_ons as t1
left join {TARGET_SCHEMA_TO_LINK}.death as t2 on t1.person_id = t2.person_id
where t2.person_id is null;

-- update death by death_ons
With temp1 AS(
	select t1.* 
	from {TARGET_SCHEMA}.death_ons as t1
	join {TARGET_SCHEMA_TO_LINK}.death as t2 on t1.person_id = t2.person_id
)
update {TARGET_SCHEMA_TO_LINK}.death as t1
set death_date =  t2.death_date,
death_datetime = t2.death_datetime,
cause_concept_id = t2.cause_concept_id,
cause_source_value = t2.cause_source_value,
cause_source_concept_id = t2.cause_source_concept_id
from temp1 as t2 
where t1.person_id = t2.person_id;
