drop table if exists {SOURCE_SCHEMA}.temp_visit_detail CASCADE;

--------------------------------
-- TEMP_VISIT_DETAIL
--------------------------------
CREATE TABLE {SOURCE_SCHEMA}.temp_visit_detail 
(
	visit_detail_id bigint NOT NULL,
	visit_occurrence_id bigint NOT NULL,
	visit_type_concept_id bigint NOT NULL,
	person_id bigint NOT NULL,
	visit_start_date date NOT NULL,
	visit_detail_concept_id bigint NOT NULL,
	source_table varchar(20) NOT NULL,
	visit_detail_source_id bigint NOT NULL
);

with cte0 AS (
	SELECT max_id + 1 as start_id from {TARGET_SCHEMA_TO_LINK}._max_ids 
	WHERE lower(tbl_name) = 'max_of_all'
),
cte3a as (
	select 
		e_patid 							as person_id,
		treatmentstartdate					as visit_start_date,
		38004269::integer 					as visit_detail_concept_id,			--Radiation Oncology Clinic/Center
		'RTDS' 								as source_table,
		prescriptionid						as visit_detail_source_id
	from {SOURCE_SCHEMA}.rtds t1
	WHERE radiotherapydiagnosisicd is null OR upper(radiotherapydiagnosisicd) = 'C61' --only prostate cancer diagnoses in this case
),
cte3b as (
	select 
		e_patid 							as person_id,
		apptdate							as visit_start_date,
		38004269::integer 					as visit_detail_concept_id,			--Radiation Oncology Clinic/Center
		'RTDS' 								as source_table,
		prescriptionid						as visit_detail_source_id
	from {SOURCE_SCHEMA}.rtds t1
	WHERE radiotherapydiagnosisicd is null OR upper(radiotherapydiagnosisicd) = 'C61' --only prostate cancer diagnoses in this case
),
cte4a as (
	select 
		e_patid					as person_id,
		start_date_of_regimen	as visit_start_date,
		38004228::integer 		as visit_detail_concept_id,						--Infusion Therapy Clinic/Center
		'SACT' 					as source_table,
		pseudo_merged_tumour_id	as visit_detail_source_id
	FROM {SOURCE_SCHEMA}.sact
	WHERE primary_diagnosis is null OR upper(primary_diagnosis) = 'C61' --only prostate cancer diagnoses in this case
),
cte4b as (
	select 
		e_patid					as person_id,
		administration_date		as visit_start_date,
		38004228::integer 		as visit_detail_concept_id,						--Infusion Therapy Clinic/Center
		'SACT' 					as source_table,
		pseudo_merged_tumour_id	as visit_detail_source_id
	FROM {SOURCE_SCHEMA}.sact
	WHERE primary_diagnosis is null OR upper(primary_diagnosis) = 'C61' --only prostate cancer diagnoses in this case
),
cte5 as (
	select * from cte3a
	UNION DISTINCT
	select * from cte3b
),
cte6 as (
	select * from cte4a
	UNION DISTINCT
	select * from cte4b
),
cte7 as (
	select * from cte5
	UNION ALL
	select * from cte6
),
cte8 as (
	select person_id, visit_start_date, source_table,
	row_number() over (order by person_id, visit_start_date, source_table) as visit_occurrence_id
	from cte0, cte7
	group by person_id, visit_start_date, source_table
)
INSERT INTO {SOURCE_SCHEMA}.temp_visit_detail
SELECT 
row_number() over (order by t1.person_id, t1.visit_start_date, t1.source_table || ' - ' || t1.visit_detail_source_id) + cte0.start_id as visit_detail_id, 
t2.visit_occurrence_id + cte0.start_id as visit_occurrence_id, 
32879::integer as visit_type_concept_id,  --Registry
t1.*
FROM cte0, cte7 as t1
inner join cte8 as t2 on t1.person_id = t2.person_id and t1.visit_start_date = t2.visit_start_date 
and t1.source_table = t2.source_table;

alter table {SOURCE_SCHEMA}.temp_visit_detail add constraint pk_temp_visit_d primary key (visit_detail_id) USING INDEX TABLESPACE pg_default;
create index idx_temp_visit_1 on {SOURCE_SCHEMA}.temp_visit_detail (person_id, visit_start_date, source_table, visit_detail_source_id) TABLESPACE pg_default;
