--------------------------------
-- TEMP_VISIT_DETAIL
--------------------------------
drop table if exists {SOURCE_SCHEMA}.temp_visit_detail CASCADE;

CREATE TABLE {SOURCE_SCHEMA}.temp_visit_detail 
(
	visit_detail_id bigint NOT NULL,
	person_id bigint NOT NULL,
	visit_detail_start_date date NOT NULL
);

insert into {SOURCE_SCHEMA}.temp_visit_detail
select 
	ROW_NUMBER () OVER (ORDER BY eid, p53_i0) as visit_detail_id,
	eid as person_id,
	p53_i0 as visit_detail_start_date
from {SOURCE_SCHEMA}.baseline;

alter table {SOURCE_SCHEMA}.temp_visit_detail add constraint pk_temp_visit_d primary key (visit_detail_id);
create index idx_temp_visit_1 on {SOURCE_SCHEMA}.temp_visit_detail (person_id, visit_detail_start_date); 