CREATE TABLE {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (LIKE {TARGET_SCHEMA}.STEM_SOURCE);

-------------------------------------------
--insert into stem_source table from RTDS
-------------------------------------------
-- EPISODE - radiotherapy prescription / planning (prescriptionid)
WITH cte01 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
),
cte1 as (
	select t2.e_patid as person_id, 
	MIN(t2.treatmentstartdate) as start_date, 
	'prescriptionid' as source_value, 
	t2.prescriptionid as value_as_number,
	'prescriptionid' as value_source_value,
	t2.prescriptionid as stem_source_id
	from cte01 as t1
	inner join {SOURCE_SCHEMA}.rtds as t2 on t1.person_id = t2.e_patid
	WHERE (radiotherapydiagnosisicd is null OR upper(radiotherapydiagnosisicd) = 'C61') --only prostate cancer diagnoses in this case
	AND prescriptionid is not null
	group by t2.e_patid, t2.prescriptionid
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	value_as_number,
	value_source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	stem_source_table,
	stem_source_id
)
select distinct
	t1.person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.source_value,
	value_as_number,
	t1.value_source_value,
	0 as source_concept_id,	
	32879 as type_concept_id, 		--Registry
	t1.start_date,
	t1.start_date as end_date,
	'00:00:00'::time start_time,
	t2.source_table as stem_source_table,
	t1.stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.person_id = t2.person_id AND t1.start_date = t2.visit_start_date
WHERE t2.source_table = 'RTDS'
AND t1.stem_source_id = t2.visit_detail_source_id;


-- EPISODE - radiotherapyintent
WITH cte01 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
),
cte1 as (
	select t2.e_patid as person_id, 
	MIN(t2.treatmentstartdate) as start_date, 
	t2.radiotherapyintent as source_value, 
	'radiotherapyintent' as value_source_value,
	t2.prescriptionid as stem_source_id
	from cte01 as t1
	inner join {SOURCE_SCHEMA}.rtds as t2 on t1.person_id = t2.e_patid
	WHERE (radiotherapydiagnosisicd is null OR upper(radiotherapydiagnosisicd) = 'C61') --only prostate cancer diagnoses in this case
	AND radiotherapyintent is not null
	group by t2.e_patid, t2.prescriptionid, t2.radiotherapyintent

)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	value_source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	stem_source_table,
	stem_source_id
)
select distinct
	t1.person_id,
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.source_value,
	t1.value_source_value,
	0 as source_concept_id,
	32879 as type_concept_id, 		--Registry
	t1.start_date,
	t1.start_date as end_date,
	'00:00:00'::time start_time,
	t2.source_table as stem_source_table,
	t1.stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.person_id = t2.person_id AND t1.start_date = t2.visit_start_date
WHERE t2.source_table = 'RTDS'
AND t1.stem_source_id = t2.visit_detail_source_id;


--PRESCRIPTION - rttreatmentregion
WITH cte02 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
),
cte1 as (
	select t2.e_patid as person_id, 
	MIN(t2.treatmentstartdate) as start_date, 
	CASE WHEN UPPER(t2.rttreatmentregion) in ('P', 'PR', 'R') THEN UPPER(t2.rttreatmentregion) end as source_value,
	CASE WHEN UPPER(t2.rttreatmentregion) in ('P', 'PR', 'R') THEN 'rttreatmentregion' end as value_source_value,
	t2.prescriptionid as stem_source_id
	from cte02 as t1
	inner join {SOURCE_SCHEMA}.rtds as t2 on t1.person_id = t2.e_patid
	WHERE (radiotherapydiagnosisicd is null OR upper(radiotherapydiagnosisicd) = 'C61')
	AND UPPER(rttreatmentregion) in ('P', 'PR', 'R')
	group by t2.e_patid, t2.prescriptionid, t2.rttreatmentregion
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id, 
	visit_detail_id, 
	source_value,
	value_source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	stem_source_table,
	stem_source_id
)
select distinct
	t1.person_id, 
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.source_value,
	t1.value_source_value,
	0 as source_concept_id,
	32879 as type_concept_id, --Registry
	t1.start_date,
	t1.start_date as end_date,
	'00:00:00'::time start_time,
	t2.source_table as stem_source_table,
	t1.stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.person_id = t2.person_id AND t1.start_date = t2.visit_start_date
WHERE t2.source_table = 'RTDS'
AND t1.stem_source_id = t2.visit_detail_source_id;

