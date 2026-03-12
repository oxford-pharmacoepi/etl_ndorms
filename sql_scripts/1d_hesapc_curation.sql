DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.hes_patient CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.hes_ccare CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.hes_diagnosis_epi CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.hes_diagnosis_hosp CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.hes_episodes CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.hes_hospital CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.hes_hrg CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.hes_maternity CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.hes_primary_diag_hosp CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.hes_procedures_epi CASCADE;

-- PATIENT - Move unacceptable patient from source_hesapc.patient to source_hesapc_nok.patient
CREATE TABLE {SOURCE_NOK_SCHEMA}.hes_patient (LIKE {SOURCE_SCHEMA}.hes_patient) TABLESPACE pg_default;

WITH cte1 as (
--	SELECT patid FROM {SOURCE_SCHEMA}.hes_patient
--	WHERE match_rank in (3,4,5) --match_rank has been removed from the patient table
--	UNION DISTINCT
	SELECT patid FROM {SOURCE_SCHEMA}.hes_patient as t1
	left join {TARGET_SCHEMA_TO_LINK}.person as t2 on t1.patid = t2.person_id
	where t2.person_id is null
)
INSERT INTO {SOURCE_NOK_SCHEMA}.hes_patient
SELECT t1.* 
FROM {SOURCE_SCHEMA}.hes_patient as t1
INNER JOIN cte1 on cte1.patid = t1.patid;
	
alter table {SOURCE_NOK_SCHEMA}.hes_patient add constraint pk_patient_nok primary key (patid) USING INDEX TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.hes_patient as t1 
USING {SOURCE_NOK_SCHEMA}.hes_patient as t2
WHERE t1.patid = t2.patid;

-- PATIENT - Move patients without hospitalization records from source_hesapc.patient to source_hesapc_nok.patient
WITH cte2 as (
	SELECT t1.patid
	FROM {SOURCE_SCHEMA}.hes_patient AS t1
	LEFT JOIN {SOURCE_SCHEMA}.hes_hospital AS t2 ON t1.patid = t2.patid
	WHERE t2.patid IS NULL
)
INSERT INTO {SOURCE_NOK_SCHEMA}.hes_patient
SELECT t1.* 
FROM {SOURCE_SCHEMA}.hes_patient as t1
INNER JOIN cte2 on cte2.patid = t1.patid;

DELETE FROM {SOURCE_SCHEMA}.hes_patient as t1 
USING {SOURCE_NOK_SCHEMA}.hes_patient as t2
WHERE t1.patid = t2.patid;


-- Move unacceptable patient from source_hesapc.hes_ccare to source_hesapc_nok.hes_ccare
CREATE TABLE {SOURCE_NOK_SCHEMA}.hes_ccare (LIKE {SOURCE_SCHEMA}.hes_ccare) TABLESPACE pg_default;

INSERT INTO {SOURCE_NOK_SCHEMA}.hes_ccare
SELECT t1.* 
FROM {SOURCE_SCHEMA}.hes_ccare as t1
left JOIN {SOURCE_SCHEMA}.hes_patient as t2 on t2.patid = t1.patid
WHERE t2.patid is NULL;

create index idx_hesapc_nok_ccare_patid on {SOURCE_NOK_SCHEMA}.hes_ccare(patid) TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.hes_ccare as t1 
USING {SOURCE_NOK_SCHEMA}.hes_patient as t2
WHERE t1.patid = t2.patid;


-- Move unacceptable patient from source_hesapc.hes_diagnosis_epi to source_hesapc_nok.hes_diagnosis_epi
CREATE TABLE {SOURCE_NOK_SCHEMA}.hes_diagnosis_epi (LIKE {SOURCE_SCHEMA}.hes_diagnosis_epi) TABLESPACE pg_default;

INSERT INTO {SOURCE_NOK_SCHEMA}.hes_diagnosis_epi
SELECT t1.* 
FROM {SOURCE_SCHEMA}.hes_diagnosis_epi as t1
left JOIN {SOURCE_SCHEMA}.hes_patient as t2 on t2.patid = t1.patid
WHERE t2.patid is NULL;

create index idx_hesapc_nok_diagnosis_epi_patid on {SOURCE_NOK_SCHEMA}.hes_diagnosis_epi(patid) TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.hes_diagnosis_epi as t1 
USING {SOURCE_NOK_SCHEMA}.hes_patient as t2
WHERE t1.patid = t2.patid;


-- Move unacceptable patient from source_hesapc.hes_diagnosis_hosp to source_hesapc_nok.hes_diagnosis_hosp
CREATE TABLE {SOURCE_NOK_SCHEMA}.hes_diagnosis_hosp (LIKE {SOURCE_SCHEMA}.hes_diagnosis_hosp) TABLESPACE pg_default;

INSERT INTO {SOURCE_NOK_SCHEMA}.hes_diagnosis_hosp
SELECT t1.* 
FROM {SOURCE_SCHEMA}.hes_diagnosis_hosp as t1
left JOIN {SOURCE_SCHEMA}.hes_patient as t2 on t2.patid = t1.patid
WHERE t2.patid is NULL;

create index idx_hesapc_nok_diagnosis_hosp_patid on {SOURCE_NOK_SCHEMA}.hes_diagnosis_hosp(patid) TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.hes_diagnosis_hosp as t1 
USING {SOURCE_NOK_SCHEMA}.hes_patient as t2
WHERE t1.patid = t2.patid;


