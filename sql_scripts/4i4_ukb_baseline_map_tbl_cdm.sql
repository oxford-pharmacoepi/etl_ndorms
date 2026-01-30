--------------------------------
-- Map Baseline Measurements to Measurement
--------------------------------

-- SEQUENCE for ukb baseline Measurement
DROP SEQUENCE IF EXISTS {SOURCE_SCHEMA}.measurement_seq;
CREATE SEQUENCE {SOURCE_SCHEMA}.measurement_seq as bigint START WITH 1 INCREMENT BY 1 NO MAXVALUE CACHE 1;

truncate table {TARGET_SCHEMA}.measurement;

with cte as (
-- TOWNSEND DEPRIVATION INDEX
	select distinct eid as person_id, 
	p53_i0 as measurement_date, ---- Initial assessment visit (2006-2010) at which participants were recruited and consent given
	p22189 as value_as_number,
	'p22189' as source_code,
	NULL as unit_source_value,
	NULL::int as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p22189 IS NOT NULL
UNION ALL 
-- BMI
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p21001 as value_as_number,
	'p21001' as source_code,
	'kg/m2' as unit_source_value,
	9531 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p21001 IS NOT NULL
UNION ALL 
-- Alanine aminotransferase
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30620 as value_as_number,
	'p30620' as source_code,
	'U/L' as unit_source_value,
	8645 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30620 IS NOT NULL
UNION ALL 
--Albumin
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30600 as value_as_number,
	'p30600' as source_code,
	'g/L' as unit_source_value,
	8636 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30600 IS NOT NULL
UNION ALL 
--Alkaline phosphatase
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30610 as value_as_number,
	'p30610' as source_code,
	'U/L' as unit_source_value,
	8645 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30610 IS NOT NULL
UNION ALL 
--Apolipoprotein A
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30630 as value_as_number,
	'p30630' as source_code,
	'g/L' as unit_source_value,
	8636 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30630 IS NOT NULL
UNION ALL 
--Apolipoprotein B
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30640 as value_as_number,
	'p30640' as source_code,
	'g/L' as unit_source_value,
	8636 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30640 IS NOT NULL
UNION ALL 
--Aspartate aminotransferase
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30650 as value_as_number,
	'p30650' as source_code,
	'U/L' as unit_source_value,
	8645 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30650 IS NOT NULL
UNION ALL 
--C-reactive protein
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30710 as value_as_number,
	'p30710' as source_code,
	'mg/L' as unit_source_value,
	8751 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30710 IS NOT NULL
UNION ALL 
--Calcium
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30680 as value_as_number,
	'p30680' as source_code,
	'mmol/L' as unit_source_value,
	8753 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30680 IS NOT NULL
UNION ALL 
--Cholesterol
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30690 as value_as_number,
	'p30690' as source_code,
	'mmol/L' as unit_source_value,
	8753 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30690 IS NOT NULL
UNION ALL 
--Creatinine
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30700 as value_as_number,
	'p30700' as source_code,
	'µmol/L' as unit_source_value,
	8749 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30700 IS NOT NULL
UNION ALL 
--Cystatin C
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30720 as value_as_number,
	'p30720' as source_code,
	'mg/L' as unit_source_value,
	8751 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30720 IS NOT NULL
UNION ALL 
--Direct bilirubin
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30660 as value_as_number,
	'p30660' as source_code,
	'µmol/L' as unit_source_value,
	8749 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30660 IS NOT NULL
UNION ALL 
--Gamma glutamyltransferase
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30730 as value_as_number,
	'p30730' as source_code,
	'U/L' as unit_source_value,
	8645 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30730 IS NOT NULL
UNION ALL 
--Glucose
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30740 as value_as_number,
	'p30740' as source_code,
	'mmol/L' as unit_source_value,
	8753 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30740 IS NOT NULL
UNION ALL 
--Glycated haemoglobin (HbA1c)
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30750 as value_as_number,
	'p30750' as source_code,
	'mmol/mol' as unit_source_value,
	9579 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30750 IS NOT NULL
UNION ALL 
--Cholesterol HDL
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30760 as value_as_number,
	'p30760' as source_code,
	'mmol/L' as unit_source_value,
	8753 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30760 IS NOT NULL
UNION ALL 
--IGF-1
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30770 as value_as_number,
	'p30770' as source_code,
	'nmol/L' as unit_source_value,
	8736 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30770 IS NOT NULL
UNION ALL 
--LDL direct
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30780 as value_as_number,
	'p30780' as source_code,
	'mmol/L' as unit_source_value,
	8753 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30780 IS NOT NULL
UNION ALL 
--Lipoprotein A	
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30790 as value_as_number,
	'p30790' as source_code,
	'nmol/L' as unit_source_value,
	8736 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30790 IS NOT NULL
UNION ALL 
--Oestradiol
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30800 as value_as_number,
	'p30800' as source_code,
	'pmol/L' as unit_source_value,
	8729 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30800 IS NOT NULL
UNION ALL 
--Phosphate
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30810 as value_as_number,
	'p30810' as source_code,
	'mmol/L' as unit_source_value,
	8753 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30810 IS NOT NULL
UNION ALL 
--Rheumatoid factor
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30820 as value_as_number,
	'p30820' as source_code,
	'iU/mL' as unit_source_value,
	8985 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30820 IS NOT NULL
UNION ALL 
--SHBG
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30830 as value_as_number,
	'p30830' as source_code,
	'nmol/L' as unit_source_value,
	8736 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30830 IS NOT NULL
UNION ALL 
--Testosterone
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30850 as value_as_number,
	'p30850' as source_code,
	'nmol/L' as unit_source_value,
	8736 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30850 IS NOT NULL
UNION ALL 
--Total bilirubin
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30840 as value_as_number,
	'p30840' as source_code,
	'µmol/L' as unit_source_value,
	8749 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30840 IS NOT NULL
UNION ALL 
--Total protein
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30860 as value_as_number,
	'p30860' as source_code,
	'g/L' as unit_source_value,
	8636 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30860 IS NOT NULL 
UNION ALL 
--Triglycerides
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30870 as value_as_number,
	'p30870' as source_code,
	'mmol/L' as unit_source_value,
	8753 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30870 IS NOT NULL
UNION ALL 
--Urate
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30880 as value_as_number,
	'p30880' as source_code,
	'µmol/L' as unit_source_value,
	8749 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30880 IS NOT NULL
UNION ALL 
--Urea
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30670 as value_as_number,
	'p30670' as source_code,
	'mmol/L' as unit_source_value,
	8753 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30670 IS NOT NULL
UNION ALL 
--Vitamin D
	select distinct eid as person_id, 
	p53_i0 as measurement_date,
	p30890 as value_as_number,
	'p30890' as source_code,
	'nmol/L' as unit_source_value,
	8736 as unit_concept_id
	from {SOURCE_SCHEMA}.baseline
	where p30890 IS NOT NULL
)
insert into {TARGET_SCHEMA}.measurement
select 
	nextval('{SOURCE_SCHEMA}.measurement_seq') as measurement_id,
	t1.person_id,
	t4.target_concept_id as measurement_concept_id,
	t1.measurement_date,
	t1.measurement_date as measurement_datetime,
	NULL as measurement_time,
	32880 as measurement_type_concept_id,
	NULL::int as operator_concept_id,
	t1.value_as_number,
	NULL::int as value_as_concept_id,
	t1.unit_concept_id,  
	NULL::int as range_low,
	NULL::int as range_high,
	NULL::int as provider_id,
	t3.visit_occurrence_id as visit_occurrence_id,
	t3.visit_detail_id as visit_detail_id,
	t4.source_code as measurement_source_value,
	t4.source_concept_id as measurement_source_concept_id,	
	t1.unit_source_value, 
	NULL::int as unit_source_concept_id,
	NULL as value_source_value,
	NULL::bigint as measurement_event_id,
	NULL::int as meas_event_field_concept_id