--PRESCRIPTION - rttreatmentanatomicalsite - The part of the body to which the radiotherapy actual dose is administered. 
--Only complete where the treatment region is A, O or M. OPCS Z codes

WITH cte03 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
),
cte1 as (
	select t2.e_patid as person_id, 
	MIN(t2.treatmentstartdate) as start_date, 
	CASE WHEN length(t2.rttreatmentanatomicalsite) = 4 
		THEN CONCAT(UPPER(LEFT(t2.rttreatmentanatomicalsite,3)),'.',RIGHT(t2.rttreatmentanatomicalsite,1)) 
		ELSE UPPER(t2.rttreatmentanatomicalsite) 
	END as source_value,
	'rttreatmentanatomicalsite' as value_source_value,
	t2.prescriptionid as stem_source_id
	from cte03 as t1
	inner join {SOURCE_SCHEMA}.rtds as t2 on t1.person_id = t2.e_patid
	WHERE (radiotherapydiagnosisicd is null OR upper(radiotherapydiagnosisicd) = 'C61')
	AND rttreatmentregion in ('A', 'O', 'M') AND rttreatmentanatomicalsite is not null
	group by t2.e_patid, t2.prescriptionid, t2.rttreatmentanatomicalsite
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id, 
	visit_detail_id, 
	source_value,
	value_source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	stem_source_table,
	stem_source_id
)
select distinct
	t1.person_id, 
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.source_value,
	t1.value_source_value,
	COALESCE(t3.source_concept_id, 0) as source_concept_id,
	32879 as type_concept_id, --Registry
	t1.start_date,
	t1.start_date as end_date,
	'00:00:00'::time start_time,
	t2.source_table as stem_source_table,
	t1.stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.person_id = t2.person_id AND t1.start_date = t2.visit_start_date
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.source_value = t3.source_code AND upper(t3.source_vocabulary_id) = 'OPCS4'
WHERE t2.source_table = 'RTDS'
AND t1.stem_source_id = t2.visit_detail_source_id;


--PRESCRIPTION - numberofteletherapyfields
WITH cte04 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
),
cte1 as (
	select t2.e_patid as person_id, 
	MIN(t2.treatmentstartdate) as start_date, 
	CASE WHEN t2.numberofteletherapyfields = 1 THEN 'numberofteletherapyfields1'
		 WHEN t2.numberofteletherapyfields = 2 THEN 'numberofteletherapyfields2'
		 WHEN t2.numberofteletherapyfields = 3 THEN 'numberofteletherapyfields3'
		 WHEN t2.numberofteletherapyfields = 4 THEN 'numberofteletherapyfields4'
		 ELSE 'numberofteletherapyfields' END as source_value,
	t2.numberofteletherapyfields as value_as_number,
	'numberofteletherapyfields' as value_source_value,
	t2.prescriptionid as stem_source_id
	from cte04 as t1
	inner join {SOURCE_SCHEMA}.rtds as t2 on t1.person_id = t2.e_patid
	WHERE (radiotherapydiagnosisicd is null OR upper(radiotherapydiagnosisicd) = 'C61')
	AND t2.numberofteletherapyfields is not null AND t2.numberofteletherapyfields <> 0
	group by t2.e_patid, t2.prescriptionid, t2.numberofteletherapyfields
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id, 
	visit_detail_id, 
	source_value,
	value_as_number,
--	value_source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	stem_source_table,
	stem_source_id
)
select distinct
	t1.person_id, 
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.source_value,
	t1.value_as_number,
--	t1.value_source_value,
	0 as source_concept_id,
	32879 as type_concept_id, --Registry
	t1.start_date,
	t1.start_date as end_date,
	'00:00:00'::time start_time,
	t2.source_table as stem_source_table,
	t1.stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.person_id = t2.person_id AND t1.start_date = t2.visit_start_date
WHERE t2.source_table = 'RTDS'
AND t1.stem_source_id = t2.visit_detail_source_id;


