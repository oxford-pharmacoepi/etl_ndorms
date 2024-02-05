DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.hesae_patient CASCADE;


-- PATIENT - Move unacceptable patient from source_hesapc.patient to source_hesapc_nok.patient
CREATE TABLE {SOURCE_NOK_SCHEMA}.hesae_patient (LIKE {SOURCE_SCHEMA}.hesae_patient) TABLESPACE pg_default;

WITH cte1 as (
	SELECT patid FROM {SOURCE_SCHEMA}.hesae_patient
	WHERE match_rank in (3,4,5)
	UNION DISTINCT
	SELECT patid from source_nok.patient
)
INSERT INTO {SOURCE_NOK_SCHEMA}.hesae_patient
SELECT t1.* 
FROM {SOURCE_SCHEMA}.hesae_patient as t1
INNER JOIN cte1 on cte1.patid = t1.patid;
	
alter table {SOURCE_NOK_SCHEMA}.hesae_patient add constraint pk_patient_nok primary key (patid) USING INDEX TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.hesae_patient as t1 
USING {SOURCE_NOK_SCHEMA}.hesae_patient as t2
WHERE t1.patid = t2.patid;