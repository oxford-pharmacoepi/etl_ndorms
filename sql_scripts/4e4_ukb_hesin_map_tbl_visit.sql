--------------------------------
-- VISIT_OCCURRENCE
--------------------------------
drop table if exists {TARGET_SCHEMA}.visit_occurrence CASCADE;

with cte1 as (
	SELECT distinct visit_occurrence_id, person_id, visit_start_date, visit_end_date, visit_source_value
	from {SOURCE_SCHEMA}.temp_visit_detail
)
SELECT distinct
	t1.visit_occurrence_id,
	t1.person_id,
	9201 AS visit_concept_id,
	t1.visit_start_date,
	t1.visit_start_date::timestamp as visit_start_datetime,
	t1.visit_end_date,
	t1.visit_end_date::timestamp as visit_end_datetime,
	32818 AS visit_type_concept_id,
	NULL::int AS provider_id,
	NULL::int AS care_site_id,
	t1.visit_source_value,
	NULL::int AS visit_source_concept_id,
	NULL::int AS admitted_from_concept_id,
	NULL::varchar(50) AS admitted_from_source_value,
	NULL::int AS discharged_to_concept_id,
	NULL::varchar(50) AS discharged_to_source_value,
	t2.visit_occurrence_id AS preceding_visit_occurrence_id
INTO {TARGET_SCHEMA}.visit_occurrence
from cte1 as t1
left join cte1 as t2 on t1.person_id = t2.person_id and (t1.visit_occurrence_id - 1) = t2.visit_occurrence_id;
 

ALTER TABLE {TARGET_SCHEMA}.visit_occurrence ADD CONSTRAINT xpk_visit_occurrence PRIMARY KEY (visit_occurrence_id) USING INDEX TABLESPACE pg_default;
CREATE INDEX idx_visit_occ ON {TARGET_SCHEMA}.visit_occurrence (person_id, visit_start_date) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.visit_occurrence USING idx_visit_occ;
--CREATE INDEX idx_visit_concept_id ON {TARGET_SCHEMA}.visit_occurrence (visit_concept_id ASC) TABLESPACE pg_default;
CREATE INDEX idx_visit_source_value ON {TARGET_SCHEMA}.visit_occurrence (visit_source_value ASC) TABLESPACE pg_default;

---------------------------------
-- VISIT_DETAIL FROM hesin
--------------------------------
drop table if exists {TARGET_SCHEMA}.visit_detail CASCADE;

with cte1 AS (
	select eid as person_id, 
	spell_index::varchar(50) as visit_source_value, 
	ins_index::varchar(50) as visit_detail_source_value,
	CASE WHEN tretspef <> '&' THEN tretspef ELSE CASE WHEN mainspef <> '&' THEN mainspef ELSE Null END END as provider_specialty,
	t2.target_concept_id AS admitted_from_concept_id,
	t2.source_code_description::varchar(100) AS admitted_from_source_value,
	t3.source_code_description::varchar(100) AS discharged_to_source_value,
	t3.target_concept_id::int AS discharged_to_concept_id
	FROM {SOURCE_SCHEMA}.hesin as t1
	LEFT JOIN {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_code = CONCAT('265-',t1.admisorc_uni) and t2.target_domain_id = 'Visit' and t2.source_vocabulary_id = 'UKB_ADMISORC_STCM'
	LEFT JOIN {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t3.source_code = CONCAT('267-',t1.disdest_uni) and t3.target_domain_id = 'Visit' and t3.source_vocabulary_id = 'UKB_DISDEST_STCM'
),
cte2 AS (	
	select t1.*, t3.provider_id
	FROM cte1 as t1
	INNER JOIN {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t1.provider_specialty = t2.source_code 
	and t2.source_vocabulary_id = 'HES Specialty'
	INNER JOIN {TARGET_SCHEMA}.provider as t3 on t3.specialty_source_value = t2.source_code_description
),
cte3 AS (	
	select t1.*, t3.provider_id
	FROM cte1 as t1
	LEFT JOIN cte2 as t4 on t1.person_id = t4.person_id and t1.visit_detail_source_value = t4.visit_detail_source_value and t1.provider_specialty = t4.provider_specialty
	LEFT JOIN {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t1.provider_specialty = t2.source_code 
	and t2.source_vocabulary_id = 'HES_SPEC_STCM'
	LEFT JOIN {TARGET_SCHEMA}.provider as t3 on t3.specialty_source_value = t2.source_code_description
	WHERE t4.provider_specialty is null
),
cte4 AS (
	select * from cte2
	UNION DISTINCT
	select * from cte3
)
SELECT distinct 
	t1.visit_detail_id,
	t1.person_id,
	9201 AS visit_detail_concept_id,
	t1.visit_detail_start_date,
	t1.visit_detail_start_date::timestamp as visit_detail_start_datetime,
	t1.visit_detail_end_date,
	t1.visit_detail_end_date::timestamp AS visit_detail_end_datetime,
	32818 AS visit_detail_type_concept_id,
	t2.provider_id,
	NULL::int AS care_site_id,
	t1.visit_detail_source_value as visit_detail_source_value,
	NULL::int AS visit_detail_source_concept_id,
	t2.admitted_from_concept_id,
	t2.admitted_from_source_value,
	t2.discharged_to_source_value,
	t2.discharged_to_concept_id,
	t3.visit_detail_id as preceding_visit_detail_id,
	NULL::int AS parent_visit_detail_id,
	t1.visit_occurrence_id
into {TARGET_SCHEMA}.visit_detail
FROM {SOURCE_SCHEMA}.temp_visit_detail as t1
LEFT JOIN cte4 as t2 on t1.person_id = t2.person_id and t1.visit_source_value = t2.visit_source_value and t1.visit_detail_source_value = t2.visit_detail_source_value
LEFT JOIN {SOURCE_SCHEMA}.temp_visit_detail as t3 on t1.person_id = t3.person_id and (t1.visit_detail_id - 1) = t3.visit_detail_id;


ALTER TABLE {TARGET_SCHEMA}.visit_detail ADD CONSTRAINT xpk_visit_detail PRIMARY KEY (visit_detail_id) USING INDEX TABLESPACE pg_default;	
CREATE INDEX idx_visit_detail_person_id  ON {TARGET_SCHEMA}.visit_detail (person_id, visit_detail_source_value) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.visit_detail USING idx_visit_detail_person_id;
CREATE INDEX idx_visit_detail_concept_id ON {TARGET_SCHEMA}.visit_detail (visit_detail_concept_id ASC) TABLESPACE pg_default;
CREATE INDEX idx_visit_det_occ_id ON {TARGET_SCHEMA}.visit_detail (visit_occurrence_id ASC) TABLESPACE pg_default;