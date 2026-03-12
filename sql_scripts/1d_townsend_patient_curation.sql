DROP TABLE IF EXISTS {LINKAGE_NOK_SCHEMA}.patient_townsend CASCADE;

-- PATIENT - Move unacceptable patient from linkage.patient_townsend to linkage_nok.patient_townsend
CREATE TABLE {LINKAGE_NOK_SCHEMA}.patient_townsend (LIKE {LINKAGE_SCHEMA}.patient_townsend) TABLESPACE pg_default;

WITH cte1 as (
	SELECT patid FROM {LINKAGE_SCHEMA}.patient_townsend as t1
	left join {TARGET_SCHEMA_TO_LINK}.person as t2 on t1.patid = t2.person_id
	where t2.person_id is null
)
INSERT INTO {LINKAGE_NOK_SCHEMA}.patient_townsend
SELECT t1.* 
FROM {LINKAGE_SCHEMA}.patient_townsend as t1
INNER JOIN cte1 on cte1.patid = t1.patid;
	
alter table {LINKAGE_NOK_SCHEMA}.patient_townsend add constraint pk_patient_townsend_nok primary key (patid) USING INDEX TABLESPACE pg_default;

DELETE FROM {LINKAGE_SCHEMA}.patient_townsend as t1 
USING {LINKAGE_NOK_SCHEMA}.patient_townsend as t2
WHERE t1.patid = t2.patid;
