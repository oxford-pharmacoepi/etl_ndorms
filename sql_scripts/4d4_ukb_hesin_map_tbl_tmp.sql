
--------------------------------
-- TEMP_VISIT_DETAIL
--------------------------------
drop table if exists {SOURCE_SCHEMA}.temp_visit_detail CASCADE;

CREATE TABLE {SOURCE_SCHEMA}.temp_visit_detail
(
	visit_detail_id bigint NOT NULL,
	person_id bigint NOT NULL,
	visit_detail_start_date date NOT NULL,
	visit_detail_end_date date NOT NULL,
	visit_detail_source_value varchar NOT NULL,
	visit_detail_source_value_2 varchar NOT NULL,
	
);
--with cte0 AS (
--	SELECT max_id + 1 as start_id from {TARGET_SCHEMA_TO_LINK}._max_ids 
--	WHERE lower(tbl_name) = 'max_of_all'
--),
--	cte1 as (


--)
--SELECT 
--	COUNT(*)
--from cte2 as t1

With cte0 AS(
	select 
		eid,
		data_provider, 
		reg_date as event_dt,
		'Registration' as source_table
	from {SOURCE_SCHEMA}.gp_registrations
), cte1 as(
	select distinct		
		t1.eid,
		t1.event_dt,
		lkup.description as data_provider,
		source_table
	from cte0 as t1
	join {SOURCE_SCHEMA}.lookup626 as lkup on lkup.code = t1.data_provider
	join {TARGET_SCHEMA}.observation_period as t2 on t1.eid = t2.person_id
	where t1.event_dt >= t2.observation_period_start_date and t1.event_dt <= t2.observation_period_end_date
)
insert into {SOURCE_SCHEMA}.temp_visit_detail
select 
	ROW_NUMBER () OVER ( ORDER BY eid, event_dt, data_provider, source_table) as visit_detail_id,
	*
from cte1;




alter table {SOURCE_SCHEMA}.temp_visit_detail add constraint pk_temp_visit_d primary key (visit_detail_id);
create index idx_temp_visit_1 on {SOURCE_SCHEMA}.temp_visit_detail (person_id, visit_detail_start_date, visit_source_value); 
