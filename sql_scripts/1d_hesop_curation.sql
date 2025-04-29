DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.hesop_patient CASCADE;

-- PATIENT - Move unacceptable patient from source_hesop.patient to source_hesop_nok.patient
CREATE TABLE {SOURCE_NOK_SCHEMA}.hesop_patient (LIKE {SOURCE_SCHEMA}.hesop_patient) TABLESPACE pg_default;

INSERT INTO {SOURCE_NOK_SCHEMA}.hesop_patient
SELECT t1.* 
FROM {SOURCE_SCHEMA}.hesop_patient as t1
INNER JOIN {SOURCE_NOK_SCHEMA_TO_LINK}.patient as t2 on t2.patid = t1.patid;
	
alter table {SOURCE_NOK_SCHEMA}.hesop_patient add constraint pk_patient_nok primary key (patid) USING INDEX TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.hesop_patient as t1 
USING {SOURCE_NOK_SCHEMA}.hesop_patient as t2
WHERE t1.patid = t2.patid;