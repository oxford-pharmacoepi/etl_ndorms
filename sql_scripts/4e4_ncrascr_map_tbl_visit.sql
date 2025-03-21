--------------------------------
-- VISIT_OCCURRENCE
--------------------------------
drop table if exists {TARGET_SCHEMA}.visit_occurrence CASCADE;

with cte1 as (
	SELECT distinct visit_occurrence_id, person_id, visit_detail_start_date
	from {SOURCE_SCHEMA}.temp_visit_detail as t1
)
SELECT 
	t1.visit_occurrence_id,
	t1.person_id as person_id,
	38004268::integer as visit_concept_id, --Ambulatory Health Care Facilities, Clinic / Center, Oncology
	t1.visit_detail_start_date as visit_start_date,
	t1.visit_detail_start_date::timestamp as visit_start_datetime,
	t1.visit_detail_start_date as visit_end_date, 
	t1.visit_detail_start_date::timestamp as visit_end_datetime,
	32879::integer as visit_type_concept_id,  -- Registry
	NULL::bigint as provider_id,		
	NULL::integer as care_site_id,
	NULL::varchar(50) as visit_source_value,
	0 as visit_source_concept_id,
	NULL::integer as admitted_from_concept_id,
	NULL::varchar(50) as admitted_from_source_value,
	NULL::integer as discharged_to_concept_id,
	NULL::varchar(50) as discharged_to_source_value,
	t2.visit_occurrence_id as preceding_visit_occurrence_id
INTO {TARGET_SCHEMA}.visit_occurrence
from cte1 as t1
left join cte1 as t2 on (t1.visit_occurrence_id - 1) = t2.visit_occurrence_id 
and t1.person_id = t2.person_id;

alter table {TARGET_SCHEMA}.visit_occurrence add constraint xpk_visit_occurrence primary key (visit_occurrence_id) USING INDEX TABLESPACE pg_default;
create index idx_visit_occ1 on {TARGET_SCHEMA}.visit_occurrence (person_id, visit_start_date, visit_source_value) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.visit_occurrence USING idx_visit_occ1;
CREATE INDEX idx_visit_concept_id ON {TARGET_SCHEMA}.visit_occurrence (visit_concept_id ASC) TABLESPACE pg_default;

--------------------------------
-- VISIT_DETAIL
--------------------------------
drop table if exists {TARGET_SCHEMA}.visit_detail CASCADE;

select 
	t1.visit_detail_id, 
	t1.person_id as person_id, 
	38004268::integer as visit_detail_concept_id,	--Ambulatory Health Care Facilities, Clinic / Center, Oncology
	t1.visit_detail_start_date as visit_detail_start_date,
	t1.visit_detail_start_date::TIMESTAMP as visit_detail_start_datetime,
	t1.visit_detail_start_date as visit_detail_end_date,
	t1.visit_detail_start_date::TIMESTAMP as visit_detail_end_datetime,
	32879::integer as visit_detail_type_concept_id,	-- Registry
	null::integer as provider_id, 		
	null::integer as care_site_id, 
	t1.source_table as visit_detail_source_value, 
	0 as visit_detail_source_concept_id, 
	null::integer as admitted_from_concept_id, 
	null::varchar(50) as admitted_from_source_value, 
	null::varchar(50) as discharged_to_source_value, 
	null::integer as discharged_to_concept_id,
	t2.visit_detail_id as preceding_visit_detail_id,
	null::bigint as parent_visit_detail_id,
	t1.visit_occurrence_id as visit_occurrence_id
into {TARGET_SCHEMA}.visit_detail
from {SOURCE_SCHEMA}.temp_visit_detail as t1
left join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.visit_detail_id - 1 = t2.visit_detail_id 
and t2.person_id = t1.person_id;

	
ALTER TABLE {TARGET_SCHEMA}.visit_detail ADD CONSTRAINT xpk_visit_detail PRIMARY KEY (visit_detail_id) USING INDEX TABLESPACE pg_default;
CREATE INDEX idx_visit_detail_person_id  ON {TARGET_SCHEMA}.visit_detail (person_id) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.visit_detail USING idx_visit_detail_person_id;
CREATE INDEX idx_visit_detail_concept_id ON {TARGET_SCHEMA}.visit_detail (visit_detail_concept_id ASC) TABLESPACE pg_default;
CREATE INDEX idx_visit_det_occ_id ON {TARGET_SCHEMA}.visit_detail (visit_occurrence_id ASC) TABLESPACE pg_default;