--------------------------------
-- temp_gp_scripts_1
--------------------------------
drop table if exists {SOURCE_SCHEMA}.temp_gp_scripts_1 CASCADE;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.temp_gp_scripts_1 (
	id					bigint,
	eid					bigint,	
	data_provider		int,
	issue_date			date,
	read_2				varchar(7),
	--bnf_code			varchar(8),
	dmd_code			varchar(20),
	drug_name			varchar(600),
	quantity			varchar(250),	
	qty					numeric,
	supply				varchar(200),
	supply_qty			numeric,
	supply_unit			varchar(100),
	packsize			numeric
)TABLESPACE pg_default;

ALTER TABLE {SOURCE_SCHEMA}.temp_gp_scripts_1 SET (autovacuum_enabled = False);

-- CASE 1: (regexp_match(lower(quantity), 'supply'))[1] is not null
insert into {SOURCE_SCHEMA}.temp_gp_scripts_1
select 	
		id,
		eid,
		data_provider,
		issue_date,
		read_2,
		CASE WHEN dmd_code = '0' THEN NULL ELSE dmd_code END as dmd_code,
		drug_name, 
		quantity,
		(regexp_match(quantity, '\d+[.]\d+|\d+'))[1]::numeric  as qty,
		(regexp_match(lower(quantity), 'supply for\D+\d+\D+|\d+\D+supply'))[1] as supply,	
		(regexp_match((regexp_match(lower(quantity), 'supply for\D+\d+|\d+\D+supply'))[1], '\d+'))[1]::numeric as supply_qty,	
		CASE
			WHEN (regexp_match(lower(quantity), 'supply for'))[1] is not null THEN (regexp_match(lower((regexp_match(lower(quantity), 'supply for\D+\d+\D+'))[1]), '[^supply for][^\d\s]+'))[1] 
			ELSE (regexp_match(lower((regexp_match(lower(quantity), '\d+\D+supply'))[1]), '[^\d\s]+[^supply]'))[1] 
		END as supply_unit,
		0
from {SOURCE_SCHEMA}.gp_scripts
where (regexp_match(lower(quantity), 'supply'))[1] is not null;

-- CASE 2: (regexp_match(lower(quantity), 'day pack'))[1] is not null
-- 'day pack' and 'supply' are mutually exclusive
insert into {SOURCE_SCHEMA}.temp_gp_scripts_1
select 		
		id,
		eid,
		data_provider,
		issue_date,
		read_2,
		CASE WHEN dmd_code = '0' THEN NULL ELSE dmd_code END as dmd_code,
		drug_name, 
		quantity,
		(regexp_match(quantity, '\d+[.]\d+|\d+'))[1]::numeric  as qty,	
		(regexp_match(lower(quantity), '\d+\D+day'))[1] as supply,
		(regexp_match((regexp_match(lower(quantity), '\d+\D+day'))[1], '\d+'))[1]::numeric as supply_qty,	
		(regexp_match((regexp_match(lower(quantity), '\d+\D+day'))[1], '\D+'))[1] as supply_unit,
		(regexp_match((regexp_match(lower(quantity), '\d+ day pack'))[1], '\d+[.]\d+|\d+'))[1]::numeric as packsize
from {SOURCE_SCHEMA}.gp_scripts
where (regexp_match(lower(quantity), 'day pack'))[1] is not null;

-- CASE 3: (regexp_match(lower(quantity), 'supply'))[1] is null
-- 'day pack' and 'supply' are mutually exclusive
insert into {SOURCE_SCHEMA}.temp_gp_scripts_1
select 		
		id,
		eid,
		data_provider,
		issue_date,
		read_2,
		CASE WHEN dmd_code = '0' THEN NULL ELSE dmd_code END as dmd_code,
		drug_name, 
		quantity,
		(regexp_match(quantity, '\d+[.]\d+|\d+'))[1]::numeric  as qty,	
		(regexp_match(lower(quantity), '\d+\D+day|\d+\D+week|\d+\D+month'))[1] as supply,
		CASE WHEN (regexp_match(lower(quantity), 'weekly|every'))[1] is null THEN (regexp_match((regexp_match(lower(quantity), '\d+\D+day|\d+\D+week|\d+\D+month'))[1], '\d+'))[1]::numeric END as supply_qty,	
		CASE WHEN (regexp_match(lower(quantity), 'weekly|every'))[1] is null THEN (regexp_match((regexp_match(lower(quantity), '\d+\D+day|\d+\D+week|\d+\D+month'))[1], '\D+'))[1] END as supply_unit,
		(regexp_match((regexp_match(lower(quantity), '\d+[.]\d+\D+tab|\d+\D+tab|\d+[.]\d+\D+caps|\d+\D+caps'))[1], '\d+[.]\d+|\d+'))[1]::numeric as packsize