--PRESCRIPTION - rtprescribeddose
WITH cte05 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
),
cte1 as (
	select t2.e_patid as person_id, 
	MIN(t2.treatmentstartdate) as start_date, 
	'rtprescribeddose' as source_value, 
	t2.rtprescribeddose as value_as_number,
	'rtprescribeddose' as value_source_value,
	t2.prescriptionid as stem_source_id
	from cte05 as t1
	inner join {SOURCE_SCHEMA}.rtds as t2 on t1.person_id = t2.e_patid 
	WHERE (radiotherapydiagnosisicd is null OR upper(radiotherapydiagnosisicd) = 'C61')
	AND rtprescribeddose is not null AND rtprescribeddose <> 0
	group by t2.e_patid, t2.prescriptionid, t2.rtprescribeddose
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id, 
	visit_detail_id, 
	source_value,
	value_as_number,
	value_source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	unit_concept_id, 
	unit_source_value, 
	stem_source_table,
	stem_source_id
)
select distinct
	t1.person_id, 
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.source_value,
	t1.value_as_number,
	t1.value_source_value,
	0 as source_concept_id,
	32879 as type_concept_id, --Registry
	t1.start_date,
	t1.start_date as end_date,
	'00:00:00'::time start_time,
	9519 as unit_concept_id, 
	'Gray' as unit_source_value, 
	t2.source_table as stem_source_table,
	t1.stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.person_id = t2.person_id AND t1.start_date = t2.visit_start_date
WHERE t2.source_table = 'RTDS'
AND t1.stem_source_id = t2.visit_detail_source_id;


--PRESCRIPTION - prescribedfractions
WITH cte06 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
),
cte1 as (
	select t2.e_patid as person_id, 
	MIN(t2.treatmentstartdate) as start_date, 
	'prescribedfractions' as source_value, 
	t2.prescribedfractions as value_as_number,
	'prescribedfractions' as value_source_value,
	t2.prescriptionid as stem_source_id
	from cte06 as t1
	inner join {SOURCE_SCHEMA}.rtds as t2 on t1.person_id = t2.e_patid
	WHERE (radiotherapydiagnosisicd is null OR upper(radiotherapydiagnosisicd) = 'C61')
	AND prescribedfractions is not null AND prescribedfractions <> 0
	group by t2.e_patid, t2.prescriptionid, t2.prescribedfractions
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id, 
	visit_detail_id, 
	source_value,
	value_as_number,
	value_source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	stem_source_table,
	stem_source_id
)
select distinct
	t1.person_id, 
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.source_value,
	t1.value_as_number,
	t1.value_source_value,
	0 as source_concept_id,
	32879 as type_concept_id, --Registry
	t1.start_date,
	t1.start_date as end_date,
	'00:00:00'::time start_time,
	t2.source_table as stem_source_table,
	t1.stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.person_id = t2.person_id AND t1.start_date = t2.visit_start_date
WHERE t2.source_table = 'RTDS'
AND t1.stem_source_id = t2.visit_detail_source_id;

--PRESCRIPTION - rtactualdose
WITH cte07 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
),
cte1 as (
	select t2.e_patid as person_id, 
--	t2.prescriptionid, 
	MIN(treatmentstartdate) as start_date, 
	'rtactualdose' as source_value, 
	t2.rtactualdose as value_as_number,
	'rtactualdose' as value_source_value,
	t2.prescriptionid as stem_source_id
	from cte07 as t1
	inner join {SOURCE_SCHEMA}.rtds as t2 on t1.person_id = t2.e_patid
	WHERE (radiotherapydiagnosisicd is null OR upper(radiotherapydiagnosisicd) = 'C61')
	AND rtactualdose is not null AND rtactualdose <> 0
	group by t2.e_patid, t2.prescriptionid, t2.rtactualdose
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id, 
	visit_detail_id, 
	source_value,
	value_as_number,
	value_source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time,
	unit_concept_id, 
	unit_source_value, 
	stem_source_table,
	stem_source_id
)
select distinct
	t1.person_id, 
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.source_value,
	t1.value_as_number,
	t1.value_source_value,
	0 as source_concept_id,
	32879 as type_concept_id, --Registry
	t1.start_date,
	t1.start_date as end_date,
	'00:00:00'::time start_time,
	9519 as unit_concept_id, 
	'Gray' as unit_source_value, 
	t2.source_table as stem_source_table,
	t1.stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.person_id = t2.person_id AND t1.start_date = t2.visit_start_date
WHERE t2.source_table = 'RTDS'
AND t1.stem_source_id = t2.visit_detail_source_id;


