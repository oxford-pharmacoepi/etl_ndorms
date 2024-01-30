--hesae_attendance
ALTER TABLE {SOURCE_SCHEMA}.hesae_attendance ADD CONSTRAINT pk_hesae_attendance PRIMARY KEY (patid, aekey) USING INDEX TABLESPACE pg_default;
create index idx_hesae_attendance_patid on {SOURCE_SCHEMA}.hesae_attendance(patid,aekey) TABLESPACE pg_default;
cluster {SOURCE_SCHEMA}.hesae_attendance using idx_hesae_attendance_patid;
