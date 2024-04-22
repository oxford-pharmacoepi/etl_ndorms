DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.ons_death CASCADE;

CREATE TABLE {SOURCE_NOK_SCHEMA}.ons_death (LIKE {SOURCE_SCHEMA}.ons_death) TABLESPACE pg_default;
with cte1 as (
	select *
	from {SOURCE_SCHEMA}.ons_death
	where cause is null
	or match_rank > 2
)
INSERT INTO {SOURCE_NOK_SCHEMA}.ons_death
(SELECT t1.* FROM {SOURCE_SCHEMA}.ons_death as t1
INNER JOIN cte1 on cte1.patid = t1.patid
UNION
select t1.*
from {SOURCE_SCHEMA}.ons_death as t1
join source.linkage_coverage as t2 on t1.dod < t2.start or t1.dod > t2.end 
where t2.data_source = 'ons_death'
UNION
-- Eliminate dead patients exist in source_nok.patient
select t1.*
from {SOURCE_SCHEMA}.ons_death as t1
join source_nok.patient as t2 on t1.patid = t2.patid
);

alter table {SOURCE_NOK_SCHEMA}.ons_death add constraint pk_dpatient_nok primary key (patid) USING INDEX TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.ons_death as t1 
using {SOURCE_NOK_SCHEMA}.ons_death as t2
WHERE t1.patid = t2.patid;