from {SOURCE_SCHEMA}.gp_scripts
where (regexp_match(lower(quantity), 'supply|day pack'))[1] is null;

alter table {SOURCE_SCHEMA}.temp_gp_scripts_1 add constraint pk_temp_gp_scripts_1 primary key (id) USING INDEX TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_temp_gp_scripts_1_1 ON {SOURCE_SCHEMA}.temp_gp_scripts_1 (drug_name, qty, packsize) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_temp_gp_scripts_1_2 ON {SOURCE_SCHEMA}.temp_gp_scripts_1 (dmd_code, qty, packsize) TABLESPACE pg_default;

VACUUM (ANALYZE) {SOURCE_SCHEMA}.temp_gp_scripts_1;
ALTER TABLE {SOURCE_SCHEMA}.temp_gp_scripts_1 SET (autovacuum_enabled = True);

--------------------------------
-- temp_gp_scripts_2
--------------------------------
drop table if exists {SOURCE_SCHEMA}.temp_gp_scripts_2 CASCADE;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.temp_gp_scripts_2 (
	id					bigint,
	eid					bigint,	
	data_provider		int,
	issue_date			date,
	read_2				varchar(7),
	--bnf_code			varchar(8),
	dmd_code			varchar(20),
	drug_name			varchar(600),
	quantity			varchar(250),	
	qty					numeric,
	supply				varchar(200),
	supply_qty			numeric,
	supply_unit			varchar(100),
	packsize			numeric,
	daysupply			int
)TABLESPACE pg_default;

ALTER TABLE {SOURCE_SCHEMA}.temp_gp_scripts_2 SET (autovacuum_enabled = False);

-- CASE 1
-- days supply exists in source data: supply_qty is not null 
-- no drug_name and dmd_code to link to gold: drug_name is null and dmd_code is null
insert into {SOURCE_SCHEMA}.temp_gp_scripts_2
select 
	id, 
	eid,
	data_provider, 
	issue_date, 
	read_2, 
	dmd_code, 
	drug_name, 
	quantity,
	CASE
		WHEN packsize = 0 THEN qty
		WHEN qty <> packsize THEN qty*packsize
		ELSE qty
	END,
	supply,
	supply_qty,
	supply_unit, 
	packsize,
	CASE
		WHEN (regexp_match(lower(quantity), 'day'))[1] is not null THEN supply_qty
		WHEN (regexp_match(lower(quantity), 'week'))[1] is not null THEN supply_qty * 7
		WHEN (regexp_match(lower(quantity), 'month'))[1] is not null THEN supply_qty * 28
		ELSE supply_qty	
	END as daysupply
from {SOURCE_SCHEMA}.temp_gp_scripts_1 as t1
where supply_qty is not null 
or (drug_name is null and dmd_code is null);

-- CASE 2
-- no days supply in source data: t1.supply_qty is null
-- link to gold by drug_name: dmd_code is null
WITH daysupply_decodes as(
	select distinct t1.id, t2.dmdcode, t2.productname, t1.qty, t1.numpacks, t1.numdays
	from {SOURCE_SCHEMA}.gold_daysupply_decodes as t1
	join {SOURCE_SCHEMA}.gold_product as t2 on t1.prodcode = t2.prodcode
), daysupply_modes as(
	select distinct t1.id, t2.dmdcode, t2.productname, t1.numdays
	from {SOURCE_SCHEMA}.gold_daysupply_modes as t1
	join {SOURCE_SCHEMA}.gold_product as t2 on t1.prodcode = t2.prodcode
), cte0 as(
	select UPPER(productname) as productname, qty, numpacks
	from daysupply_decodes
	group by UPPER(productname), qty, numpacks
	having count(*) = 1  
), cte1 as(
	select t1.*
	from daysupply_decodes as t1
	join cte0 as t2 on UPPER(t1.productname) = t2.productname and t1.qty = t2.qty and t1.numpacks = t2.numpacks
), cte2 as(
	select UPPER(productname) as productname
	from daysupply_modes
	group by UPPER(productname)
	having count(*) = 1  
), cte3 as(
	select t1.*
	from daysupply_modes as t1
	join cte2 as t2 on UPPER(t1.productname) = t2.productname
)
insert into {SOURCE_SCHEMA}.temp_gp_scripts_2
select 
t1.id, 
t1.eid,
t1.data_provider, 
t1.issue_date, 
t1.read_2, 
t1.dmd_code, 
t1.drug_name, 
t1.quantity,
CASE
	WHEN t1.packsize = 0 THEN t1.qty
	WHEN t1.qty <> t1.packsize THEN t1.qty*t1.packsize
	ELSE t1.qty
