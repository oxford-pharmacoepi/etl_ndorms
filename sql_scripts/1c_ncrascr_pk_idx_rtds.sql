--RTDS
--No PK because the data are dirty
create index idx_rtds_1 on {SOURCE_SCHEMA}.rtds (e_patid, prescriptionid, apptdate, primaryprocedureopcs) TABLESPACE pg_default;
create index idx_rtds_2 on {SOURCE_SCHEMA}.rtds (e_patid, prescriptionid, treatmentstartdate) TABLESPACE pg_default;