from cte as t1
inner join {TARGET_SCHEMA}.observation_period as t2 on t1.person_id = t2.person_id
inner join {TARGET_SCHEMA}.visit_detail as t3 on t1.person_id = t3.person_id and t1.measurement_date = t3.visit_detail_start_date
inner join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t1.source_code = t4.source_code 
where t1.measurement_date >= t2.observation_period_start_date 
and t1.measurement_date <= t2.observation_period_end_date
and t4.source_vocabulary_id = 'UKB_BASE_MEASUREMENT_STCM';

DROP SEQUENCE IF EXISTS {SOURCE_SCHEMA}.measurement_seq;


-- SEQUENCE for ukb baseline Observation
DROP SEQUENCE IF EXISTS {SOURCE_SCHEMA}.observation_seq;
CREATE SEQUENCE {SOURCE_SCHEMA}.observation_seq as bigint START WITH 1 INCREMENT BY 1 NO MAXVALUE CACHE 1;

truncate table {TARGET_SCHEMA}.observation;

--------------------------------
-- Map Baseline "Smoking Status" Answers to Observation
-- This answer are the result of a manual merging and the answers are not in UK Biobank vocabulary
--------------------------------
--	0	Never				
--	1	Previous			
--	2	Current				
--	-3	Prefer not to say	
--------------------------------
-- SMOKING STATUS
with cte as (
	select distinct eid as person_id, 
	p53_i0 as observation_date,
	'p20116' as observation_source_value, 	-- source question
	p20116 as qualifier_source_value,		-- source coded answer
	'Never smoker' as value_source_value	-- source answer
	from {SOURCE_SCHEMA}.baseline
	WHERE p20116 = 0 	-- Never
UNION ALL
	select distinct eid as person_id, 
	p53_i0 as observation_date,
	'p20116' as observation_source_value, 	-- source question
	p20116 as qualifier_source_value,		-- source coded answer
	'Former smoker' as value_source_value	-- source answer
	from {SOURCE_SCHEMA}.baseline
	WHERE p20116 = 1	-- Previous
UNION ALL
	select distinct eid as person_id, 
	p53_i0 as observation_date,
	'p20116' as observation_source_value, 	-- source question
	p20116 as qualifier_source_value,		-- source coded answer
	'Current smoker' as value_source_value	-- source answer
	from {SOURCE_SCHEMA}.baseline
	WHERE p20116 = 2	-- Current
)
insert into {TARGET_SCHEMA}.observation 
SELECT 
	nextval('{SOURCE_SCHEMA}.observation_seq') as observation_id,
	t1.person_id,
	t4.target_concept_id as observation_concept_id,	
	t1.observation_date,
	t1.observation_date as observation_datetime,
	32880 as observation_type_concept_id,
	NULL as value_as_number,
	NULL as value_as_string,	
	NULL::bigint value_as_concept_id,
	NULL::bigint qualifier_concept_id,
	NULL::bigint as unit_concept_id,		
	NULL::bigint provider_id,
	t3.visit_occurrence_id,
	t3.visit_detail_id,
	t1.observation_source_value,				-- source question
	NULL::bigint observation_source_concept_id,
	NULL as unit_source_value,
	t1.qualifier_source_value,					-- coded source answer
	t1.value_source_value,						-- source answer
	NULL::bigint as observation_event_id,
	NULL::bigint as obs_event_field_concept_id