END as qty,
NULL as supply,
NULL::integer as supply_qty,
NULL as supply_unit, 
t1.packsize,
COALESCE(t2.numdays, t3.numdays) as daysupply
from {SOURCE_SCHEMA}.temp_gp_scripts_1 as t1
left join cte1 as t2 on UPPER(t1.drug_name) = UPPER(t2.productname) and t1.qty= t2.qty and COALESCE(t1.packsize, 0) = t2.numpacks
left join cte3 as t3 on UPPER(t1.drug_name) = UPPER(t3.productname) 
where t1.supply_qty is null 
and drug_name is not null
and dmd_code is null;

-- CASE 3
-- no days supply in source data: t1.supply_qty is null
-- link to gold by dmd_code: dmd_code is null: dmd_code is not null;
WITH daysupply_decodes as(
	select distinct t1.id, t2.dmdcode, t2.productname, t1.qty, t1.numpacks, t1.numdays
	from {SOURCE_SCHEMA}.gold_daysupply_decodes as t1
	join {SOURCE_SCHEMA}.gold_product as t2 on t1.prodcode = t2.prodcode
), daysupply_modes as(
	select distinct t1.id, t2.dmdcode, t2.productname, t1.numdays
	from {SOURCE_SCHEMA}.gold_daysupply_modes as t1
	join {SOURCE_SCHEMA}.gold_product as t2 on t1.prodcode = t2.prodcode
), cte0 as(
	select dmdcode, qty, numpacks
	from daysupply_decodes as t1
	group by dmdcode, qty, numpacks
	having count(*) = 1  
), cte1 as(
	select t1.* 
	from daysupply_decodes as t1
	join cte0 as t2 on t1.dmdcode = t2.dmdcode and t1.qty = t2.qty and t1.numpacks = t2.numpacks
), cte2 as(
	select dmdcode
	from daysupply_modes
	group by dmdcode
	having count(*) = 1  
), cte3 as(
	select t1.* 
	from daysupply_modes as t1
	join cte2 as t2 on t1.dmdcode = t2.dmdcode
), cte4 as(
	select UPPER(productname) as productname, qty, numpacks
	from daysupply_decodes
	group by UPPER(productname), qty, numpacks
	having count(*) = 1  
), cte5 as(
	select t1.*
	from daysupply_decodes as t1
	join cte4 as t2 on UPPER(t1.productname) = t2.productname and t1.qty = t2.qty and t1.numpacks = t2.numpacks
), cte6 as(
	select UPPER(productname) as productname
	from daysupply_modes
	group by UPPER(productname)
	having count(*) = 1  
), cte7 as(
	select t1.*
	from daysupply_modes as t1
	join cte6 as t2 on UPPER(t1.productname) = t2.productname
)
insert into {SOURCE_SCHEMA}.temp_gp_scripts_2
select 
	t1.id, 
	t1.eid,
	t1.data_provider, 
	t1.issue_date, 
	t1.read_2, 
	t1.dmd_code, 
	t1.drug_name, 
	t1.quantity,
	CASE
		WHEN t1.packsize = 0 THEN t1.qty
		WHEN t1.qty <> t1.packsize THEN t1.qty* t1.packsize
		ELSE t1.qty
	END as qty,
	NULL as supply,
	NULL::integer as supply_qty,
	NULL as supply_unit, 
	t1.packsize,
	COALESCE(t2.numdays, t3.numdays, t4.numdays, t5.numdays) as daysupply
