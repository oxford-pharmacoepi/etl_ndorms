--------------------------------
-- TEMP_VISIT_DETAIL
--------------------------------
drop table if exists {SOURCE_SCHEMA}.temp_visit_detail CASCADE;

CREATE TABLE {SOURCE_SCHEMA}.temp_visit_detail
(
	visit_detail_id bigint NOT NULL,
	visit_occurrence_id bigint NOT NULL,
	person_id bigint NOT NULL,
	visit_source_value varchar(50) NOT NULL,
	visit_start_date date NOT NULL,
	visit_end_date date NOT NULL,
	visit_detail_start_date date NOT NULL,
	visit_detail_end_date date NOT NULL,
	visit_detail_source_value varchar(50) NOT NULL
);

with cte0 AS (
	select * from 
	(SELECT max_id as start_id_vo
	from {TARGET_SCHEMA_TO_LINK}._max_ids 
	WHERE lower(tbl_name) = 'visit_occurrence') as t1,
	(SELECT max_id as start_id_vd
	from {TARGET_SCHEMA_TO_LINK}._max_ids 
	WHERE lower(tbl_name) = 'visit_detail') as t2
),
cte1 AS ( -- FROM HESIN
	select 
		eid as person_id,
		ins_index::varchar(50) as visit_detail_source_value,
		COALESCE(epistart, admidate) as visit_detail_start_date,
		COALESCE(epiend, disdate, epistart, admidate) as visit_detail_end_date,
		spell_index::varchar(50) as visit_source_value
	from {SOURCE_SCHEMA}.hesin
),
cte2 AS (
	SELECT t1.*
	FROM cte1 as t1
	inner join {TARGET_SCHEMA}.observation_period as t2 on t1.person_id = t2.person_id
	WHERE t1.visit_detail_start_date >= t2.observation_period_start_date
	AND t1.visit_detail_end_date <= t2.observation_period_end_date + interval '14 day' -- to avoid removing episodes crossing end of life
),
cte3 AS (
	select person_id, visit_source_value,
	MIN(visit_detail_start_date) as visit_start_date,
	MAX(visit_detail_end_date) as visit_end_date 
	from cte2
	group by person_id, visit_source_value
),
cte5 AS (
	select t1.person_id, t1.visit_source_value, t1.visit_start_date, 
	t1.visit_end_date,
	row_number() over (order by t1.person_id, t1.visit_start_date, t1.visit_end_date, t1.visit_source_value) as visit_occurrence_id
	from cte3 as t1
)
insert into {SOURCE_SCHEMA}.temp_visit_detail
SELECT 
row_number() over (order by t2.visit_occurrence_id, t1.visit_detail_start_date, t1.visit_detail_end_date, t1.visit_detail_source_value) + cte0.start_id_vd as visit_detail_id, 
t2.visit_occurrence_id + cte0.start_id_vo as visit_occurrence_id, 
t2.person_id, t2.visit_source_value, t2.visit_start_date, t2.visit_end_date, 
t1.visit_detail_start_date, t1.visit_detail_end_date, t1.visit_detail_source_value
FROM cte0, cte2 as t1
inner join cte5 as t2 on t1.person_id = t2.person_id and t1.visit_source_value = t2.visit_source_value
order by visit_detail_id;


alter table {SOURCE_SCHEMA}.temp_visit_detail add constraint pk_temp_visit_d primary key (visit_occurrence_id, visit_detail_id);
create index idx_temp_visit_1 on {SOURCE_SCHEMA}.temp_visit_detail (person_id, visit_source_value, visit_detail_source_value); 
