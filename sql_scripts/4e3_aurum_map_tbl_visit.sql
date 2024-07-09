--------------------------------
-- VISIT_OCCURRENCE
--------------------------------
drop table if exists {TARGET_SCHEMA}.visit_occurrence CASCADE;
-- Removed where visit_detail_start_date is not null as filtered in temp_visit_detail creation, as obsdate is always NOT NULL
-- Moved before VISIT_DETAILS so it can be used in there
with cte1 as (
	SELECT person_id,
			visit_detail_start_date as visit_start_date,
			care_site_id,
			count(*) as visit_detail_count
	from {SOURCE_SCHEMA}.temp_visit_detail
	group by person_id, visit_detail_start_date, care_site_id
)
SELECT row_number() over (order by person_id, visit_start_date, care_site_id) as visit_occurrence_id, 
		person_id,
		581477::bigint as visit_concept_id,
		visit_start_date,
		NULL::timestamp as visit_start_datetime,
		visit_start_date as visit_end_date, 
		NULL::timestamp as visit_end_datetime,
		32817::bigint as visit_type_concept_id,
		NULL::bigint as provider_id,
		care_site_id,
		NULL::varchar(50) as visit_source_value,
		0 as visit_source_concept_id,
		0 as admitting_source_concept_id,
		NULL::varchar(50) as admitting_source_value,
		0 as discharge_to_concept_id,
		NULL::varchar(50) as discharge_to_source_value,
		NULL::bigint as preceding_visit_occurrence_id
INTO {TARGET_SCHEMA}.visit_occurrence 
FROM cte1;

alter table {TARGET_SCHEMA}.visit_occurrence add constraint xpk_visit_occurrence primary key (visit_occurrence_id) USING INDEX TABLESPACE pg_default;;
create index idx_visit_occ1 on {TARGET_SCHEMA}.visit_occurrence (person_id, visit_start_date, care_site_id) TABLESPACE pg_default;
CLUSTER visit_occurrence USING idx_visit_occ1;
CREATE INDEX idx_visit_concept_id ON visit_occurrence (visit_concept_id ASC) TABLESPACE pg_default;

--------------------------------
-- VISIT_DETAIL
--------------------------------
drop table if exists {TARGET_SCHEMA}.visit_detail CASCADE;
--this first round does not take into account the field preceding_visit_detail_id
--AD: preceding_visit_detail_id is always NULL in the final table. Check!
with cte2 as (
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
	NULL::varchar(50) as admitting_source_value,
	0 as admitting_source_concept_id,
	NULL::varchar(50) as discharge_to_source_value,
	0 as discharge_to_concept_id,
	NULL::bigint preceding_visit_detail_id,
	t2.visit_detail_id as visit_detail_parent_id
from {SOURCE_SCHEMA}.temp_visit_detail t1
left join {SOURCE_SCHEMA}.temp_visit_detail t2
	on t1.visit_detail_parent_id = t2.visit_detail_source_id
	and t2.source_table = 'Observation' -- This condition wasn't in Clair's etl, but it avoids garbage duplication of rows where parentobsid = consid
--where t1.visit_detail_start_date is not null -- Filtered in temp_visit_detail creation
)
SELECT cte2.*, t3.visit_occurrence_id 
INTO {TARGET_SCHEMA}.visit_detail 
FROM cte2
inner join {TARGET_SCHEMA}.visit_occurrence t3 --left join because some of the visit_occurrence_ids are null. AD: WHY Nathan reported this??? I do not think there are visit_occurrence_ids null: we should use INNER JOIN 
	on cte2.person_id = t3.person_id
	and cte2.visit_detail_start_date = t3.visit_start_date
	and cte2.care_site_id = t3.care_site_id;

ALTER TABLE {TARGET_SCHEMA}.visit_detail ADD CONSTRAINT xpk_visit_detail PRIMARY KEY (visit_detail_id) USING INDEX TABLESPACE pg_default;
CREATE INDEX idx_visit_detail_person_id  ON {TARGET_SCHEMA}.visit_detail (person_id) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.visit_detail USING idx_visit_detail_person_id;
CREATE INDEX idx_visit_detail_concept_id ON {TARGET_SCHEMA}.visit_detail (visit_detail_concept_id ASC) TABLESPACE pg_default;
CREATE INDEX idx_visit_det_occ_id ON {TARGET_SCHEMA}.visit_detail (visit_occurrence_id ASC) TABLESPACE pg_default;