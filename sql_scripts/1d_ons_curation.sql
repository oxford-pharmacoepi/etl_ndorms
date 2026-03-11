DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.ons_death CASCADE;

CREATE TABLE {SOURCE_NOK_SCHEMA}.ons_death (LIKE {SOURCE_SCHEMA}.ons_death) TABLESPACE pg_default;

INSERT INTO {SOURCE_NOK_SCHEMA}.ons_death
(
	select t1.*
	from {SOURCE_SCHEMA}.ons_death as t1
	left join {TARGET_SCHEMA_TO_LINK}.person as t3 on t3.person_id = t1.patid  
	WHERE t3.person_id is null			-- Eliminate dead patients not present in {target_to_link}.person
	OR t1.reg_date_of_death is null		-- Eliminate dead patients without date of death

	UNION DISTINCT 

	select t1.*
	from {SOURCE_SCHEMA}.ons_death as t1
	left join {LINKAGE_SCHEMA}.linkage_coverage as t2 on t2.data_source = 'ons_death' 
	where 	                                                                                                              
	t1.reg_date_of_death < t2.start or t1.reg_date_of_death > t2.end	-- Eliminate dead patients out of linkage_coverage period
);

alter table {SOURCE_NOK_SCHEMA}.ons_death add constraint pk_dpatient_nok primary key (id) USING INDEX TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.ons_death as t1 
using {SOURCE_NOK_SCHEMA}.ons_death as t2
WHERE t1.id = t2.id;

-- DUPLICATED RECORDS -- Added on 02/03/2026 as linked algorithm changed
with pat_multiple1 as (
	select patid 
	from (
		select patid 
		from {SOURCE_SCHEMA}.ons_death
		group by patid
		having count(*) > 1
	) as t1
),
pat_multiple2A as (	--MULTIPLE RECORDS WITH SAME reg_date_of_death and s_cod_code_1
	select t2.patid, t2.reg_date_of_death, t2.s_cod_code_1
	from pat_multiple1 as t1
	inner join {SOURCE_SCHEMA}.ons_death as t2 on t1.patid = t2.patid
	group by t2.patid, t2.reg_date_of_death, t2.s_cod_code_1
	having count(*) > 1
),
pat_multiple2B as (	--NUMBER THEM FOR EACH PATID
	select t2.id, t2.reg_date_of_death, t2.patid, t2.s_cod_code_1, row_number() over (partition by t2.patid order by t2.id)
	from pat_multiple2A as t1
	inner join {SOURCE_SCHEMA}.ons_death as t2 on t1.patid = t2.patid
	WHERE t1.reg_date_of_death = t2.reg_date_of_death 
	AND t1.s_cod_code_1 = t2.s_cod_code_1
),
pat_multiple2 as ( --DELETE THOSE DUPLICATES AFTER THE FIRST
	select id
	from pat_multiple2B
	where row_number > 1
),
pat_multiple3A as (	--MULTIPLE RECORDS WITH SAME reg_date_of_death ONLY
	select t2.patid, t2.reg_date_of_death
	from pat_multiple1 as t1
	inner join {SOURCE_SCHEMA}.ons_death as t2 on t1.patid = t2.patid
	left join pat_multiple2 as t3 on t2.id = t3.id
	WHERE t3.id is null
	group by t2.patid, t2.reg_date_of_death
	having count(*) > 1
),
pat_multiple3B as (	--NUMBER THEM FOR EACH PATID
	select t2.id, t2.reg_date_of_death, t2.patid, row_number() over (partition by t2.patid order by t2.id)
	from pat_multiple3A as t1
	inner join {SOURCE_SCHEMA}.ons_death as t2 on t1.patid = t2.patid
	left join pat_multiple2 as t3 on t2.id = t3.id
	WHERE t1.reg_date_of_death = t2.reg_date_of_death 
	AND t3.id is null
),
pat_multiple3 as (	--DELETE THOSE DUPLICATES AFTER THE FIRST
	select id
	from pat_multiple3B
	where row_number > 1
),
pat_multiple4A as (			--IDENTIFY RESIDUAL DUPLICATES
	select t2.patid
	from pat_multiple1 as t1
	inner join {SOURCE_SCHEMA}.ons_death as t2 on t2.patid = t1.patid
	left join pat_multiple2 as t3 on t2.id = t3.id
	left join pat_multiple3 as t4 on t2.id = t4.id
	WHERE t3.id is null
	AND t4.id is null
	group by t2.patid
	having count(*) > 1
),
pat_multiple4B as (	--NUMBER THEM FOR EACH PATID
	select t2.id, t2.reg_date_of_death, t2.s_cod_code_1, t2.patid, row_number() over (partition by t2.patid order by t2.s_cod_code_1, t2.reg_date_of_death)
	from pat_multiple4A as t1
	inner join {SOURCE_SCHEMA}.ons_death as t2 on t1.patid = t2.patid
	left join pat_multiple2 as t3 on t2.id = t3.id
	left join pat_multiple3 as t4 on t2.id = t4.id
	WHERE t3.id is null
	AND t4.id is null
),
pat_multiple4C as (	--TO DELETE THOSE PATIENTS WITH DIFFERENT CAUSES or DEATH DATE WITH A GAP OF MORE THAN 30 DAYS
	select distinct t1.*
	from pat_multiple4B as t1
	inner join pat_multiple4B as t2 on t1.patid = t2.patid
	WHERE t1.s_cod_code_1 <> t2.s_cod_code_1
	OR ABS(t1.reg_date_of_death - t2.reg_date_of_death) > 30
),
pat_multiple4D as (	--IDENTIFY RESIDUAL DUPLICATES
	select distinct t1.id, t1.row_number
	from pat_multiple4B as t1
	left join pat_multiple4C as t2 on t1.patid = t2.patid
	WHERE t2.id is null
),
pat_multiple4 as (	--DELETE THOSE DUPLICATES AFTER THE FIRST
	select id
	from pat_multiple4D
	where row_number > 1
)
INSERT INTO {SOURCE_NOK_SCHEMA}.ons_death(
	select t1.* 
	from {SOURCE_SCHEMA}.ons_death as t1
	inner join pat_multiple2 as t2 on t1.id = t2.id
	
	UNION DISTINCT
	
	select t1.* 
	from {SOURCE_SCHEMA}.ons_death as t1
	inner join pat_multiple3 as t2 on t1.id = t2.id

	UNION DISTINCT 

	select t1.*
	from {SOURCE_SCHEMA}.ons_death as t1
	inner join pat_multiple4C as t2 on t1.id = t2.id

	UNION DISTINCT 
	
	select t1.*
	from {SOURCE_SCHEMA}.ons_death as t1
	inner join pat_multiple4 as t2 on t1.id = t2.id
);

DELETE FROM {SOURCE_SCHEMA}.ons_death as t1 
using {SOURCE_NOK_SCHEMA}.ons_death as t2
WHERE t1.id = t2.id;

create unique index idx_ons_patient on {SOURCE_SCHEMA}.ons_death(patid) TABLESPACE pg_default;
