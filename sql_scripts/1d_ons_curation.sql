DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.ons_death CASCADE;

CREATE TABLE {SOURCE_NOK_SCHEMA}.ons_death (LIKE {SOURCE_SCHEMA}.ons_death) TABLESPACE pg_default;

INSERT INTO {SOURCE_NOK_SCHEMA}.ons_death(
	select t1.*
	from {SOURCE_SCHEMA}.ons_death as t1
	left join {TARGET_SCHEMA_TO_LINK}.person as t3 on t3.person_id = t1.patid
	where t3.person_id is null								-- Eliminate dead patients not exist in {target_to_link}.person

	UNION

	select t1.*
	from {SOURCE_SCHEMA}.ons_death as t1
	left join {SOURCE_SCHEMA}.linkage_coverage as t2 on t2.data_source = 'ons_death' 
	where t1.match_rank > 2                       			-- Eliminate dead patients which match_rank > 2 	                                                                                                              
	or t1.dod < t2.start or t1.dod > t2.end					-- Eliminate dead patients out of linkage_coverage period
);

alter table {SOURCE_NOK_SCHEMA}.ons_death add constraint pk_dpatient_nok primary key (patid) USING INDEX TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.ons_death as t1 
using {SOURCE_NOK_SCHEMA}.ons_death as t2
WHERE t1.patid = t2.patid;