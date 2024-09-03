--------------------------------
-- TEMP_VISIT_DETAIL
--------------------------------
drop table if exists {SOURCE_SCHEMA}.temp_visit_detail CASCADE;

CREATE TABLE {SOURCE_SCHEMA}.temp_visit_detail 
(
	visit_detail_id bigint NOT NULL,
	person_id bigint NOT NULL,
	visit_detail_start_date date NOT NULL,
	care_site_id bigint NULL,
	source_table varchar(15) NULL
);

With cte AS(
	select distinct 
		eid, 
		data_provider, 
		event_dt as event_dt,
		'gp_clinical' as source_table
	from {SOURCE_SCHEMA}.gp_clinical
	union
	select distinct 
		eid, 
		data_provider, 
		issue_date as event_dt,
		'gp_scripts' as source_table
	from {SOURCE_SCHEMA}.gp_scripts 
)
insert into {SOURCE_SCHEMA}.temp_visit_detail(
	select 
		ROW_NUMBER () OVER ( ORDER BY t1.eid, t1.data_provider, t1.event_dt) as visit_detail_id,
		t1.eid,
		t1.event_dt,
		t1.data_provider,
		t1.source_table
	from cte as t1
	join {TARGET_SCHEMA}.observation_period as t2 on t1.eid = t2.person_id
	where t1.event_dt >= t2.observation_period_start_date and t1.event_dt <= t2.observation_period_end_date
);

alter table {SOURCE_SCHEMA}.temp_visit_detail add constraint pk_temp_visit_d primary key (visit_detail_id);
create index idx_temp_visit_1 on {SOURCE_SCHEMA}.temp_visit_detail (person_id, visit_detail_start_date, care_site_id); 
create index idx_temp_visit_2 on {SOURCE_SCHEMA}.temp_visit_detail (source_table);