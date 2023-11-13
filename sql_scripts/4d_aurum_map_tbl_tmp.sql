--------------------------------
-- TEMP_DRUG_CONCEPT_MAP
--------------------------------
drop table if exists {SOURCE_SCHEMA}.temp_drug_concept_map CASCADE;

create table if not exists {SOURCE_SCHEMA}.temp_drug_concept_map as
select d.prodcodeid,
	d.termfromemis,
	d.dmdid,
	st1.target_concept_id as dmd_source_concept_id
from {SOURCE_SCHEMA}.productdictionary d
left join {TARGET_SCHEMA}.source_to_source_vocab_map st1 on d.dmdid::varchar = st1.source_code and st1.source_vocabulary_id = 'dm+d';

alter table {SOURCE_SCHEMA}.temp_drug_concept_map add constraint pk_temp_drug_concept_map primary key (prodcodeid);

--------------------------------
-- TEMP_CONCEPT_MAP
--------------------------------
drop table if exists {SOURCE_SCHEMA}.temp_concept_map CASCADE;

create table if not exists {SOURCE_SCHEMA}.temp_concept_map as
with cte1 as (
	SELECT source_code, target_concept_id as Read_source_concept_id
		FROM {TARGET_SCHEMA}.source_to_source_vocab_map
		WHERE source_vocabulary_id = 'Read'
	),
	cte2 as (
	SELECT source_code, target_concept_id as SNOMED_source_concept_id
		FROM {TARGET_SCHEMA}.source_to_source_vocab_map
		WHERE source_vocabulary_id = 'SNOMED'
	)
SELECT m.medcodeid,
	m.term,
	m.cleansedreadcode,
	m.snomedctconceptid,
	cte1.Read_source_concept_id,
	cte2.SNOMED_source_concept_id
from {SOURCE_SCHEMA}.medicaldictionary m
left join cte1 on m.cleansedreadcode = cte1.source_code
left join cte2 on m.snomedctconceptid = cte2.source_code;

alter table {SOURCE_SCHEMA}.temp_concept_map add constraint pk_temp_concept_map primary key (medcodeid);

--------------------------------
-- TEMP_VISIT_DETAIL
--------------------------------
drop table if exists {SOURCE_SCHEMA}.temp_visit_detail CASCADE;

CREATE TABLE {SOURCE_SCHEMA}.temp_visit_detail 
(
	visit_detail_id bigint NOT NULL,
	visit_detail_source_id bigint NOT NULL,
	person_id bigint NOT NULL,
	visit_detail_start_date date NOT NULL,
	visit_detail_end_date date NOT NULL,
	provider_id bigint NULL,
	care_site_id bigint NULL,
	visit_detail_parent_id bigint NULL,
	source_table varchar(20) NULL
);

WITH cte3 as (
	select o.obsid as visit_detail_source_id,
		o.patid as person_id,
		case
			when c.consdate is NULL then o.obsdate
			else c.consdate
			end as visit_detail_start_date,
		case
			when c.consdate is NULL then o.obsdate
			else c.consdate
			end as visit_detail_end_date,
		c.staffid as provider_id,
		o.pracid as care_site_id,
		o.parentobsid as visit_detail_parent_id,
		'Observation' as source_table
	from {SOURCE_SCHEMA}.observation o
	left join {SOURCE_SCHEMA}.consultation c on o.consid = c.consid
--	where c.consdate is not null or o.obsdate is not null -- not necessary as obsdate is always not NULL, filtered in check_source_data.sql
),
cte4 as (
	select c.consid	as visit_detail_source_id,
		c.patid		as person_id,
		c.consdate	as visit_detail_start_date,
		c.consdate	as visit_detail_end_date,
		c.staffid	as provider_id,
		c.pracid	as care_site_id,
		NULL::bigint	as visit_detail_parent_id,
		'Consultation' as source_table
	from {SOURCE_SCHEMA}.consultation c
	where c.consdate is not null
),
cte5 as (
	select * 
	from cte3
	UNION
	select * 
	from cte4
)
INSERT INTO {SOURCE_SCHEMA}.temp_visit_detail
SELECT row_number() over (order by visit_detail_source_id) as visit_detail_id, *
FROM cte5;


alter table {SOURCE_SCHEMA}.temp_visit_detail add constraint pk_temp_visit_d primary key (visit_detail_id); --added 31/10/2022
create index idx_temp_visit_det1 on {SOURCE_SCHEMA}.temp_visit_detail (visit_detail_source_id, source_table); --modified 27/10/2022
create index idx_temp_visit_det2 on {SOURCE_SCHEMA}.temp_visit_detail (person_id, visit_detail_start_date, care_site_id); 