--PRESCRIPTION - actualfractions
WITH cte08 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
),
cte1 as (
	select t2.e_patid as person_id, 
--	t2.prescriptionid, 
	MIN(treatmentstartdate) as start_date, 
	'actualfractions' as source_value, 
	t2.actualfractions as value_as_number,
	'actualfractions' as value_source_value,
	t2.prescriptionid as stem_source_id
	from cte08 as t1
	inner join {SOURCE_SCHEMA}.rtds as t2 on t1.person_id = t2.e_patid
	WHERE (radiotherapydiagnosisicd is null OR upper(radiotherapydiagnosisicd) = 'C61')
	AND actualfractions is not null AND actualfractions <> 0
	group by t2.e_patid, t2.prescriptionid, t2.actualfractions
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id, 
	visit_detail_id, 
	source_value,
	value_as_number,
	value_source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	stem_source_table,
	stem_source_id
)
select distinct
	t1.person_id, 
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.source_value,
	t1.value_as_number,
	t1.value_source_value,
	0 as source_concept_id,
	32879 as type_concept_id, --Registry
	t1.start_date,
	t1.start_date as end_date,
	'00:00:00'::time start_time,
	t2.source_table as stem_source_table,
	t1.stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.person_id = t2.person_id AND t1.start_date = t2.visit_start_date
WHERE t2.source_table = 'RTDS'
AND t1.stem_source_id = t2.visit_detail_source_id;


--PRESCRIPTION or EXPOSURE?? - rttreatmentmodality (It can change from one event to another, it cannot be recorded under prescription date)
WITH cte09 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
),
cte1 as (
	select t2.e_patid as person_id, 
	MIN(treatmentstartdate) as start_date, 
	rttreatmentmodality as source_value, 
	'rttreatmentmodality' as value_source_value,
	t2.prescriptionid as stem_source_id
	from cte09 as t1
	inner join {SOURCE_SCHEMA}.rtds as t2 on t1.person_id = t2.e_patid
	WHERE (radiotherapydiagnosisicd is null OR upper(radiotherapydiagnosisicd) = 'C61')
	AND rttreatmentmodality is not null --AND radiotherapybeamtype is not null
	group by t2.e_patid, t2.prescriptionid, t2.rttreatmentmodality
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id, 
	visit_detail_id, 
	source_value,
	value_source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	stem_source_table,
	stem_source_id
)
select distinct
	t1.person_id, 
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.source_value,
	t1.value_source_value,
	0 as source_concept_id,
	32879 as type_concept_id, --Registry
	t1.start_date,
	t1.start_date as end_date,
	'00:00:00'::time start_time,
	t2.source_table as stem_source_table,
	t1.stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.person_id = t2.person_id AND t1.start_date = t2.visit_start_date
WHERE t2.source_table = 'RTDS'
AND t1.stem_source_id = t2.visit_detail_source_id;


--OPCDS - primaryprocedureopcs
WITH cte10 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
),
cte1 as (
	select distinct t2.e_patid, 
	t2.apptdate as start_date, 
	CASE
		WHEN length(t2.primaryprocedureopcs) > 5 AND POSITION(' ' in t2.primaryprocedureopcs) > 0 THEN
			CASE WHEN length(split_part(t2.primaryprocedureopcs, ' ', 1)) = 5 THEN UPPER(split_part(t2.primaryprocedureopcs, ' ', 1))
				 WHEN length(split_part(t2.primaryprocedureopcs, ' ', 1)) = 4 THEN CONCAT(UPPER(LEFT(split_part(t2.primaryprocedureopcs, ' ', 1),3)),'.',RIGHT(split_part(t2.primaryprocedureopcs, ' ', 1),1)) 
			END
		WHEN length(t2.primaryprocedureopcs) = 5 THEN UPPER(t2.primaryprocedureopcs)
		WHEN length(t2.primaryprocedureopcs) = 4 THEN CONCAT(UPPER(LEFT(t2.primaryprocedureopcs,3)),'.',RIGHT(t2.primaryprocedureopcs,1)) 
	END as source_value,
	t2.prescriptionid as stem_source_id
	from cte10 as t1
	inner join {SOURCE_SCHEMA}.rtds as t2 on t1.person_id = t2.e_patid
	WHERE (radiotherapydiagnosisicd is null OR upper(radiotherapydiagnosisicd) = 'C61') --only prostate cancer diagnoses in this case
	and t2.primaryprocedureopcs is not null and t2.primaryprocedureopcs not in ('-', '0', '-1', 'N/A', 'Z')
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id,
	visit_detail_id,
	source_value,
	value_source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	stem_source_table,
	stem_source_id
)
select distinct
	t1.e_patid as person_id, 
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.source_value,
	'primaryprocedureopcs' as value_source_value,
	COALESCE(t3.source_concept_id, 0) as source_concept_id,
	32879 as type_concept_id, --Registry
	t1.start_date,
	t1.start_date as end_date,
	'00:00:00'::time start_time,
	t2.source_table as stem_source_table,
	t1.stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.e_patid = t2.person_id AND t1.start_date = t2.visit_start_date 
