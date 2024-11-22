drop table if exists {SOURCE_SCHEMA}.temp_visit_detail CASCADE;

--------------------------------
-- TEMP_VISIT_DETAIL
--------------------------------
CREATE TABLE {SOURCE_SCHEMA}.temp_visit_detail 
(
	visit_detail_id bigint NOT NULL,
	visit_occurrence_id bigint NOT NULL,
	person_id bigint NOT NULL,
	visit_detail_source_id bigint NOT NULL,
	visit_detail_start_date date NOT NULL,
	visit_detail_end_date date NOT NULL,
	source_table varchar(20) NULL
);

with cte0 AS (
	SELECT max_id + 1 as start_id from {TARGET_SCHEMA_TO_LINK}._max_ids 
	WHERE lower(tbl_name) = 'max_of_all'
),
cte3 as (
	select 
		e_patid 			as person_id,
		e_cr_id 			as visit_detail_source_id,
		diagnosisdatebest 	as visit_detail_start_date,
		diagnosisdatebest 	as visit_detail_end_date,
		'Tumour' 			as source_table
	from {SOURCE_SCHEMA}.tumour t1
),
cte4 as (
	select 
		e_patid			as person_id,
		treatment_id 	as visit_detail_source_id,
		eventdate		as visit_detail_start_date,
		eventdate		as visit_detail_end_date,
		'Treatment' 	as source_table
	FROM {SOURCE_SCHEMA}.treatment
	WHERE eventdate is not null
),
cte5 as (
	select * 
	from cte3
	UNION ALL
	select * 
	from cte4
),
cte6 as (
	select person_id, visit_detail_start_date,
	row_number() over (order by person_id, visit_detail_start_date) as visit_occurrence_id
	from cte0, cte5
	group by person_id, visit_detail_start_date
)
INSERT INTO {SOURCE_SCHEMA}.temp_visit_detail
SELECT 
row_number() over (order by t1.person_id, t1.visit_detail_start_date, t1.visit_detail_source_id) + cte0.start_id as visit_detail_id, 
t2.visit_occurrence_id + cte0.start_id as visit_occurrence_id, t1.*
FROM cte0, cte5 as t1
inner join cte6 as t2 on t1.person_id = t2.person_id and t1.visit_detail_start_date = t2.visit_detail_start_date;


alter table {SOURCE_SCHEMA}.temp_visit_detail add constraint pk_temp_visit_d primary key (visit_detail_id);
create index idx_temp_visit_1 on {SOURCE_SCHEMA}.temp_visit_detail (person_id, visit_detail_source_id, visit_detail_start_date);

