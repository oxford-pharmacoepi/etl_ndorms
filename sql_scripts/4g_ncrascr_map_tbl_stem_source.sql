CREATE TABLE {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (LIKE {TARGET_SCHEMA}.STEM_SOURCE) TABLESPACE pg_default;

-------------------------------------------
--insert into stem_source table from tumour
-------------------------------------------
WITH cte01 as (
		select person_id
		from {CHUNK_SCHEMA}.chunk_person
		where chunk_id = {CHUNK_ID}
),
cte1 as (
		select distinct
		t2.patid as person_id, 
		t2.cr_id, 
		t2.diagnosisdatebest as start_date, 
		t2.morph_icd10_o2, t2.behaviour_icd10_o2, site_icd10_o2, 
		replace(t2.site_coded,'-','') as site_coded,
		CASE 
			WHEN t2.basisofdiagnosis in ('3','9','&') and upper(t2.dco) = 'Y' THEN 0
			WHEN t2.basisofdiagnosis = '&' and upper(t2.dco) in ('N','0') THEN null
			WHEN t2.basisofdiagnosis = '&' and t2.dco is null THEN null
			ELSE t2.basisofdiagnosis::int 
		END as type_source_value
		from cte01 as t1
		inner join {SOURCE_SCHEMA}.tumour as t2 on t1.person_id = t2.patid
),
cte1a as (
		select distinct
		person_id, 
		cr_id, 
		start_date, 
		site_icd10_o2,
		CASE WHEN length(site_icd10_o2) = 4 
			THEN morph_icd10_o2 || '/' || behaviour_icd10_o2 || '-' || left(site_icd10_o2,3) || '.' || right(site_icd10_o2,1)
			ELSE morph_icd10_o2 || '/' || behaviour_icd10_o2 || '-' || site_icd10_o2 || '.9' 
		END as source_value,
		type_source_value
		from cte1
		WHERE site_icd10_o2 is not NULL
),
cte2a1 as (
		select distinct
		t1.person_id, 
		t1.cr_id, 
		t1.start_date, 
		t1.site_icd10_o2,
		t1.source_value,
		COALESCE(t2.source_concept_id, 0) as source_concept_id,
		'tumour_diagnosis_icdO3' as value_source_value,
		type_source_value
		from cte1a as t1
		left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t1.source_value = t2.source_code 
		and t2.source_vocabulary_id = 'ICDO3'
),
cte2a2 as (
		select distinct
		t1.person_id, 
		t1.cr_id, 
		t1.start_date, 
		t2.source_code as source_value,
		t2.source_concept_id,
		'tumour_diagnosis_icd10' as value_source_value,
		type_source_value
		from cte2a1 as t1
		inner join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t1.site_icd10_o2 = replace(t2.source_code,'.','') 
		and t2.source_vocabulary_id = 'ICD10'
		WHERE t1.source_concept_id = 0
),
cte2a as (
		select person_id, cr_id, start_date, source_value, source_concept_id, value_source_value, type_source_value 
		from cte2a1 
		WHERE source_concept_id <> 0
		
		UNION DISTINCT 
		
		select * 
		from cte2a2
		
		UNION DISTINCT 

		select t1.person_id, t1.cr_id, t1.start_date, t1.source_value, t1.source_concept_id, t1.value_source_value, t1.type_source_value 
		from cte2a1 as t1
		left join cte2a2 as t2 on t1.person_id = t2.person_id and t1.cr_id = t2.cr_id and t1.start_date = t2.start_date 
		WHERE t2.source_concept_id = 0
		and t2.person_id is null
),
cte1b as (
		select distinct
		person_id, 
		cr_id, 
		start_date,
		CASE WHEN length(site_coded) = 3 THEN site_coded
			 WHEN length(site_coded) = 4 THEN left(site_coded,3) || '.'|| right(site_coded, 1)
		END as site_coded,
		type_source_value
		from cte1
		WHERE site_icd10_o2 is NULL 
		AND site_coded is not NULL
),
cte2b as (
		select distinct
		t1.person_id, 
		t1.cr_id, 
		t1.start_date, 
		COALESCE(t2.source_code, t1.site_coded) as source_value,
		COALESCE(t2.source_concept_id, 0) as source_concept_id,
		'tumour_diagnosis_icd9cm' as value_source_value,
		type_source_value
		from cte1b as t1
		left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 ON t1.site_coded = t2.source_code
		and t2.source_vocabulary_id = 'ICD9CM'
),
cte3 as (
		SELECT person_id, cr_id, start_date, source_value, source_concept_id, value_source_value, type_source_value from cte2a
		UNION DISTINCT
		SELECT person_id, cr_id, start_date, source_value, source_concept_id, value_source_value, type_source_value from cte2b
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
	null as concept_id,
	t1.source_value,
	t1.source_concept_id,
	COALESCE(t3.target_concept_id, 32879) as type_concept_id,
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
	t1.value_source_value,
	0 as anatomic_site_concept_id,
	0 as disease_status_concept_id,
	NULL as specimen_source_id,
	NULL as anatomic_site_source_value, 
	NULL as disease_status_source_value, 
	0 as modifier_concept_id,
	'Tumour' stem_source_table,
	t1.cr_id as stem_source_id
from cte3 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.cr_id = t2.visit_detail_source_id
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.type_source_value = t3.source_code::int
and t3.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
WHERE t2.source_table = 'Tumour'
AND t1.person_id = t2.person_id;


-------------------------------------------
--insert into stem_source from treatment
-------------------------------------------
WITH cte02 as (
		select person_id
		from {CHUNK_SCHEMA}.chunk_person
		where chunk_id = {CHUNK_ID}
	),
	cte2a_1 as (
-- when there is an OPCS4 code of length = 4
		select t1.person_id, 
		t2.treatment_id, 
		t2.eventdate as start_date, 
		CASE WHEN length(t2.opcs4_code) = 4 THEN left(t2.opcs4_code, 3) || '.' || right(t2.opcs4_code, 1) 
			 WHEN length(t2.opcs4_code) > 4 AND substring(t2.opcs4_code,5,1) = ' ' THEN left(t2.opcs4_code, 3) || '.' || substring(t2.opcs4_code,4,1)
			 ELSE t2.opcs4_code
		END as source_code
		from cte02 as t1
		inner join {SOURCE_SCHEMA}.treatment as t2 on t1.person_id = t2.patid
		where t2.eventdate is not NULL
		AND length(t2.opcs4_code) >= 4
	),
	cte3a as (
		select t1.person_id,
		t1.treatment_id,
		t1.start_date,
		t1.source_code as source_value,
		COALESCE(t2.source_concept_id, t3.source_concept_id, 0) as source_concept_id,
		'opcs4_code' as value_source_value,
		'Treatment' as stem_source_table
		from cte2a_1 as t1
		left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_code = t1.source_code
		and t2.source_vocabulary_id = 'OPCS4'
		left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t3.source_code = t1.source_code
		and t3.source_vocabulary_id = 'NCRAS_TREATMENT_OPCS4_STCM' and t2.source_code is null
	),
-- when there is NOT an OPCS4 code
	cte2b_1 as (
		select t1.person_id, 
		t2.treatment_id, 
		t2.eventdate as start_date, 
		TRIM(SPLIT_PART(chemo_all_drug,',',1)) as ing1,
		TRIM(SPLIT_PART(chemo_all_drug,',',2)) as ing2,
		TRIM(SPLIT_PART(chemo_all_drug,',',3)) as ing3
		from cte02 as t1
		inner join {SOURCE_SCHEMA}.treatment as t2 on t1.person_id = t2.patid
		where t2.eventdate is not NULL
		AND t2.opcs4_code is null
		AND t2.chemo_all_drug is not null
		AND t2.chemo_all_drug not in ('UNKNOWN', 'NOT YET CLASSIFIED', 'NOT CHEMO', 'HORMONE THERAPY NOS', 'IMMUNOTHERAPY NOS', 'CHEMOTHERAPY NOS')
	),
	cte2b_2 as (
		select person_id, treatment_id, start_date, ing1 as source_code from cte2b_1 
		WHERE ing1 <> ''
		UNION DISTINCT
		select person_id, treatment_id, start_date, ing2 as source_code from cte2b_1 
		WHERE ing2 <> ''
		UNION DISTINCT
		select person_id, treatment_id, start_date, ing3 as source_code from cte2b_1 
		WHERE ing3 <> ''
	),
	cte3b as (
		select t1.person_id,
		t1.treatment_id,
		t1.start_date,
		t1.source_code as source_value,
		COALESCE(t2.source_concept_id, 0) as source_concept_id,
		'chemo_all_drug' as value_source_value,
		'Treatment-Chemo_all_drug' as stem_source_table
		from cte2b_2 as t1
		left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on upper(t1.source_code) = upper(t2.source_code_description) 
		and t2.source_vocabulary_id in ('RxNorm', 'RxNorm Extension') and t2.source_concept_class_id = 'Ingredient'
		and t2.source_invalid_reason is null
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
		END as source_code,
		CASE	WHEN chemo_all_drug in ('HORMONE THERAPY NOS', 'IMMUNOTHERAPY NOS', 'CHEMOTHERAPY NOS') 
					THEN 'chemo_all_drug' 
					ELSE 'radiodesc/eventdesc'
		END as value_source_value,
		CASE	WHEN chemo_all_drug in ('HORMONE THERAPY NOS', 'IMMUNOTHERAPY NOS', 'CHEMOTHERAPY NOS') 
					THEN 'Treatment-Chemo_all_drug' 
					ELSE 'Treatment-Radiodesc'
		END as stem_source_table
		from cte02 as t1
		inner join {SOURCE_SCHEMA}.treatment as t2 on t1.person_id = t2.patid
		where t2.eventdate is not NULL
		AND eventcode NOT in ('97', '99') -- 97 = "Other Treatment", 99 = "Treatment unknown"
		AND (imagingsite is null or imagingsite !~'^CZ00')
		AND t2.opcs4_code is null
		AND (t2.chemo_all_drug is null or t2.chemo_all_drug in ('UNKNOWN', 'NOT YET CLASSIFIED', 'NOT CHEMO', 'HORMONE THERAPY NOS', 'IMMUNOTHERAPY NOS', 'CHEMOTHERAPY NOS'))
	),
	cte3c as (
		select person_id,
		treatment_id,
		start_date,
		source_code as source_value,
		0 as source_concept_id,
		value_source_value,
		stem_source_table
		from cte2b_3
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
		'00:00:00'::time as start_time,
		NULL::int as days_supply,
		0 as dose_unit_concept_id,
		NULL as dose_unit_source_value,
		NULL as effective_drug_dose,
		NULL as lot_number,
		NULL as modifier_source_value,
		0 as operator_concept_id,
		0 as qualifier_concept_id,
		NULL as qualifier_source_value,
		NULL::double precision as quantity,
		NULL::double precision as range_high,
		NULL::double precision as range_low,
		NULL::int as refills,
		0 as route_concept_id,
		NULL as route_source_value,
		NULL as sig,
		NULL as stop_reason,
		NULL as unique_device_id,
		0 as unit_concept_id,
		NULL as unit_source_value,
		0 as value_as_concept_id,
		NULL::double precision as value_as_number,
		NULL as value_as_string,
		value_source_value,
		0 as anatomic_site_concept_id,
		0 as disease_status_concept_id,
		NULL as specimen_source_id,
		NULL as anatomic_site_source_value,
		NULL as disease_status_source_value,
		0 as modifier_concept_id,
		t1.stem_source_table,
		t1.treatment_id as stem_source_id
from cte3 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail t2 on t1.treatment_id::varchar = t2.visit_detail_source_id
where t2.source_table = 'Treatment'
AND t1.person_id = t2.person_id;

------------------------------------------------------------------------
-- Cancer Diagnostic Modifiers 'Tumour-[modifier]' as stem_source_table
------------------------------------------------------------------------
WITH cte03 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as (
	select DISTINCT
		t1.patid, t1.cr_id,
		CASE 
			WHEN t1.basisofdiagnosis in ('3','9','&') and upper(t1.dco) = 'Y' THEN 0
			WHEN t1.basisofdiagnosis = '&' and upper(t1.dco) in ('N','0') THEN null
			WHEN t1.basisofdiagnosis = '&' and t1.dco is null THEN null
			ELSE t1.basisofdiagnosis::int
		END as type_source_value,
		t1.diagnosisdatebest as start_date,
		t1.tumoursize, t1.nodesexcised, t1.nodesinvolved, t1.tumourcount, t1.bigtumourcount, 
		t1.chrl_tot_27_03, t1.chrl_tot_78_06, t1.gleason_combined, t1.npi
		from {SOURCE_SCHEMA}.tumour as t1
		inner join cte03 as t2 on t2.person_id = t1.patid
), cte3 as (
	select DISTINCT patid, cr_id, type_source_value, start_date, 
		'tumoursize' as source_value,
		tumoursize as value_as_number,
		'mm' as unit_source_value
	from cte1
	where tumoursize is not null

	union

	select DISTINCT patid, cr_id, type_source_value, start_date, 
		'nodesexcised' as source_value,
		nodesexcised as value_as_number,
		null as unit_source_value
	from cte1
	where nodesexcised is not null

	union

	select DISTINCT patid, cr_id, type_source_value, start_date, 
		'nodesinvolved' as source_value,
		nodesinvolved as value_as_number,
		null as unit_source_value
	from cte1
	where nodesinvolved is not null

	union

	select DISTINCT patid, cr_id, type_source_value, start_date, 
		'tumourcount' as source_value,
		tumourcount as value_as_number,
		null as unit_source_value
	from cte1
	where tumourcount is not null

	union

	select DISTINCT patid, cr_id, type_source_value, start_date, 
		'bigtumourcount' as source_value,
		bigtumourcount as value_as_number,
		null as unit_source_value
	from cte1
	where bigtumourcount is not null

	union

	select DISTINCT patid, cr_id, type_source_value, start_date, 
		'chrl_tot_27_03' as source_value,
		chrl_tot_27_03 as value_as_number,
		null as unit_source_value
	from cte1
	where chrl_tot_27_03 is not null

	union

	select DISTINCT patid, cr_id, type_source_value, start_date, 
		'chrl_tot_78_06' as source_value,
		chrl_tot_78_06 as value_as_number,
		null as unit_source_value
	from cte1
	where chrl_tot_78_06 is not null

	union

	select DISTINCT patid, cr_id, type_source_value, start_date, 
		'gleason_combined' as source_value,
		gleason_combined as value_as_number,
		null as unit_source_value
	from cte1
	where gleason_combined is not null

	union

	select DISTINCT patid, cr_id, type_source_value, start_date, 
		'npi' as source_value,
		npi as value_as_number,
		null as unit_source_value
	from cte1
	where npi is not null
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_number,
	unit_source_value,
	value_source_value,
	stem_source_table,
	stem_source_id
)
select distinct								
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.source_value,
	0 as source_concept_id,
	COALESCE(t4.target_concept_id, 32879) as type_concept_id,
	t1.start_date as start_date,
	t1.start_date as end_date,
	'00:00:00'::time start_time,
	t1.value_as_number,
	t1.unit_source_value,
	t1.source_value as value_source_value,
	'Tumour-Modifier' as stem_source_table,
	t1.cr_id as stem_source_id
from cte3 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.cr_id = t2.visit_detail_source_id 
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t1.type_source_value = t4.source_code::int
and t4.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
WHERE t2.source_table = 'Tumour'
AND t1.patid = t2.person_id;

--breslow
WITH cte04 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select DISTINCT
		patid,
		CASE 
			WHEN basisofdiagnosis in ('3','9','&') and upper(dco) = 'Y' THEN 0
			WHEN basisofdiagnosis = '&' and upper(dco) in ('N','0') THEN null
			WHEN basisofdiagnosis = '&' and dco is null THEN null
			ELSE basisofdiagnosis::int
		END as type_source_value,
		diagnosisdatebest as start_date,
		'breslow' as source_value,
		CASE WHEN breslow !~'-|>|<' THEN breslow::numeric ELSE null::numeric END as value_as_number,
		CASE WHEN breslow ~'^>' THEN substring(breslow from 2)::numeric
			 WHEN breslow ~'-' THEN substring(breslow for position('-' in breslow)-1)::numeric
			 ELSE null::numeric END as range_low,
		CASE WHEN breslow ~'^<' THEN substring(breslow from 2)::numeric
			 WHEN breslow ~'-' THEN substring(breslow from position('-' in breslow)+1)::numeric
			 ELSE null::numeric END as range_high,
		null as unit_source_value,
		breslow as value_source_value,
		cr_id
	from {SOURCE_SCHEMA}.tumour as t1
	inner join cte04 as t2 on t2.person_id = t1.patid
	where breslow is not null
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_number,
	range_low,
	range_high,
	unit_source_value,
	value_source_value,
	stem_source_table,
	stem_source_id
)
select distinct								
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.source_value,
	0 as source_concept_id,
	COALESCE(t4.target_concept_id, 32879) as type_concept_id,
	t1.start_date as start_date,
	t1.start_date as end_date,
	'00:00:00'::time start_time,
	t1.value_as_number,
	t1.range_low,
	t1.range_high,
	t1.unit_source_value,
	t1.value_source_value,
	'Tumour-Modifier' as stem_source_table,
	t1.cr_id as stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.cr_id = t2.visit_detail_source_id
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t1.type_source_value = t4.source_code::int 
and t4.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
WHERE t2.source_table = 'Tumour'
AND t1.patid = t2.person_id;

-- GRADE 
WITH cte05 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select DISTINCT
		t1.patid,
		t1.grade,
		CASE 
			WHEN t1.basisofdiagnosis in ('3','9','&') and upper(t1.dco) = 'Y' THEN 0
			WHEN t1.basisofdiagnosis = '&' and upper(t1.dco) in ('N','0') THEN null
			WHEN t1.basisofdiagnosis = '&' and t1.dco is null THEN null
			ELSE basisofdiagnosis::int
		END as type_source_value,
		t1.diagnosisdatebest,
		t1.cr_id
	from {SOURCE_SCHEMA}.tumour as t1
	inner join cte05 as t2 on t2.person_id = t1.patid
	where t1.grade is not null 
	AND t1.grade <> '&'
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_source_value,
	stem_source_table,
	stem_source_id
)
select distinct
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.grade as source_value,
	0 as source_concept_id,
	COALESCE(t4.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	'grade' as value_source_value,
	'Tumour-Grade' stem_source_table,
	t1.cr_id as stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.cr_id = t2.visit_detail_source_id 
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t1.type_source_value = t4.source_code::int 
and t4.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
WHERE t2.source_table = 'Tumour'
AND t1.patid = t2.person_id;

-- stage_best, stage_img, stage_path
WITH cte06 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select DISTINCT
		t1.cr_id,
		t1.patid,
		CASE 
			WHEN t1.basisofdiagnosis in ('3','9','&') and upper(t1.dco) = 'Y' THEN 0
			WHEN t1.basisofdiagnosis = '&' and upper(t1.dco) in ('N','0') THEN null
			WHEN t1.basisofdiagnosis = '&' and t1.dco is null THEN null
			ELSE t1.basisofdiagnosis::int
		END as type_source_value,
		t1.diagnosisdatebest,
		CASE
			WHEN t1.stage_best_system in ('6', '6th', 'UICC 6') THEN '6TH_AJCC/UICC-STAGE-'
			WHEN t1.stage_best_system in ('7', '7th', 'UICC 7', 'AJCC 7') THEN '7TH_AJCC/UICC-STAGE-'
			WHEN t1.stage_best_system in ('8', '8th', 'UICC 8', 'UICC 8') THEN  '8TH_AJCC/UICC-STAGE-'
			WHEN t1.stage_best_system = 'AnnArbor' THEN 'ANN_ARBOR-'
			WHEN t1.stage_best_system = 'Binet' THEN 'BINET-'
			WHEN t1.stage_best_system = 'ENETS 2007' THEN 'ENETS 2007-'
			WHEN t1.stage_best_system = 'FIGO' THEN 'FIGO-'
			WHEN t1.stage_best_system = 'ISS' THEN 'ISS-'
			ELSE 'AJCC/UICC-STAGE-'
		END as stage_best_system,
		CASE
			WHEN t1.stage_img_system in (6,21) THEN 'C-6TH_AJCC/UICC-STAGE-'
			WHEN t1.stage_img_system in (7,22,23) THEN 'C-7TH_AJCC/UICC-STAGE-'
			WHEN t1.stage_img_system in (8,25,26) THEN 'C-8TH_AJCC/UICC-STAGE-'
			WHEN t1.stage_img_system in (27) THEN 'ENETS 2007-'
			ELSE 'C-AJCC/UICC-STAGE-'
		END as stage_img_system,
		CASE
			WHEN t1.stage_path_system in (6,21) THEN 'P-6TH_AJCC/UICC-STAGE-'
			WHEN t1.stage_path_system in (7,22,23) THEN 'P-7TH_AJCC/UICC-STAGE-'
			WHEN t1.stage_path_system in (8,25,26) THEN 'P-8TH_AJCC/UICC-STAGE-'
			WHEN t1.stage_path_system in (27) THEN 'ENETS 2007-'
			ELSE 'P-AJCC/UICC-STAGE-'
		END as stage_path_system,
		upper(t1.stage_best) as stage_best, 
		upper(t1.stage_img) as stage_img, 
		upper(t1.stage_path) as stage_path
	from {SOURCE_SCHEMA}.tumour as t1
	inner join cte06 as t2 on t1.patid = t2.person_id
), cte2 as(		
	select DISTINCT cr_id, patid, type_source_value, diagnosisdatebest, --stage_best_system,
		stage_best as source_value,
		stage_best_system || stage_best as source_code, 
		'stage_best' as value_source_value
	from cte1
	where stage_best is not null 

	UNION
	
	select DISTINCT cr_id, patid, type_source_value, diagnosisdatebest, --stage_system,
		stage_img as source_value,
		stage_img_system || stage_img as source_code, 
		'stage_img' as value_source_value
	from cte1
	where stage_img is not null 

	UNION
	
	select DISTINCT cr_id, patid, type_source_value, diagnosisdatebest, --stage_system,
		stage_path as source_value,
		stage_path_system || stage_path as source_code, 
		'stage_path' as value_source_value
	from cte1
	WHERE stage_path is not null
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_source_value,
	stem_source_table,
	stem_source_id
)
select distinct
	t1.patid as person_id,
	t3.visit_occurrence_id,
	t3.visit_detail_id,
	COALESCE(t4.source_code, t1.source_code) as source_value,
	COALESCE(t4.source_concept_id, 0) as source_concept_id,
	COALESCE(t6.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	t1.value_source_value,
	'Tumour-Stage' as stem_source_table,
	t1.cr_id as stem_source_id
from cte2 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t3 on t1.cr_id = t3.visit_detail_source_id 
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t4.source_vocabulary_id = 'Cancer Modifier' 
and UPPER(t4.source_code) = t1.source_code and t4.target_domain_id = 'Measurement' -- for Athena changes target domain during STCM update
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t6 on t1.type_source_value = t6.source_code::int 
and t6.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
where t3.source_table = 'Tumour'
AND t1.patid = t3.person_id;

-- t_best, n_best, m_best
WITH cte07 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), 
cte1 as (
	select DISTINCT
	t1.cr_id,
	t1.patid,
	CASE 
		WHEN t1.basisofdiagnosis in ('3','9','&') and upper(t1.dco) = 'Y' THEN 0
		WHEN t1.basisofdiagnosis = '&' and upper(t1.dco) in ('N','0') THEN null
		WHEN t1.basisofdiagnosis = '&' and t1.dco is null THEN null
		ELSE t1.basisofdiagnosis::int
	END as type_source_value,
	t1.diagnosisdatebest,
	CASE
		WHEN t1.stage_best_system in ('6', '6th', 'UICC 6') THEN '6TH_'
		WHEN t1.stage_best_system in ('7', '7th', 'UICC 7', 'AJCC 7') THEN '7TH_'
		WHEN t1.stage_best_system in ('8', '8th', 'UICC 8', 'AJCC 8') THEN  '8TH_'
		ELSE ''
	END as stage_system,
	t1.t_best, t1.n_best, t1.m_best
	from {SOURCE_SCHEMA}.tumour as t1
	inner join cte07 as t2 on t1.patid = t2.person_id
),
cte2 as(
	select DISTINCT cr_id, patid, type_source_value, diagnosisdatebest, stage_system,
	CASE
		WHEN LEFT(t_best, 1) in ('T', 't') THEN t_best
		ELSE 'T' || t_best
	END as tnm_code,
	't_best' as modifier
	from cte1
	where t_best is not null
	
	UNION
	
	select DISTINCT cr_id, patid, type_source_value, diagnosisdatebest, stage_system,
	CASE
		WHEN LEFT(n_best, 1) in ('N', 'n') THEN n_best
		ELSE 'N' || n_best
	END as tnm_code,
	'n_best' as modifier
	from cte1
	where n_best is not null
	 
	UNION
	
	select DISTINCT cr_id, patid, type_source_value, diagnosisdatebest, stage_system,
	CASE
		WHEN LEFT(m_best, 1) in ('M', 'm') THEN m_best
		ELSE 'M' || m_best
	END as tnm_code,
	'm_best' as modifier
	from cte1
	where m_best is not null 
),
cte3 as (
	select distinct cr_id, patid, type_source_value, diagnosisdatebest, 
	CASE WHEN tnm_code = 'N+' THEN tnm_code
		 ELSE UPPER(stage_system || 'AJCC/UICC-'|| tnm_code) 
	END as source_code, 
	modifier
	from cte2
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_source_value,
	stem_source_table,
	stem_source_id
)
select 
	t1.patid as person_id,
	t3.visit_occurrence_id,
	t3.visit_detail_id,
	t1.source_code as source_value,
	COALESCE(t4.source_concept_id, 0) as source_concept_id,
	COALESCE(t5.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	modifier as value_source_value,
	'Tumour-' || modifier as stem_source_table,
	t1.cr_id as stem_source_id
from cte3 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t3 on t1.cr_id = t3.visit_detail_source_id 
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on UPPER(t4.source_code) = t1.source_code
and t4.source_vocabulary_id = 'Cancer Modifier' and t4.target_domain_id = 'Measurement' -- for Athena changes target domain during STCM update
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t5 on t1.type_source_value = t5.source_code::int 
and t5.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
where t3.source_table = 'Tumour'
AND t1.patid = t3.person_id;


-- t_img, n_img, m_img
WITH cte08 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select DISTINCT
	t1.cr_id,
	t1.patid,
	CASE 
		WHEN t1.basisofdiagnosis in ('3','9','&') and upper(t1.dco) = 'Y' THEN 0
		WHEN t1.basisofdiagnosis = '&' and upper(t1.dco) in ('N','0') THEN null
		WHEN t1.basisofdiagnosis = '&' and t1.dco is null THEN null
		ELSE t1.basisofdiagnosis::int
	END as type_source_value,
	t1.diagnosisdatebest,
	CASE
		WHEN t1.stage_img_system in (6,21) THEN 'C-6TH_AJCC/UICC-'
		WHEN t1.stage_img_system in (7,22,23) THEN 'C-7TH_AJCC/UICC-'
		WHEN t1.stage_img_system in (8,25,26) THEN 'C-8TH_AJCC/UICC-'
		WHEN t1.stage_img_system in (27) THEN 'ENETS 2007-'
		ELSE 'C-AJCC/UICC-'
	END as stage_system,
	t_img, n_img, m_img
	from {SOURCE_SCHEMA}.tumour as t1
	inner join cte08 as t2 on t1.patid = t2.person_id
), cte2 as(
	select DISTINCT cr_id, patid, type_source_value, diagnosisdatebest, stage_system,
	CASE
		WHEN LEFT(t_img, 1) in ('T', 't') THEN t_img
		ELSE 'T' || t_img
	END as tnm_code,
	't_img' as modifier
	from cte1
	where t_img is not null
	
	UNION
	
	select DISTINCT cr_id, patid, type_source_value, diagnosisdatebest, stage_system,
	CASE
		WHEN LEFT(n_img, 1) in ('N', 'n') THEN n_img
		ELSE 'N' || n_img
	END as tnm_code,
	'n_img' as modifier
	from cte1
	where n_img is not null
	
	UNION
	
	select DISTINCT cr_id, patid, type_source_value, diagnosisdatebest, stage_system,
	CASE
		WHEN LEFT(m_img, 1) in ('M', 'm') THEN m_img
		ELSE 'M' || m_img
	END as tnm_code,
	'm_img' as modifier
	from cte1
	where m_img is not null 
),
cte3 as (
	select distinct cr_id, patid, type_source_value, diagnosisdatebest, 
	stage_system || upper(tnm_code) as source_code, 
	modifier
	from cte2
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_source_value,
	stem_source_table,
	stem_source_id
)
select 
	t1.patid as person_id,
	t3.visit_occurrence_id,
	t3.visit_detail_id,
	COALESCE(t4.source_code, t1.source_code) as source_value,
	COALESCE(t4.source_concept_id, 0) as source_concept_id,
	COALESCE(t5.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	modifier as value_source_value,
	'Tumour' || '-' || modifier as stem_source_table,
	t1.cr_id as stem_source_id
from cte3 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t3 on t1.cr_id = t3.visit_detail_source_id 
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on UPPER(t4.source_code) = t1.source_code
and t4.source_vocabulary_id = 'Cancer Modifier' and t4.target_domain_id = 'Measurement' -- for Athena changes target domain during STCM update
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t5 on t1.type_source_value = t5.source_code::int 
and t5.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
where t3.source_table = 'Tumour'
AND t1.patid = t3.person_id;


-- t_path, n_path, m_path
WITH cte09 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select DISTINCT
	t1.cr_id,
	t1.patid,
	CASE 
		WHEN t1.basisofdiagnosis in ('3','9','&') and upper(t1.dco) = 'Y' THEN 0
		WHEN t1.basisofdiagnosis = '&' and upper(t1.dco) in ('N','0') THEN null
		WHEN t1.basisofdiagnosis = '&' and t1.dco is null THEN null
		ELSE t1.basisofdiagnosis::int
	END as type_source_value,
	t1.diagnosisdatebest,
	CASE
		WHEN t1.stage_path_system in (6,21) THEN 'P-6TH_AJCC/UICC-'
		WHEN t1.stage_path_system in (7,22,23) THEN 'P-7TH_AJCC/UICC-'
		WHEN t1.stage_path_system in (8,25,26) THEN 'P-8TH_AJCC/UICC-'
		WHEN t1.stage_path_system in (27) THEN 'ENETS 2007-'
		ELSE 'P-AJCC/UICC-'
	END as stage_system,
	t1.t_path, t1.n_path, t1.m_path
	from {SOURCE_SCHEMA}.tumour as t1
	join cte09 as t2 on t1.patid = t2.person_id
), cte2 as(
	select DISTINCT cr_id, patid, type_source_value, diagnosisdatebest, stage_system,
	CASE
		WHEN LEFT(t_path, 1) in ('T', 't') THEN t_path
		ELSE 'T' || t_path
	END as tnm_code,
	't_path' as modifier
	from cte1
	where t_path is not null

	UNION
	
	select DISTINCT cr_id, patid, type_source_value, diagnosisdatebest, stage_system,
	CASE
		WHEN LEFT(n_path, 1) in ('N', 'n') THEN n_path
		ELSE 'N' || n_path
	END as tnm_code,
	'n_path' as modifier
	from cte1
	where n_path is not null
	
	UNION
	
	select DISTINCT cr_id, patid, type_source_value, diagnosisdatebest, stage_system,
	CASE
		WHEN LEFT(m_path, 1) in ('M', 'm') THEN m_path
		ELSE 'M' || m_path
	END as tnm_code,
	'm_path' as modifier
	from cte1
	where m_path is not null 
),
cte3 as (
	select distinct cr_id, patid, type_source_value, diagnosisdatebest, 
	CASE WHEN tnm_code = 'N+' THEN tnm_code
		 ELSE stage_system || upper(tnm_code) 
	END as source_code, 
	modifier
	from cte2
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_source_value,
	stem_source_table,
	stem_source_id
)
select DISTINCT
	t1.patid as person_id,
	t3.visit_occurrence_id,
	t3.visit_detail_id,
	COALESCE(t4.source_code, t1.source_code) as source_value,
	COALESCE(t4.source_concept_id, 0) as source_concept_id,
	COALESCE(t5.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	modifier as value_source_value,
	'Tumour' || '-' || modifier as stem_source_table,
	t1.cr_id as stem_source_id
from cte3 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t3 on t1.cr_id = t3.visit_detail_source_id 
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on UPPER(t4.source_code) = t1.source_code 
and t4.source_vocabulary_id = 'Cancer Modifier' 
and t4.target_domain_id = 'Measurement' -- for Athena changes target domain during STCM update
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t5 on t1.type_source_value = t5.source_code::int 
and t5.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
WHERE t3.source_table = 'Tumour'
AND t1.patid = t3.person_id;

-- gleason_primary 
WITH cte010 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select DISTINCT
		t1.patid,
		CASE 
			WHEN t1.basisofdiagnosis in ('3','9','&') and upper(t1.dco) = 'Y' THEN 0
			WHEN t1.basisofdiagnosis = '&' and upper(t1.dco) in ('N','0') THEN null
			WHEN t1.basisofdiagnosis = '&' and t1.dco is null THEN null
			ELSE t1.basisofdiagnosis::int
		END as type_source_value,
		t1.diagnosisdatebest,
		t1.gleason_primary,
		t1.cr_id
	from {SOURCE_SCHEMA}.tumour as t1
	join cte010 as t2 on t1.patid = t2.person_id
	where t1.gleason_primary >= 1 and t1.gleason_primary <= 5
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_number,
	value_source_value,
	stem_source_table,
	stem_source_id
)
select DISTINCT
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.gleason_primary::text as source_value,
	0 as source_concept_id,
	COALESCE(t4.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	t1.gleason_primary as value_as_number,
	'gleason_primary' as value_source_value,
	'Tumour-Gleason Primary' as stem_source_table,
	t1.cr_id as stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.cr_id = t2.visit_detail_source_id 
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t1.type_source_value = t4.source_code::int 
and t4.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
WHERE t2.source_table = 'Tumour'
AND t1.patid = t2.person_id;

	
-- gleason_secondary 
WITH cte011 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select DISTINCT
		t1.patid,
		CASE 
			WHEN t1.basisofdiagnosis in ('3','9','&') and upper(t1.dco) = 'Y' THEN 0
			WHEN t1.basisofdiagnosis = '&' and upper(t1.dco) in ('N','0') THEN null
			WHEN t1.basisofdiagnosis = '&' and t1.dco is null THEN null
			ELSE t1.basisofdiagnosis::int
		END as type_source_value,
		t1.diagnosisdatebest,
		t1.gleason_secondary,
		t1.cr_id
	from {SOURCE_SCHEMA}.tumour as t1
	join cte011 as t2 on t1.patid = t2.person_id
	where t1.gleason_secondary >= 1 and t1.gleason_secondary <= 5
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_number,
	value_source_value,
	stem_source_table,
	stem_source_id
)
select DISTINCT
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.gleason_secondary::text as source_value,
	0 as source_concept_id,
	COALESCE(t4.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	t1.gleason_secondary as value_as_number,
	'gleason_secondary' as value_source_value,
	'Tumour-Gleason Secondary' as stem_source_table,
	t1.cr_id as stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.cr_id = t2.visit_detail_source_id 
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t1.type_source_value = t4.source_code::int 
and t4.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
WHERE t2.source_table = 'Tumour'
AND t1.patid = t2.person_id;


-- gleason_tertiary
WITH cte012 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select DISTINCT
		t1.patid,
		CASE 
			WHEN t1.basisofdiagnosis in ('3','9','&') and upper(t1.dco) = 'Y' THEN 0
			WHEN t1.basisofdiagnosis = '&' and upper(t1.dco) in ('N','0') THEN null
			WHEN t1.basisofdiagnosis = '&' and t1.dco is null THEN null
			ELSE t1.basisofdiagnosis::int
		END as type_source_value,
		t1.diagnosisdatebest,
		t1.gleason_tertiary,
		t1.cr_id
	from {SOURCE_SCHEMA}.tumour as t1
	join cte012 as t2 on t1.patid = t2.person_id
	where t1.gleason_tertiary >= 1 and t1.gleason_tertiary <= 5  
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_number,
	value_source_value,
	stem_source_table,
	stem_source_id
)
select DISTINCT
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.gleason_tertiary::text as source_value,
	0 as source_concept_id,
	COALESCE(t4.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	t1.gleason_tertiary as value_as_number,
	'gleason_tertiary' as value_source_value,
	'Tumour-Gleason Tertiary' as stem_source_table,
	t1.cr_id as stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.cr_id = t2.visit_detail_source_id
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t1.type_source_value = t4.source_code::int 
and t4.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
WHERE t2.source_table = 'Tumour'
AND t1.patid = t2.person_id;

-- final_route
WITH cte013 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select DISTINCT
		t1.patid,
		CASE 
			WHEN t1.basisofdiagnosis in ('3','9','&') and upper(t1.dco) = 'Y' THEN 0
			WHEN t1.basisofdiagnosis = '&' and upper(t1.dco) in ('N','0') THEN null
			WHEN t1.basisofdiagnosis = '&' and t1.dco is null THEN null
			ELSE t1.basisofdiagnosis::int
		END as type_source_value,
		t1.diagnosisdatebest,
		t1.final_route,
		t1.cr_id
	from {SOURCE_SCHEMA}.tumour as t1
	join cte013 as t2 on t1.patid = t2.person_id
	where t1.final_route is not null 
	and t1.final_route not in ('Unknown','DCO')
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_number,
	value_source_value,
	stem_source_table,
	stem_source_id
)
select DISTINCT
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.final_route as source_value,
	0 as source_concept_id,
	COALESCE(t3.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	null::int as value_as_number,
	'final_route' as value_source_value,
	'Tumour-Final Route' as stem_source_table,
	t1.cr_id as stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.cr_id = t2.visit_detail_source_id 
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.type_source_value = t3.source_code::int 
and t3.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
WHERE t2.source_table = 'Tumour'
AND t1.patid = t2.person_id;

--er_status
WITH cte014 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select DISTINCT
		t1.patid,
		CASE 
			WHEN t1.basisofdiagnosis in ('3','9','&') and upper(t1.dco) = 'Y' THEN 0
			WHEN t1.basisofdiagnosis = '&' and upper(t1.dco) in ('N','0') THEN null
			WHEN t1.basisofdiagnosis = '&' and t1.dco is null THEN null
			ELSE t1.basisofdiagnosis::int
		END as type_source_value,
		t1.diagnosisdatebest,
		t1.er_status,
		t1.cr_id
	from {SOURCE_SCHEMA}.tumour as t1
	join cte014 as t2 on t1.patid = t2.person_id
	where t1.er_status in ('N','P')
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_number,
	value_source_value,
	stem_source_table,
	stem_source_id
)
select DISTINCT
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.er_status as source_value,
	0 as source_concept_id,
	COALESCE(t3.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	null::int as value_as_number,
	'er_status' as value_source_value,
	'Tumour-ER Status' as stem_source_table,
	t1.cr_id as stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.cr_id = t2.visit_detail_source_id 
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.type_source_value = t3.source_code::int 
and t3.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
WHERE t2.source_table = 'Tumour'
AND t1.patid = t2.person_id;

--er_score
WITH cte015 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select DISTINCT
		t1.patid,
		CASE 
			WHEN t1.basisofdiagnosis in ('3','9','&') and upper(t1.dco) = 'Y' THEN 0
			WHEN t1.basisofdiagnosis = '&' and upper(t1.dco) in ('N','0') THEN null
			WHEN t1.basisofdiagnosis = '&' and t1.dco is null THEN null
			ELSE t1.basisofdiagnosis::int
		END as type_source_value,
		t1.diagnosisdatebest,
		t1.er_score,
		t1.cr_id
	from {SOURCE_SCHEMA}.tumour as t1
	join cte015 as t2 on t1.patid = t2.person_id
	where t1.er_score between 0 AND 8
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_number,
	value_source_value,
	stem_source_table,
	stem_source_id
)
select DISTINCT
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.er_score as source_value,
	0 as source_concept_id,
	COALESCE(t3.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	t1.er_score as value_as_number,
	'er_score' as value_source_value,
	'Tumour-ER Score' as stem_source_table,
	t1.cr_id as stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.cr_id = t2.visit_detail_source_id 
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.type_source_value = t3.source_code::int 
and t3.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
WHERE t2.source_table = 'Tumour'
AND t1.patid = t2.person_id;


--pr_status
WITH cte016 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select DISTINCT
		t1.patid,
		CASE 
			WHEN t1.basisofdiagnosis in ('3','9','&') and upper(t1.dco) = 'Y' THEN 0
			WHEN t1.basisofdiagnosis = '&' and upper(t1.dco) in ('N','0') THEN null
			WHEN t1.basisofdiagnosis = '&' and t1.dco is null THEN null
			ELSE t1.basisofdiagnosis::int
		END as type_source_value,
		t1.diagnosisdatebest,
		t1.pr_status,
		t1.cr_id
	from {SOURCE_SCHEMA}.tumour as t1
	join cte016 as t2 on t1.patid = t2.person_id
	where t1.pr_status in ('N','P')
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_number,
	value_source_value,
	stem_source_table,
	stem_source_id
)
select DISTINCT
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.pr_status as source_value,
	0 as source_concept_id,
	COALESCE(t3.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	null::int as value_as_number,
	'pr_status' as value_source_value,
	'Tumour-PR Status' as stem_source_table,
	t1.cr_id as stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.cr_id = t2.visit_detail_source_id 
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.type_source_value = t3.source_code::int 
and t3.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
WHERE t2.source_table = 'Tumour'
AND t1.patid = t2.person_id;


--pr_score
WITH cte017 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select DISTINCT
		t1.patid,
		CASE 
			WHEN t1.basisofdiagnosis in ('3','9','&') and upper(t1.dco) = 'Y' THEN 0
			WHEN t1.basisofdiagnosis = '&' and upper(t1.dco) in ('N','0') THEN null
			WHEN t1.basisofdiagnosis = '&' and t1.dco is null THEN null
			ELSE t1.basisofdiagnosis::int
		END as type_source_value,
		t1.diagnosisdatebest,
		t1.pr_score,
		t1.cr_id
	from {SOURCE_SCHEMA}.tumour as t1
	join cte017 as t2 on t1.patid = t2.person_id
	where t1.pr_score between 0 AND 8
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_number,
	value_source_value,
	stem_source_table,
	stem_source_id
)
select DISTINCT
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.pr_score as source_value,
	0 as source_concept_id,
	COALESCE(t3.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	t1.pr_score as value_as_number,
	'pr_score' as value_source_value,
	'Tumour-PR Score' as stem_source_table,
	t1.cr_id as stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.cr_id = t2.visit_detail_source_id 
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.type_source_value = t3.source_code::int 
and t3.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
WHERE t2.source_table = 'Tumour'
AND t1.patid = t2.person_id;

--her2_status
WITH cte018 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select DISTINCT
		t1.patid,
		CASE 
			WHEN t1.basisofdiagnosis in ('3','9','&') and upper(t1.dco) = 'Y' THEN 0
			WHEN t1.basisofdiagnosis = '&' and upper(t1.dco) in ('N','0') THEN null
			WHEN t1.basisofdiagnosis = '&' and t1.dco is null THEN null
			ELSE t1.basisofdiagnosis::int
		END as type_source_value,
		t1.diagnosisdatebest,
		t1.her2_status,
		t1.cr_id
	from {SOURCE_SCHEMA}.tumour as t1
	join cte018 as t2 on t1.patid = t2.person_id
	where t1.her2_status in ('N','P')
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_number,
	value_source_value,
	stem_source_table,
	stem_source_id
)
select DISTINCT
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.her2_status as source_value,
	0 as source_concept_id,
	COALESCE(t3.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	null::int as value_as_number,
	'her2_status' as value_source_value,
	'Tumour-HER2 Status' as stem_source_table,
	t1.cr_id as stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.cr_id = t2.visit_detail_source_id
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.type_source_value = t3.source_code::int 
and t3.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
WHERE t2.source_table = 'Tumour'
AND t1.patid = t2.person_id;

--dukes
WITH cte019 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select DISTINCT
		t1.patid,
		CASE 
			WHEN t1.basisofdiagnosis in ('3','9','&') and upper(t1.dco) = 'Y' THEN 0
			WHEN t1.basisofdiagnosis = '&' and upper(t1.dco) in ('N','0') THEN null
			WHEN t1.basisofdiagnosis = '&' and t1.dco is null THEN null
			ELSE t1.basisofdiagnosis::int
		END as type_source_value,
		t1.diagnosisdatebest,
		t1.dukes,
		t1.cr_id
	from {SOURCE_SCHEMA}.tumour as t1
	join cte019 as t2 on t1.patid = t2.person_id
	where t1.dukes in ('A','B','C','C1','C2','D')
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_number,
	value_source_value,
	stem_source_table,
	stem_source_id
)
select DISTINCT
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.dukes as source_value,
	0 as source_concept_id,
	COALESCE(t3.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	null::int as value_as_number,
	'dukes' as value_source_value,
	'Tumour-Dukes' as stem_source_table,
	t1.cr_id as stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.cr_id = t2.visit_detail_source_id 
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.type_source_value = t3.source_code::int 
and t3.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
WHERE t2.source_table = 'Tumour'
AND t1.patid = t2.person_id;

--figo
WITH cte020 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select DISTINCT
		t1.patid,
		CASE 
			WHEN t1.basisofdiagnosis in ('3','9','&') and upper(t1.dco) = 'Y' THEN 0
			WHEN t1.basisofdiagnosis = '&' and upper(t1.dco) in ('N','0') THEN null
			WHEN t1.basisofdiagnosis = '&' and t1.dco is null THEN null
			ELSE t1.basisofdiagnosis::int
		END as type_source_value,
		t1.diagnosisdatebest,
		CASE WHEN left(t1.figo,3) = 'III' THEN CONCAT('3',ltrim(UPPER(t1.figo),'I')) 
		WHEN left(t1.figo,2) = 'II'  THEN CONCAT('2',ltrim(UPPER(t1.figo),'I')) 
		WHEN left(t1.figo,2) = 'IV'  THEN CONCAT('4',ltrim(UPPER(t1.figo),'IV')) 
		WHEN left(t1.figo,1) = 'I'   THEN CONCAT('1',ltrim(UPPER(t1.figo),'I')) 
		ELSE UPPER(t1.figo) END AS figo,
		t1.cr_id
	from {SOURCE_SCHEMA}.tumour as t1
	join cte020 as t2 on t1.patid = t2.person_id
	where t1.figo is not null
	and t1.figo <> '3bii'
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_number,
	value_source_value,
	stem_source_table,
	stem_source_id
)
select DISTINCT
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.figo as source_value,
	0 as source_concept_id,
	COALESCE(t3.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	null::int as value_as_number,
	'figo' as value_source_value,
	'Tumour-Figo' as stem_source_table,
	t1.cr_id as stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.cr_id = t2.visit_detail_source_id 
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.type_source_value = t3.source_code::int 
and t3.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
WHERE t2.source_table = 'Tumour'
AND t1.patid = t2.person_id;

--screeningstatusfull_name
WITH cte021 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select DISTINCT
		t1.patid,
		CASE 
			WHEN t1.basisofdiagnosis in ('3','9','&') and upper(t1.dco) = 'Y' THEN 0
			WHEN t1.basisofdiagnosis = '&' and upper(t1.dco) in ('N','0') THEN null
			WHEN t1.basisofdiagnosis = '&' and t1.dco is null THEN null
			ELSE t1.basisofdiagnosis::int
		END as type_source_value,
		t1.diagnosisdatebest,
		t1.screeningstatusfull_code,
		t1.screeningstatusfull_name,
		site_icd10_o2,
		t1.cr_id
	from {SOURCE_SCHEMA}.tumour as t1
	join cte021 as t2 on t1.patid = t2.person_id
), cte2 as(
	select DISTINCT
		patid,
		type_source_value,
		diagnosisdatebest,
		screeningstatusfull_code as source_code,
		screeningstatusfull_name,
		'Tumour-Screen' as stem_source_table,		
		t1.cr_id
	from cte1 as t1
	inner join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_vocabulary_id = 'NCRAS_TUMOUR_SCREEN_STCM'
	and upper(t1.screeningstatusfull_code) = t2.source_code 
), cte3 as(
	select DISTINCT
		patid,
		type_source_value,
		diagnosisdatebest,
		t2.source_code,
		screeningstatusfull_name,
		'Tumour-Screen/Site' as stem_source_table,		
		t1.cr_id
	from cte1 as t1
	inner join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on t2.source_vocabulary_id = 'NCRAS_TUMOUR_SCREEN_SITE_STCM'
	and upper(t1.screeningstatusfull_code ||'/'|| site_icd10_o2) = t2.source_code 
),
cte4 as (
	select * from cte2
	UNION DISTINCT
	select * from cte3
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_number,
	value_source_value,
	stem_source_table,
	stem_source_id
)
select DISTINCT
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.source_code as source_value,
	0 as source_concept_id,
	COALESCE(t3.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	null::int as value_as_number,
	'screeningstatusfull_name' as value_source_value,
	t1.stem_source_table,
	t1.cr_id as stem_source_id
from cte4 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.cr_id = t2.visit_detail_source_id 
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.type_source_value = t3.source_code::int 
and t3.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
WHERE t2.source_table = 'Tumour'
AND t1.patid = t2.person_id;

--laterality
WITH cte022 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select DISTINCT
		t1.patid,
		CASE 
			WHEN t1.basisofdiagnosis in ('3','9','&') and upper(t1.dco) = 'Y' THEN 0
			WHEN t1.basisofdiagnosis = '&' and upper(t1.dco) in ('N','0') THEN null
			WHEN t1.basisofdiagnosis = '&' and t1.dco is null THEN null
			ELSE t1.basisofdiagnosis::int
		END as type_source_value,
		t1.diagnosisdatebest,
		t1.laterality,
		t1.cr_id
	from {SOURCE_SCHEMA}.tumour as t1
	join cte022 as t2 on t1.patid = t2.person_id
	where t1.laterality in ('R','L','B','M')
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_number,
	value_source_value,
	stem_source_table,
	stem_source_id
)
select DISTINCT
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.laterality as source_value,
	0 as source_concept_id,
	COALESCE(t3.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	null::int as value_as_number,
	'laterality' as value_source_value,
	'Tumour-Laterality' as stem_source_table,
	t1.cr_id as stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.cr_id = t2.visit_detail_source_id 
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.type_source_value = t3.source_code::int 
and t3.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
WHERE t2.source_table = 'Tumour'
AND t1.patid = t2.person_id;

--multifocal
WITH cte023 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select DISTINCT
		t1.patid,
		CASE 
			WHEN t1.basisofdiagnosis in ('3','9','&') and upper(t1.dco) = 'Y' THEN 0
			WHEN t1.basisofdiagnosis = '&' and upper(t1.dco) in ('N','0') THEN null
			WHEN t1.basisofdiagnosis = '&' and t1.dco is null THEN null
			ELSE t1.basisofdiagnosis::int
		END as type_source_value,
		t1.diagnosisdatebest,
		t1.multifocal,
		t1.cr_id
	from {SOURCE_SCHEMA}.tumour as t1
	join cte023 as t2 on t1.patid = t2.person_id
	where t1.multifocal in ('Y','N')
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_number,
	value_source_value,
	stem_source_table,
	stem_source_id
)
select DISTINCT
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.multifocal as source_value,
	0 as source_concept_id,
	COALESCE(t3.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	null::int as value_as_number,
	'multifocal' as value_source_value,
	'Tumour-Multifocal' as stem_source_table,
	t1.cr_id as stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.cr_id = t2.visit_detail_source_id 
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.type_source_value = t3.source_code::int 
and t3.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
WHERE t2.source_table = 'Tumour'
AND t1.patid = t2.person_id;

--clarks
WITH cte024 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select DISTINCT
		t1.patid,
		CASE 
			WHEN t1.basisofdiagnosis in ('3','9','&') and upper(t1.dco) = 'Y' THEN 0
			WHEN t1.basisofdiagnosis = '&' and upper(t1.dco) in ('N','0') THEN null
			WHEN t1.basisofdiagnosis = '&' and t1.dco is null THEN null
			ELSE t1.basisofdiagnosis::int
		END as type_source_value,
		t1.diagnosisdatebest,
		t1.clarks,
		t1.cr_id
	from {SOURCE_SCHEMA}.tumour as t1
	join cte024 as t2 on t1.patid = t2.person_id
	where t1.clarks between 1 AND 5
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_number,
	value_source_value,
	stem_source_table,
	stem_source_id
)
select DISTINCT
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.clarks as source_value,
	0 as source_concept_id,
	COALESCE(t3.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	null::int as value_as_number,
	'clarks' as value_source_value,
	'Tumour-Clarks' as stem_source_table,
	t1.cr_id as stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.cr_id = t2.visit_detail_source_id 
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.type_source_value = t3.source_code::int 
and t3.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
WHERE t2.source_table = 'Tumour'
AND t1.patid = t2.person_id;

--excisionmargin
WITH cte025 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select DISTINCT
		t1.patid,
		CASE 
			WHEN t1.basisofdiagnosis in ('3','9','&') and upper(t1.dco) = 'Y' THEN 0
			WHEN t1.basisofdiagnosis = '&' and upper(t1.dco) in ('N','0') THEN null
			WHEN t1.basisofdiagnosis = '&' and t1.dco is null THEN null
			ELSE t1.basisofdiagnosis::int
		END as type_source_value,
		t1.diagnosisdatebest,
		t1.excisionmargin,
		t1.cr_id
	from {SOURCE_SCHEMA}.tumour as t1
	join cte025 as t2 on t1.patid = t2.person_id
	where t1.excisionmargin::int in (1,2,3,4,5,7,8,9) --no mapping for 6
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_number,
	value_source_value,
	stem_source_table,
	stem_source_id
)
select DISTINCT
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.excisionmargin as source_value,
	0 as source_concept_id,
	COALESCE(t3.target_concept_id, 32879) as type_concept_id,
	t1.diagnosisdatebest as start_date,
	t1.diagnosisdatebest as end_date,
	'00:00:00'::time start_time,
	null::int as value_as_number,
	'excisionmargin' as value_source_value,
	'Tumour-Excisionmargin' as stem_source_table,
	t1.cr_id as stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.cr_id = t2.visit_detail_source_id 
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.type_source_value = t3.source_code::int 
and t3.source_vocabulary_id = 'NCRAS_TUMOUR_BASIS_DIAG_STCM'
WHERE t2.source_table = 'Tumour'
AND t1.patid = t2.person_id;

------------------------------------------------------------------
-- Treatment Modifiers 'Treatment-[modifier]' as stem_source_table
------------------------------------------------------------------
WITH cte025 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select 	t1.*
	from {SOURCE_SCHEMA}.treatment as t1
	join cte025 as t2 on t2.person_id = t1.patid
), cte2 as(
	select DISTINCT
		patid,
		eventdate,
		'lesionsize' as source_value,
		lesionsize as value_as_number,
		'mm' as unit_source_value,
		treatment_id
	from cte1
	where lesionsize is not null

	UNION

	select DISTINCT
		patid,
		eventdate,
		'number_of_tumours' as source_value,
		number_of_tumours as value_as_number,
		NULL as unit_source_value,
		treatment_id
	from cte1
	where number_of_tumours is not null
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id,  
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_number,
	unit_source_value,
	value_source_value,
	stem_source_table,
	stem_source_id
)
select DISTINCT
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.source_value,
	0 as source_concept_id,
	32879 as type_concept_id,
	t1.eventdate as start_date,
	t1.eventdate as end_date,
	'00:00:00'::time start_time,
	t1.value_as_number,
	t1.unit_source_value,
	t1.source_value as value_source_value,
	'Treatment-Modifier' as stem_source_table,
	t1.treatment_id as stem_source_id
