--------------------------------
-- VISIT_OCCURRENCE
--------------------------------
drop table if exists {TARGET_SCHEMA}.visit_occurrence CASCADE;

CREATE TABLE {TARGET_SCHEMA}.visit_occurrence TABLESPACE pg_default AS
with cte1 as (
	SELECT distinct visit_occurrence_id, person_id, care_site_id, visit_detail_start_date
	from {SOURCE_SCHEMA}.temp_visit_detail
)
SELECT 
	visit_occurrence_id,
	person_id,
	581477::bigint as visit_concept_id,
	visit_detail_start_date as visit_start_date,
	visit_detail_start_date::timestamp as visit_start_datetime,
	visit_detail_start_date as visit_end_date, 
	visit_detail_start_date::timestamp as visit_end_datetime,
	32817::bigint as visit_type_concept_id,
	NULL::bigint as provider_id,
	care_site_id,
	NULL::varchar(50) as visit_source_value,
	0 as visit_source_concept_id,
	0 as admitted_from_concept_id,
	NULL::varchar(50) as admitted_from_source_value,
	0 as discharged_to_concept_id,
	NULL::varchar(50) as discharged_to_source_value,
	LAG(visit_occurrence_id) OVER (PARTITION BY person_id ORDER BY visit_occurrence_id) AS preceding_visit_occurrence_id
from cte1 as t1;

alter table {TARGET_SCHEMA}.visit_occurrence add constraint xpk_visit_occurrence primary key (visit_occurrence_id) USING INDEX TABLESPACE pg_default;;
create index idx_visit_occ1 on {TARGET_SCHEMA}.visit_occurrence (person_id, visit_start_date, care_site_id) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.visit_occurrence USING idx_visit_occ1;
CREATE INDEX idx_visit_concept_id ON {TARGET_SCHEMA}.visit_occurrence (visit_concept_id ASC) TABLESPACE pg_default;

--------------------------------
-- VISIT_DETAIL
--------------------------------
drop table if exists {TARGET_SCHEMA}.visit_detail CASCADE;

select t1.visit_detail_id,
	t1.person_id,
	581477 as visit_detail_concept_id,
	t1.visit_detail_start_date,
	NULL::timestamp as visit_detail_start_datetime,
	t1.visit_detail_start_date as visit_detail_end_date,
	NULL::timestamp as visit_detail_end_datetime,
	32817 as visit_detail_type_concept_id,
	t1.provider_id,
	t1.care_site_id,
	NULL::varchar(50) as visit_detail_source_value,
	0 as visit_detail_source_concept_id,
	0 as admitted_from_concept_id,
	NULL::varchar(50) as admitted_from_source_value,
	NULL::varchar(50) as discharged_to_source_value,
	0 as discharged_to_concept_id,
	t2.visit_detail_id as preceding_visit_detail_id,
	NULL::bigint as parent_visit_detail_id,
	t1.visit_occurrence_id as visit_occurrence_id
into {TARGET_SCHEMA}.visit_detail
from {SOURCE_SCHEMA}.temp_visit_detail as t1
left join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.visit_detail_id - 1 = t2.visit_detail_id 
and t2.person_id = t1.person_id;


ALTER TABLE {TARGET_SCHEMA}.visit_detail SET TABLESPACE pg_default;

ALTER TABLE {TARGET_SCHEMA}.visit_detail ADD CONSTRAINT xpk_visit_detail PRIMARY KEY (visit_detail_id) USING INDEX TABLESPACE pg_default;
CREATE INDEX idx_visit_detail_person_id  ON {TARGET_SCHEMA}.visit_detail (person_id) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.visit_detail USING idx_visit_detail_person_id;
CREATE INDEX idx_visit_detail_concept_id ON {TARGET_SCHEMA}.visit_detail (visit_detail_concept_id ASC) TABLESPACE pg_default;
CREATE INDEX idx_visit_det_occ_id ON {TARGET_SCHEMA}.visit_detail (visit_occurrence_id ASC) TABLESPACE pg_default;