AND t2.source_table = 'RTDS' AND t1.stem_source_id = t2.visit_detail_source_id
left join {VOCABULARY_SCHEMA}.source_to_standard_vocab_map as t3 on t1.source_value = t3.source_code AND upper(t3.source_vocabulary_id) = 'OPCS4';

--EXPOSURE - radiotherapybeamtype (It can change from one event to another, it cannot be recorded under prescription date)
WITH cte011 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
),
cte1 as (
	select distinct t2.e_patid as person_id, 
	t2.apptdate as start_date, 
	t2.radiotherapybeamtype as source_value,
	t2.prescriptionid as stem_source_id
	from cte011 as t1
	inner join {SOURCE_SCHEMA}.rtds as t2 on t1.person_id = t2.e_patid
	WHERE (radiotherapydiagnosisicd is null OR upper(radiotherapydiagnosisicd) = 'C61')
	AND radiotherapybeamtype is not null
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id, 
	visit_detail_id, 
	source_value,
	value_source_value,		
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time,
	stem_source_table,
	stem_source_id
)
select distinct
	t1.person_id, 
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.source_value,
	'radiotherapybeamtype' as value_source_value,
	0 as source_concept_id,
	32879 as type_concept_id, --Registry
	t1.start_date,
	t1.start_date as end_date,
	'00:00:00'::time start_time,
	t2.source_table as stem_source_table,
	t1.stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.person_id = t2.person_id AND t1.start_date = t2.visit_start_date
WHERE t2.source_table = 'RTDS'
AND t1.stem_source_id = t2.visit_detail_source_id;

--EXPOSURE - radiotherapybeamenergy with unit (It can change from one event to another, it cannot be recorded under prescription)
WITH cte012 as (
	select person_id
	from {CHUNK_SCHEMA}.chunk_person
	where chunk_id = {CHUNK_ID}
),
cte1 as (
	select distinct t2.e_patid as person_id, 
	t2.apptdate as start_date, 
	'radiotherapybeamenergy' as source_value,
	t2.radiotherapybeamenergy as value_as_number,
	'radiotherapybeamenergy' as value_source_value,
	t2.prescriptionid as stem_source_id
	from cte012 as t1
	inner join {SOURCE_SCHEMA}.rtds as t2 on t1.person_id = t2.e_patid
	WHERE (radiotherapydiagnosisicd is null OR upper(radiotherapydiagnosisicd) = 'C61')
	AND radiotherapybeamenergy is not null AND radiotherapybeamenergy <> 0
)
insert into {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (
	person_id, 
	visit_occurrence_id, 
	visit_detail_id, 
	source_value,
	value_as_number,
	value_source_value,
	source_concept_id, 
	type_concept_id, 
	start_date, 
	end_date, 
	start_time, 
	unit_concept_id, 
	unit_source_value, 
	stem_source_table,
	stem_source_id
)
select distinct
	t1.person_id, 
	t2.visit_occurrence_id,
	t2.visit_detail_id,
	t1.source_value,
	t1.value_as_number,
	t1.value_source_value,
	0 as source_concept_id,
	32879 as type_concept_id, --Registry
	t1.start_date,
	t1.start_date as end_date,
	'00:00:00'::time start_time,
	710241 as unit_concept_id, 
	'MeV/MV/MVp' as unit_source_value, 
	t2.source_table as stem_source_table,
	t1.stem_source_id
from cte1 as t1
inner join {SOURCE_SCHEMA}.temp_visit_detail as t2 on t1.person_id = t2.person_id AND t1.start_date = t2.visit_start_date
WHERE t2.source_table = 'RTDS'
AND t1.stem_source_id = t2.visit_detail_source_id;

create index idx_stem_source_{CHUNK_ID}_1 on {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (source_concept_id);
create index idx_stem_source_{CHUNK_ID}_2 on {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (source_value);
create index idx_stem_source_{CHUNK_ID}_3 on {CHUNK_SCHEMA}.stem_source_{CHUNK_ID} (stem_source_table, stem_source_id);

-----------------------------------------
-- UPDATE CHUNK
-----------------------------------------
update {CHUNK_SCHEMA}.chunk 
set stem_source_tbl = concat('stem_source_',{CHUNK_ID}::varchar)
where chunk_id = {CHUNK_ID};