from cte2 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.treatment_id::varchar = t2.visit_detail_source_id 
WHERE t2.source_table = 'Treatment'
AND t1.patid = t2.person_id;


------------------------------
-- within_six_months_flag 
-- six_months_after_flag 
------------------------------
WITH cte026 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select t1.*
	from {SOURCE_SCHEMA}.treatment as t1
	join cte026 as t2 on t2.person_id = t1.patid
), cte2 as(
	select DISTINCT
		patid,
		'within_six_months_flag' as source_value,
		eventdate,
		CASE 
			WHEN within_six_months_flag = 0 THEN 'N'
			WHEN within_six_months_flag = 1 THEN 'Y'
		END as value_as_string,
		'<=' as qualifier_source_value,
		4171754 as qualifier_concept_id,
		treatment_id
	from cte1
	
	UNION
	
	select DISTINCT
		patid,
		'six_months_after_flag' as source_value,
		eventdate,
		CASE 
			WHEN six_months_after_flag = 0 THEN 'N'
			WHEN six_months_after_flag = 1 THEN 'Y'
		END as value_as_string,
		'>' as qualifier_source_value,
		4172704 as qualifier_concept_id,
		treatment_id
	from cte1
	
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id,  
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_as_string,
	value_as_number,
	unit_source_value,
	qualifier_source_value,
	qualifier_concept_id,
	value_source_value,
	stem_source_table,
	stem_source_id
)
select DISTINCT
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.source_value,
	0 as source_concept_id,
	32879 as type_concept_id,
	t1.eventdate as start_date,
	t1.eventdate as end_date,
	'00:00:00'::time start_time,
	t1.value_as_string,
	6 as value_as_number,
	'month' as unit_source_value,
	t1.qualifier_source_value,
	t1.qualifier_concept_id,
	t3.source_code_description as value_source_value,
	'Treatment-Modifier' as stem_source_table,
	treatment_id as stem_source_id