-- Move unacceptable patient from source_hesapc.hes_episodes to source_hesapc_nok.hes_episodes
CREATE TABLE {SOURCE_NOK_SCHEMA}.hes_episodes (LIKE {SOURCE_SCHEMA}.hes_episodes) TABLESPACE pg_default;

INSERT INTO {SOURCE_NOK_SCHEMA}.hes_episodes
SELECT t1.* 
FROM {SOURCE_SCHEMA}.hes_episodes as t1
left JOIN {SOURCE_SCHEMA}.hes_patient as t2 on t2.patid = t1.patid
WHERE t2.patid is NULL;

create index idx_hesapc_nok_episodes_patid on {SOURCE_NOK_SCHEMA}.hes_episodes(patid) TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.hes_episodes as t1 
USING {SOURCE_NOK_SCHEMA}.hes_patient as t2
WHERE t1.patid = t2.patid;


-- Move unacceptable patient from source_hesapc.hes_hospital to source_hesapc_nok.hes_hospital
CREATE TABLE {SOURCE_NOK_SCHEMA}.hes_hospital (LIKE {SOURCE_SCHEMA}.hes_hospital) TABLESPACE pg_default;

INSERT INTO {SOURCE_NOK_SCHEMA}.hes_hospital
SELECT t1.* 
FROM {SOURCE_SCHEMA}.hes_hospital as t1
left JOIN {SOURCE_SCHEMA}.hes_patient as t2 on t2.patid = t1.patid
WHERE t2.patid is NULL;

create index idx_hesapc_nok_hospital_patid on {SOURCE_NOK_SCHEMA}.hes_hospital(patid) TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.hes_hospital as t1 
USING {SOURCE_NOK_SCHEMA}.hes_patient as t2
WHERE t1.patid = t2.patid;


-- Move unacceptable patient from source_hesapc.hes_hrg to source_hesapc_nok.hes_hrg
CREATE TABLE {SOURCE_NOK_SCHEMA}.hes_hrg (LIKE {SOURCE_SCHEMA}.hes_hrg) TABLESPACE pg_default;

INSERT INTO {SOURCE_NOK_SCHEMA}.hes_hrg
SELECT t1.* 
FROM {SOURCE_SCHEMA}.hes_hrg as t1
left JOIN {SOURCE_SCHEMA}.hes_patient as t2 on t2.patid = t1.patid
WHERE t2.patid is NULL;

create index idx_hesapc_nok_hrg_patid on {SOURCE_NOK_SCHEMA}.hes_hrg(patid) TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.hes_hrg as t1 
USING {SOURCE_NOK_SCHEMA}.hes_patient as t2
WHERE t1.patid = t2.patid;


-- Move unacceptable patient from source_hesapc.hes_maternity to source_hesapc_nok.hes_maternity
CREATE TABLE {SOURCE_NOK_SCHEMA}.hes_maternity (LIKE {SOURCE_SCHEMA}.hes_maternity) TABLESPACE pg_default;

INSERT INTO {SOURCE_NOK_SCHEMA}.hes_maternity
SELECT t1.* 
FROM {SOURCE_SCHEMA}.hes_maternity as t1
left JOIN {SOURCE_SCHEMA}.hes_patient as t2 on t2.patid = t1.patid
WHERE t2.patid is NULL;

create index idx_hesapc_nok_maternity_patid on {SOURCE_NOK_SCHEMA}.hes_maternity(patid) TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.hes_maternity as t1 
USING {SOURCE_NOK_SCHEMA}.hes_patient as t2
WHERE t1.patid = t2.patid;


-- Move unacceptable patient from source_hesapc.hes_primary_diag_hosp to source_hesapc_nok.hes_primary_diag_hosp
CREATE TABLE {SOURCE_NOK_SCHEMA}.hes_primary_diag_hosp (LIKE {SOURCE_SCHEMA}.hes_primary_diag_hosp) TABLESPACE pg_default;

INSERT INTO {SOURCE_NOK_SCHEMA}.hes_primary_diag_hosp
SELECT t1.* 
FROM {SOURCE_SCHEMA}.hes_primary_diag_hosp as t1
left JOIN {SOURCE_SCHEMA}.hes_patient as t2 on t2.patid = t1.patid
WHERE t2.patid is NULL;

create index idx_hesapc_nok_primary_diag_hosp_patid on {SOURCE_NOK_SCHEMA}.hes_primary_diag_hosp(patid) TABLESPACE pg_default;
	
DELETE FROM {SOURCE_SCHEMA}.hes_primary_diag_hosp as t1 
USING {SOURCE_NOK_SCHEMA}.hes_patient as t2
WHERE t1.patid = t2.patid;


-- Move unacceptable patient from source_hesapc.hes_procedures_epi to source_hesapc_nok.hes_procedures_epi
CREATE TABLE {SOURCE_NOK_SCHEMA}.hes_procedures_epi (LIKE {SOURCE_SCHEMA}.hes_procedures_epi) TABLESPACE pg_default;

INSERT INTO {SOURCE_NOK_SCHEMA}.hes_procedures_epi
SELECT t1.* 
FROM {SOURCE_SCHEMA}.hes_procedures_epi as t1
left JOIN {SOURCE_SCHEMA}.hes_patient as t2 on t2.patid = t1.patid
WHERE t2.patid is NULL;
	
create index idx_hesapc_nok_procedures_epi_patid on {SOURCE_NOK_SCHEMA}.hes_procedures_epi(patid) TABLESPACE pg_default;
	
DELETE FROM {SOURCE_SCHEMA}.hes_procedures_epi as t1 
USING {SOURCE_NOK_SCHEMA}.hes_patient as t2
WHERE t1.patid = t2.patid;

