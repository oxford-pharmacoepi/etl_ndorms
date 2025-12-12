DROP TABLE IF EXISTS {SOURCE_NOK_SCHEMA}.rtds CASCADE;

CREATE TABLE {SOURCE_NOK_SCHEMA}.rtds (LIKE {SOURCE_SCHEMA}.rtds) TABLESPACE pg_default;

-- rtds
INSERT INTO {SOURCE_NOK_SCHEMA}.rtds(
	select t1.* 
	from {SOURCE_SCHEMA}.rtds as t1
	left join {TARGET_SCHEMA_TO_LINK}.person as t2 on t1.e_patid = t2.person_id
	where t2.person_id is null													-- Eliminated by patients not exist in {target_to_link}.person

--We decided not to consider the linkage_coverage for RTDS as the data appear to be 7 years ahead of the linkage_coverage
--	UNION
--
--	select t1.* 
--	from {SOURCE_SCHEMA}.rtds as t1
--	join {LINKAGE_SCHEMA}.linkage_coverage as t2 on t2.data_source = 'ncras_cr'	
--	where t1.apptdate < t2.start or t1.apptdate > t2.end		-- Eliminate rtds out of linkage_coverage period
);

--NO PKs, the data are dirty
create index idx_rtds_1 on {SOURCE_NOK_SCHEMA} (e_patid,prescriptionid,apptdate,primaryprocedureopcs) TABLESPACE pg_default;

DELETE FROM {SOURCE_SCHEMA}.rtds as t1 
using {SOURCE_NOK_SCHEMA}.rtds as t2
WHERE t1.e_patid = t2.e_patid
and t1.e_cr_patid = t2.e_cr_patid
and t1.e_cr_id = t2.e_cr_id;

