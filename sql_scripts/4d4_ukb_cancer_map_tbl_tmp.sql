--------------------------------
-- TEMP_VISIT_DETAIL
--------------------------------
drop table if exists {SOURCE_SCHEMA}.temp_visit_detail CASCADE;

CREATE TABLE {SOURCE_SCHEMA}.temp_visit_detail 
(
	visit_detail_id bigint NOT NULL,
	person_id bigint NOT NULL,
	visit_detail_start_date date NOT NULL,
	visit_source_value varchar(60)
);

With cte AS(
	select distinct 
		t1.eid, 
		t1.p40005 as diagnosis_date,
		COALESCE(t2.description, t1.p40021) as data_source
	from {SOURCE_SCHEMA}.cancer2 as t1
	left join {SOURCE_SCHEMA}.lookup1970 as t2 on t1.p40021 = t2.code
)
insert into {SOURCE_SCHEMA}.temp_visit_detail
select 
	ROW_NUMBER () OVER ( ORDER BY eid, diagnosis_date, data_source) as visit_detail_id,
	eid,
	diagnosis_date,
	data_source
from cte;

alter table {SOURCE_SCHEMA}.temp_visit_detail add constraint pk_temp_visit_d primary key (visit_detail_id);
create index idx_temp_visit_1 on {SOURCE_SCHEMA}.temp_visit_detail (person_id, visit_detail_start_date, visit_source_value); 