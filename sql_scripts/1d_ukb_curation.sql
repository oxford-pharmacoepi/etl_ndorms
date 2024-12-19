DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.death_cause CASCADE;

CREATE TABLE {SOURCE_NOK_SCHEMA}.death_cause (LIKE {SOURCE_SCHEMA}.death_cause) TABLESPACE pg_default;

INSERT INTO {SOURCE_NOK_SCHEMA}.death_cause
(
	With tmp AS(
		select distinct t1.eid, t2.cause_icd10
		from {SOURCE_SCHEMA}.death as t1
		left join {SOURCE_SCHEMA}.death_cause as t2 on t1.eid = t2.eid and t1.ins_index = t2.ins_index
		where t2.level = 1 
	), eid_muti_primary_dcause AS(
		select eid
		from tmp
		group by eid
		having count(*) >1
	)
	select t1.* 
	from {SOURCE_SCHEMA}.death_cause as t1
	left join {SOURCE_SCHEMA}.death as t2 on t1.eid = t2.eid and t1.ins_index = t2.ins_index	
	where t2.eid is null				--Eliminate death_cause without dod

	union

	select * from {SOURCE_SCHEMA}.death_cause
	where level <> 1					--Eliminate non-primanry death_cause 

	union 

	select t1.* 
	from {SOURCE_SCHEMA}.death_cause as t1 
	join eid_muti_primary_dcause as t2 on t1.eid = t2.eid
	where t1.level = 1 and t1.ins_index > 0					--Eliminate mutiple primanry death_cause with ins_index > 0
);

alter table {SOURCE_NOK_SCHEMA}.death_cause add constraint pk_death_cause_nok primary key (eid, ins_index, arr_index) USING INDEX TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.death_cause as t1 
using {SOURCE_NOK_SCHEMA}.death_cause as t2
WHERE t1.eid = t2.eid
and t1.ins_index = t2.ins_index
and t1.arr_index = t2.arr_index;