from cte as t1
inner join {TARGET_SCHEMA}.observation_period as t2 on t1.person_id = t2.person_id
inner join {TARGET_SCHEMA}.visit_detail as t3 on t1.person_id = t3.person_id and t1.observation_date = t3.visit_detail_start_date
inner join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t1.qualifier_source_value::varchar = t4.source_code 
where t1.observation_date >= t2.observation_period_start_date 
and t1.observation_date <= t2.observation_period_end_date
and t4.source_vocabulary_id = 'UKB_BASE_SMOKER_STCM';

--------------------------------
-- Map Baseline "Alcohol intake frequency" Answers to Observation
-- Question was: About how often do you drink alcohol?"
--------------------------------
with cte as (
	select distinct t1.eid as person_id, 
	t1.p53_i0 as observation_date,
	'p1558' as observation_source_value,  				-- source question
	t2.target_concept_id as observation_concept_id,		-- mapped question
	t1.p1558 as qualifier_source_value					-- source coded answer
	from {SOURCE_SCHEMA}.baseline as t1
	inner join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t2 on 'p1558' = t2.source_code 
	where t1.p1558 between 1 and 6
	and t2.source_vocabulary_id = 'UKB_BASE_ALCOHOL_INTAKE_STCM'
)
insert into {TARGET_SCHEMA}.observation 
SELECT 
	nextval('{SOURCE_SCHEMA}.observation_seq') as observation_id,
	t1.person_id,
	t1.observation_concept_id,							-- mapped question
	t1.observation_date,
	t1.observation_date as observation_datetime,
	32880 as observation_type_concept_id,
	NULL as value_as_number,
	NULL AS value_as_string,	
	t4.target_concept_id as value_as_concept_id,		-- mapped answer
	NULL::bigint qualifier_concept_id,
	NULL::bigint as unit_concept_id,		
	NULL::bigint provider_id,
	t3.visit_occurrence_id,
	t3.visit_detail_id,
	t1.observation_source_value,						-- source question
	NULL::bigint as observation_source_concept_id,
	NULL as unit_source_value,
	t1.qualifier_source_value,							-- source coded answer
	t4.source_code_description as value_source_value,
	NULL::bigint as observation_event_id,
	NULL::bigint as obs_event_field_concept_id
FROM cte as t1
inner join {TARGET_SCHEMA}.observation_period as t2 on t1.person_id = t2.person_id
inner join {TARGET_SCHEMA}.visit_detail as t3 on t1.person_id = t3.person_id and t1.observation_date = t3.visit_detail_start_date
inner join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t4 on t1.qualifier_source_value::varchar = t4.source_code 
where t1.observation_date >= t2.observation_period_start_date 
and t1.observation_date <= t2.observation_period_end_date
and t4.source_vocabulary_id = 'UKB_BASE_ALCOHOL_INTAKE_STCM';


DROP SEQUENCE IF EXISTS {SOURCE_SCHEMA}.observation_seq;