from cte2 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.treatment_id::varchar = t2.visit_detail_source_id 
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t3.source_code = t1.source_value 
and t3.source_vocabulary_id = 'NCRAS_TREATMENT_MODIFIER_STCM'
WHERE t2.source_table = 'Treatment'
AND t1.patid = t2.person_id;

------------------------------
-- Imagingcode
------------------------------
WITH cte027 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select 	t1.*
	from {SOURCE_SCHEMA}.treatment as t1
	inner join cte027 as t2 on t2.person_id = t1.patid
	WHERE imagingcode is not null
), cte2 as(
	select DISTINCT
		patid,
		eventdate,
		imagingcode as source_value,
		imagingcode || '/' || imagingsite as cz_source_value,
		treatment_id
	from cte1
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id,  
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_source_value,
	stem_source_table,
	stem_source_id
)
select DISTINCT
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.source_value,
	0 as source_concept_id,
	32879 as type_concept_id,
	t1.eventdate as start_date,
	t1.eventdate as end_date,
	'00:00:00'::time start_time,
	t4.source_code_description as value_source_value,
	'Treatment-Imagingcode' as stem_source_table,
	treatment_id as stem_source_id
from cte2 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.treatment_id::varchar = t2.visit_detail_source_id 
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on upper(t3.source_code) = upper(t1.cz_source_value)
and t3.source_vocabulary_id = 'NCRAS_TREATMENT_SITE_CZ00_STCM'
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on upper(t4.source_code) = upper(t1.source_value)
and t4.source_vocabulary_id = 'NCRAS_TREATMENT_IMAGING_STCM' 
WHERE t2.source_table = 'Treatment'
AND t1.patid = t2.person_id
AND t3.source_code is null;