from {SOURCE_SCHEMA}.temp_gp_scripts_1 as t1
left join cte1 as t2 on t1.dmd_code = t2.dmdcode and t1.qty= t2.qty and COALESCE(t1.packsize, 0) = t2.numpacks
left join cte3 as t3 on t1.dmd_code = t3.dmdcode
left join cte5 as t4 on UPPER(t1.drug_name) = UPPER(t4.productname) and t1.qty= t4.qty and COALESCE(t1.packsize, 0) = t4.numpacks
left join cte7 as t5 on UPPER(t1.drug_name) = UPPER(t5.productname) 
where t1.supply_qty is null 
and dmd_code is not null;


alter table {SOURCE_SCHEMA}.temp_gp_scripts_2 add constraint pk_temp_gp_scripts_2 primary key (id) USING INDEX TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_temp_gp_scripts_2_1 ON {SOURCE_SCHEMA}.temp_gp_scripts_2 (eid) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_temp_gp_scripts_2_2 ON {SOURCE_SCHEMA}.temp_gp_scripts_2 (read_2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_temp_gp_scripts_2_3 ON {SOURCE_SCHEMA}.temp_gp_scripts_2 (drug_name) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_temp_gp_scripts_2_4 ON {SOURCE_SCHEMA}.temp_gp_scripts_2 (eid, data_provider, issue_date) TABLESPACE pg_default;

VACUUM (ANALYZE) {SOURCE_SCHEMA}.temp_gp_scripts_2;
ALTER TABLE {SOURCE_SCHEMA}.temp_gp_scripts_2 SET (autovacuum_enabled = True);

--------------------------------
-- TEMP_VISIT_DETAIL
--------------------------------
drop table if exists {SOURCE_SCHEMA}.temp_visit_detail CASCADE;

CREATE TABLE {SOURCE_SCHEMA}.temp_visit_detail 
(
	visit_detail_id bigint NOT NULL,
	person_id bigint NOT NULL,
	visit_detail_start_date date NOT NULL,
	data_provider varchar(16) NOT NULL,
	source_table varchar(20) NOT NULL
)TABLESPACE pg_default;

ALTER TABLE {SOURCE_SCHEMA}.temp_visit_detail SET (autovacuum_enabled = False);

With cte0 AS(
	select 
		eid,
		data_provider, 
		reg_date as event_dt,
		'Registration' as source_table
	from {SOURCE_SCHEMA}.gp_registrations
	union
	select  
		eid, 
		data_provider, 
		event_dt as event_dt,
		'Clinical' as source_table
	from {SOURCE_SCHEMA}.gp_clinical
	union
	select  
		eid, 
		data_provider, 
		issue_date as event_dt,
		'Drug Prescription' as source_table
	from {SOURCE_SCHEMA}.gp_scripts 
), cte1 as(
	select distinct		
		t1.eid,
		t1.event_dt,
		lkup.description as data_provider,
		source_table
	from cte0 as t1
	join {SOURCE_SCHEMA}.coding626 as lkup on lkup.code = t1.data_provider
	join {TARGET_SCHEMA}.observation_period as t2 on t1.eid = t2.person_id
	where t1.event_dt >= t2.observation_period_start_date and t1.event_dt <= t2.observation_period_end_date
), cte2 as (
	SELECT max_id as start_id from {TARGET_SCHEMA_TO_LINK}._max_ids 
	WHERE lower(tbl_name) = 'visit_detail'
)
insert into {SOURCE_SCHEMA}.temp_visit_detail
select 
	ROW_NUMBER () OVER ( ORDER BY eid, event_dt, data_provider, source_table) + cte2.start_id as visit_detail_id,
	cte1.*
from cte1, cte2;

alter table {SOURCE_SCHEMA}.temp_visit_detail add constraint pk_temp_visit_d primary key (visit_detail_id) USING INDEX TABLESPACE pg_default;
create index idx_temp_visit_1 on {SOURCE_SCHEMA}.temp_visit_detail (person_id, visit_detail_start_date, data_provider, source_table) TABLESPACE pg_default; 

VACUUM (ANALYZE) {SOURCE_SCHEMA}.temp_visit_detail;
ALTER TABLE {SOURCE_SCHEMA}.temp_visit_detail SET (autovacuum_enabled = True);