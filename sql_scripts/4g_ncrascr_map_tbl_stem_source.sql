CREATE TABLE {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (LIKE {TARGET_SCHEMA}.STEM_SOURCE);

-------------------------------------------
--insert into stem_source table from tumour
-------------------------------------------
WITH cte0 as (
		select person_id
		from {CHUNK_SCHEMA}.chunk_person
		where chunk_id = {CHUNK_ID}
),
cte1 as (
		select t2.e_patid as person_id, 
		t2.e_cr_id, 
		t2.diagnosisdatebest as start_date, 
		t2.morph_icd10_o2 || '/' || t2.behaviour_icd10_o2 || '-' || site_icd10_o2 || '.9' as source_code
		from cte0 as t1
		inner join {SOURCE_SCHEMA}.tumour as t2 on t1.person_id = t2.e_patid
),
cte2 as (
		select t1.person_id, 
		t1.e_cr_id, 
		t1.start_date, 
		t1.source_code as source_value,
		COALESCE(t2.source_concept_id, 0) as source_concept_id
		from cte1 as t1
		left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t1.source_code = t2.source_code 
		and t2.source_vocabulary_id = 'ICDO3'
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (domain_id, person_id, visit_occurrence_id, visit_detail_id, provider_id, concept_id, source_value,
					 source_concept_id, type_concept_id, start_date, end_date, start_time, days_supply, dose_unit_concept_id,
					 dose_unit_source_value, effective_drug_dose, lot_number, modifier_source_value, 
					 operator_concept_id, qualifier_concept_id, qualifier_source_value, quantity, 
					 range_high, range_low, refills, route_concept_id, route_source_value, sig, stop_reason, unique_device_id, unit_concept_id,
					 unit_source_value, value_as_concept_id, value_as_number, value_as_string,
					 value_source_value, anatomic_site_concept_id, disease_status_concept_id, specimen_source_id, anatomic_site_source_value, disease_status_source_value, 
					 modifier_concept_id, stem_source_table, stem_source_id)
select NULL as domain_id,
	t1.person_id, 
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	NULL as provider_id,
	NULL as concept_id,
	t1.source_value,
	t1.source_concept_id,
	32879 as type_concept_id,	--Registry
	t1.start_date,
	t1.start_date as end_date,
	'00:00:00'::time start_time,
	NULL as days_supply,
	0 as dose_unit_concept_id,
	NULL as dose_unit_source_value, 
	NULL as effective_drug_dose, 
	NULL as lot_number, 
	NULL as modifier_source_value,
	0 as operator_concept_id,
	0 as qualifier_concept_id,
	NULL as qualifier_source_value, 
	NULL as quantity, 
	NULL::double precision as range_high,
	NULL::double precision as range_low,
	NULL as refills,
	0 as route_concept_id,
	NULL as route_source_value,
	0 as unit_concept_id,
	NULL as sig, 
	NULL as stop_reason, 
	NULL as unique_device_id,
	NULL as unit_source_value,
	0 as value_as_concept_id,
	NULL::int as value_as_number,
	NULL as value_as_string,
	NULL::varchar value_source_value,
	0 as anatomic_site_concept_id,
	0 as disease_status_concept_id,
	NULL as specimen_source_id,
	NULL as anatomic_site_source_value, 
	NULL as disease_status_source_value, 
	0 as modifier_concept_id,
	'Tumour' stem_source_table,
	t1.e_cr_id as stem_source_id
from cte2 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.e_cr_id = t2.visit_detail_source_id
WHERE t2.source_table = 'Tumour';


-------------------------------------------
--insert into stem_source from treatment
-------------------------------------------
WITH cte1 as (
		select person_id
		from {CHUNK_SCHEMA}.chunk_person
		where chunk_id = {CHUNK_ID}
	),
	cte2a as (
-- when there is an OPCS4 code
		select t1.person_id, 
		t2.treatment_id, 
		t2.eventdate as start_date, 
		left(t2.opcs4_code, 3) || '.' || right(t2.opcs4_code, 1) as source_code
		from cte1 as t1
		inner join {SOURCE_SCHEMA}.treatment as t2 on t1.person_id = t2.e_patid
		where t2.eventdate is not NULL
		AND t2.opcs4_code is not null
	),
	cte3a as (
		select t1.person_id,
		t1.treatment_id,
		t1.start_date,
		t1.source_code as source_value,
		COALESCE(t2.source_concept_id, 0) as source_concept_id
		from cte2a as t1
		left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_code = t1.source_code
		and t2.source_vocabulary_id = 'OPCS4'
	),
-- when there is NOT an OPCS4 code
	cte2b_1 as (
		select t1.person_id, 
		t2.treatment_id, 
		t2.eventdate as start_date, 
		TRIM(SPLIT_PART(chemo_all_drug,',',1)) as ing1,
		TRIM(SPLIT_PART(chemo_all_drug,',',2)) as ing2,
		TRIM(SPLIT_PART(chemo_all_drug,',',3)) as ing3
		from cte1 as t1
		inner join {SOURCE_SCHEMA}.treatment as t2 on t1.person_id = t2.e_patid
		where t2.eventdate is not NULL
		AND t2.opcs4_code is null
		AND t2.chemo_all_drug is not null
		AND t2.chemo_all_drug not in ('UNKNOWN', 'NOT YET CLASSIFIED', 'NOT CHEMO', 'HORMONE THERAPY NOS', 'IMMUNOTHERAPY NOS', 'CHEMOTHERAPY NOS')
	),
	cte2b_2 as (
		select person_id, treatment_id, start_date, ing1 as source_code from cte2b_1 
		WHERE ing1 <> ''
		UNION ALL
		select person_id, treatment_id, start_date, ing2 as source_code from cte2b_1 
		WHERE ing2 <> ''
		UNION ALL
		select person_id, treatment_id, start_date, ing3 as source_code from cte2b_1 
		WHERE ing3 <> ''
	),
	cte3b as (
		select t1.person_id,
		t1.treatment_id,
		t1.start_date,
		t1.source_code as source_value,
		COALESCE(t2.source_concept_id, 0) as source_concept_id
		from cte2b_2 as t1
		left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on upper(t1.source_code) = upper(t2.source_code_description) 
		and t2.source_vocabulary_id in ('RxNorm', 'RxNorm Extension') and t2.source_concept_class_id = 'Ingredient'
		left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t3.source_code = t1.source_code
		and t2.source_concept_id is null and t3.source_vocabulary_id = 'NCRAS_STCM'
	),
	cte2b_3 as (
		select t1.person_id, 
		t2.treatment_id, 
		t2.eventdate as start_date, 
		CASE	WHEN radiodesc is null and chemo_all_drug is null THEN eventdesc
				WHEN radiodesc is not null THEN
					CASE WHEN radiodesc in ('RADIOACTIVE ISOTOPES', 'BRACHYTHERAPY', 'INTRACAVITARY OR INTERSTITIAL', 'EXTERNAL BEAM')
						THEN radiodesc
						ELSE eventdesc
					END
				WHEN chemo_all_drug is not null THEN
					CASE WHEN chemo_all_drug in ('UNKNOWN', 'NOT YET CLASSIFIED', 'NOT CHEMO') THEN eventdesc
						WHEN chemo_all_drug in ('HORMONE THERAPY NOS', 'IMMUNOTHERAPY NOS', 'CHEMOTHERAPY NOS') THEN chemo_all_drug
					END
		END as source_code
		from cte1 as t1
		inner join {SOURCE_SCHEMA}.treatment as t2 on t1.person_id = t2.e_patid
		where t2.eventdate is not NULL
		AND t2.opcs4_code is null
		AND (t2.chemo_all_drug is null or t2.chemo_all_drug in ('UNKNOWN', 'NOT YET CLASSIFIED', 'NOT CHEMO', 'HORMONE THERAPY NOS', 'IMMUNOTHERAPY NOS', 'CHEMOTHERAPY NOS'))
	),
	cte3c as (
		select t1.person_id,
		t1.treatment_id,
		t1.start_date,
		t1.source_code as source_value,
		COALESCE(t2.source_concept_id, 0) as source_concept_id
		from cte2b_3 as t1
		left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_code = t1.source_code
		and t2.source_vocabulary_id = 'NCRAS_STCM'
	),
	cte3 as (
		select * from cte3a
		UNION ALL
		select * from cte3b
		UNION ALL
		select * from cte3c
	)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (domain_id, person_id, visit_occurrence_id, visit_detail_id, provider_id, concept_id, source_value,
										 source_concept_id, type_concept_id, start_date, end_date, start_time, days_supply, dose_unit_concept_id,
										 dose_unit_source_value, effective_drug_dose, lot_number, modifier_source_value, operator_concept_id, qualifier_concept_id,
										 qualifier_source_value, quantity, range_high, range_low, refills, route_concept_id, route_source_value,
										 sig, stop_reason, unique_device_id, unit_concept_id, unit_source_value, value_as_concept_id, value_as_number,
										 value_as_string, value_source_value, anatomic_site_concept_id, disease_status_concept_id, specimen_source_id,
										 anatomic_site_source_value, disease_status_source_value, modifier_concept_id, stem_source_table, stem_source_id)
select NULL as domain_id,
		t1.person_id,
		t2.visit_occurrence_id,
		t2.visit_detail_id,
		NULL as provider_id,
		NULL as concept_id,
		t1.source_value,
		t1.source_concept_id,
		32879 as type_concept_id,	--Registry
		t1.start_date,
		t1.start_date as end_date,
		'00:00:00'::time,
		NULL::int,
		0,
		NULL,
		NULL,
		NULL,
		NULL,
		0,
		0,
		NULL,
		NULL::double precision,
		NULL::double precision,
		NULL::double precision,
		NULL::int,
		0,
		NULL,
		NULL,
		NULL,
		NULL,
		0,
		NULL,
		0,
		NULL::double precision,
		NULL,
		NULL,
		0,
		0,
		NULL,
		NULL,
		NULL,
		0,
		'Treatment',
		t1.treatment_id as stem_source_id
from cte3 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail t2 on t1.treatment_id = t2.visit_detail_source_id
where t2.source_table = 'Treatment';

create index idx_stem_source_{CHUNK_ID} on {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (source_concept_id);

-----------------------------------------
-- UPDATE CHUNK
-----------------------------------------
update {CHUNK_SCHEMA}.chunk 
set stem_source_tbl = concat('stem_source_',{CHUNK_ID}::varchar)
where chunk_id = {CHUNK_ID};