------------------------------
-- Imagingsite
------------------------------
WITH cte028 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select 	t1.*
	from {SOURCE_SCHEMA}.treatment as t1
	join cte028 as t2 on t2.person_id = t1.patid
	WHERE imagingsite is not null
	AND imagingsite !~'^CZ00' --CZ001 = Whole body / CZ002 = Multiple sites
), cte2 as(
	select DISTINCT
		patid,
		eventdate,
		imagingsite as source_value,
		treatment_id
	from cte1
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id,  
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_source_value,
	stem_source_table,
	stem_source_id
)
select DISTINCT
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	COALESCE(t3.source_code,t1.source_value) as source_value,
	COALESCE(t3.source_concept_id, 0) as source_concept_id,
	32879 as type_concept_id,
	t1.eventdate as start_date,
	t1.eventdate as end_date,
	'00:00:00'::time start_time,
	t3.source_code_description as value_source_value,
	'Treatment-Imagingsite' as stem_source_table,
	treatment_id as stem_source_id
from cte2 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.treatment_id::varchar = t2.visit_detail_source_id 
left join {VOCABULARY_SCHEMA}.source_to_source_vocab_map as t3 on replace(t3.source_code,'.','') = t1.source_value --use source_to_source to include those present in Athena without a standard concept_id
and t3.source_vocabulary_id = 'OPCS4'
WHERE t2.source_table = 'Treatment'
AND t1.patid = t2.person_id;
	
