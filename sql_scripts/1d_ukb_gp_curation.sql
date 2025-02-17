DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.gp_clinical CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.gp_scripts CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.gp_registrations CASCADE;

DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.baseline CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.death CASCADE;

CREATE TABLE {SOURCE_NOK_SCHEMA}.gp_clinical (LIKE {SOURCE_SCHEMA}.gp_clinical) TABLESPACE pg_default;
CREATE TABLE {SOURCE_NOK_SCHEMA}.gp_scripts (LIKE {SOURCE_SCHEMA}.gp_scripts) TABLESPACE pg_default;
CREATE TABLE {SOURCE_NOK_SCHEMA}.gp_registrations (LIKE {SOURCE_SCHEMA}.gp_registrations) TABLESPACE pg_default;

CREATE TABLE {SOURCE_NOK_SCHEMA}.baseline (LIKE {SOURCE_SCHEMA}.baseline) TABLESPACE pg_default;
CREATE TABLE {SOURCE_NOK_SCHEMA}.death (LIKE {SOURCE_SCHEMA}.death) TABLESPACE pg_default;

--------------------------------
-- gp_clinical
--------------------------------
INSERT INTO {SOURCE_NOK_SCHEMA}.gp_clinical
(
	select t1.* from {SOURCE_SCHEMA}.gp_clinical as t1
	join {SOURCE_SCHEMA}._patid_deleted as t2 on t1.eid = t2.patid	--Remove withdrawal patients

	union

	select * from {SOURCE_SCHEMA}.gp_clinical
	where read_2 = '.....' or read_3 = '.....' or read_2 = '@A2..'

	union

	select * from {SOURCE_SCHEMA}.gp_clinical
	where read_2 = '22A..'
	and COALESCE(value1, value3) = '^'		-- read_2 = 22A.. value1 = ^

	union 
	
	select * from {SOURCE_SCHEMA}.gp_clinical
	where event_dt in ('1901-01-01', '1902-02-02', '1903-03-03', '1909-09-09', '2037-07-07') -- https://biobank.ndph.ox.ac.uk/ukb/coding.cgi?id=819
	
);

alter table {SOURCE_NOK_SCHEMA}.gp_clinical add constraint pk_gp_clinical_nok primary key (id) USING INDEX TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.gp_clinical as t1 
using {SOURCE_NOK_SCHEMA}.gp_clinical as t2
WHERE t1.id = t2.id;

--------------------------------
-- gp_scripts
--------------------------------
INSERT INTO {SOURCE_NOK_SCHEMA}.gp_scripts
(
	select t1.* from {SOURCE_SCHEMA}.gp_scripts as t1
	join {SOURCE_SCHEMA}._patid_deleted as t2 on t1.eid = t2.patid	--Remove withdrawal patients

	union
	
	select * from {SOURCE_SCHEMA}.gp_scripts
	where read_2 is null 
	and drug_name is null
	and (dmd_code is null or dmd_code = '0')  --Remove empty drug
	
	union
	
	select * from {SOURCE_SCHEMA}.gp_scripts
	where issue_date in ('1901-01-01', '1902-02-02', '1903-03-03', '1909-09-09', '2037-07-07')	-- https://biobank.ndph.ox.ac.uk/ukb/coding.cgi?id=819
	
);

alter table {SOURCE_NOK_SCHEMA}.gp_scripts add constraint pk_gp_scripts_nok primary key (id) USING INDEX TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.gp_scripts as t1 
using {SOURCE_NOK_SCHEMA}.gp_scripts as t2
WHERE t1.id = t2.id;


--------------------------------
-- gp_registrations
--------------------------------
--Remove withdrawal patients
insert into {SOURCE_NOK_SCHEMA}.gp_registrations
select t1.* from {SOURCE_SCHEMA}.gp_registrations as t1
join {SOURCE_SCHEMA}._patid_deleted as t2 on t1.eid = t2.patid;

DELETE FROM {SOURCE_SCHEMA}.gp_registrations  
where eid in(
	select patid from {SOURCE_SCHEMA}._patid_deleted 
);

-- https://biobank.ndph.ox.ac.uk/ukb/coding.cgi?id=819
INSERT INTO {SOURCE_NOK_SCHEMA}.gp_registrations
select * from source_ukb_gp.gp_registrations
where reg_date in ('1901-01-01', '1902-02-02', '1903-03-03', '1909-09-09', '2037-07-07');

DELETE FROM {SOURCE_SCHEMA}.gp_registrations  
where reg_date in ('1901-01-01', '1902-02-02', '1903-03-03', '1909-09-09', '2037-07-07');

--------------------------------
-- baseline
--------------------------------
With cte AS(
	select distinct eid 
	from {SOURCE_SCHEMA}.gp_registrations 
	union 
	select distinct eid 
	from {SOURCE_SCHEMA}.gp_clinical 
	union 
	select distinct eid 
	from {SOURCE_SCHEMA}.gp_scripts 
)
INSERT INTO {SOURCE_NOK_SCHEMA}.baseline
select t1.*
from {SOURCE_SCHEMA}.baseline as t1
left join cte as t2 on t1.eid = t2.eid
where t2.eid is null;

alter table {SOURCE_NOK_SCHEMA}.baseline add constraint pk_baseline_nok primary key (eid) USING INDEX TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.baseline as t1 
using {SOURCE_NOK_SCHEMA}.baseline as t2
WHERE t1.eid = t2.eid;


--------------------------------
-- death
--------------------------------
INSERT INTO {SOURCE_NOK_SCHEMA}.death
select t1.*
from {SOURCE_SCHEMA}.death as t1
join {SOURCE_NOK_SCHEMA}.baseline as t2 on t1.eid = t2.eid;		--Eliminate death with no gp records

alter table {SOURCE_NOK_SCHEMA}.death add constraint pk_death primary key (eid, ins_index) USING INDEX TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.death as t1 
using {SOURCE_NOK_SCHEMA}.death as t2
WHERE t1.eid = t2.eid
and t1.ins_index = t2.ins_index;