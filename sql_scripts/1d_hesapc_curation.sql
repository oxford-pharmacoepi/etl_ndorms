DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.hes_patient CASCADE;
DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.hes_acp CASCADE;
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
--	WHERE match_rank in (3,4,5) match_rank has been removed from the patient table
--	UNION DISTINCT
	SELECT patid from {SOURCE_NOK_SCHEMA_TO_LINK}.patient
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