------------------------------
-- Imagingsite / Imagingcode - 'CZ00'
------------------------------
WITH cte029 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
), cte1 as(
	select 	t1.*
	from {SOURCE_SCHEMA}.treatment as t1
	inner join cte029 as t2 on t2.person_id = t1.patid
	WHERE imagingsite ~'^CZ00' --CZ001 = Whole body / CZ002 = Multiple sites
	AND imagingcode is not null
), cte2 as(
	select DISTINCT
		patid,
		eventdate,
		imagingcode || '/' || imagingsite as source_value,
		CASE WHEN imagingsite = 'CZ001' THEN imagingdesc || '/' || 'Whole body'
			 WHEN imagingsite = 'CZ002' THEN imagingdesc || '/' || 'Multiple sites'
		END as imagingdesc_cz,
		treatment_id
	from cte1
), cte3 as(
		select t1.patid, t1.eventdate, t1.source_value, t1.treatment_id,
		COALESCE(t2.source_code_description,t1.imagingdesc_cz) as value_source_value
		from cte2 as t1
		inner join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on upper(t2.source_code) = upper(t1.source_value)
		and t2.source_vocabulary_id = 'NCRAS_TREATMENT_SITE_CZ00_STCM'	
), cte4 as (
		select DISTINCT
		t1.patid,
		t1.eventdate,
		CASE WHEN imagingsite = 'CZ001' THEN imagingsite
			 WHEN imagingsite = 'CZ002' THEN 'CZ002 - Multiple sites'
		END as source_value,
		t1.treatment_id
		from cte1 as t1
		left join cte3 as t2 on t1.patid = t2.patid and t1.eventdate = t2.eventdate and t1.treatment_id = t2.treatment_id
		WHERE t2.patid is null
), cte5 as (
		select t1.*,
		COALESCE(t2.source_code_description,'') as value_source_value
		from cte4 as t1
		left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on upper(t2.source_code) = upper(t1.source_value)
		and t2.source_vocabulary_id = 'NCRAS_TREATMENT_SITE_CZ00_STCM'
), cte6 as (
	select * from cte3
	UNION DISTINCT
	select * from cte5
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id,  
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	value_source_value,
	stem_source_table,
	stem_source_id
)
select DISTINCT
	t1.patid as person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.source_value,
	0 as source_concept_id,
	32879 as type_concept_id,
	t1.eventdate as start_date,
	t1.eventdate as end_date,
	'00:00:00'::time start_time,
	value_source_value,
	'Treatment-CZ00' as stem_source_table,
	treatment_id as stem_source_id
from cte6 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.treatment_id::varchar = t2.visit_detail_source_id 
WHERE t2.source_table = 'Treatment'
AND t1.patid = t2.person_id;

create index idx_stem_source_{CHUNK_ID}_1 on {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (source_concept_id)  TABLESPACE pg_default;
create index idx_stem_source_{CHUNK_ID}_2 on {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (source_value) TABLESPACE pg_default;
create index idx_stem_source_{CHUNK_ID}_3 on {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (stem_source_table) TABLESPACE pg_default;

-----------------------------------------
-- UPDATE CHUNK
-----------------------------------------
update {CHUNK_SCHEMA}.chunk 
set stem_source_tbl = concat('stem_source_',{CHUNK_ID}::varchar)
where chunk_id = {CHUNK_ID};