DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.death_patient CASCADE;

CREATE TABLE {SOURCE_NOK_SCHEMA}.death_patient (LIKE {SOURCE_SCHEMA}.death_patient) TABLESPACE pg_default;

with cte1 as (
	select *
	from {SOURCE_SCHEMA}.death_patient
	where cause is null
	or match_rank > 2
)
INSERT INTO {SOURCE_NOK_SCHEMA}.death_patient
SELECT t1.* FROM {SOURCE_SCHEMA}.death_patient as t1
INNER JOIN cte1 on cte1.patid = t1.patid;

alter table {SOURCE_NOK_SCHEMA}.death_patient add constraint pk_dpatient_nok primary key (patid) USING INDEX TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.death_patient as t1 
using {SOURCE_NOK_SCHEMA}.death_patient as t2
WHERE t1.patid = t2.patid;