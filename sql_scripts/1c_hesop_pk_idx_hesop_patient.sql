--hesop_patient
ALTER TABLE {SOURCE_SCHEMA}.hesop_patient ADD CONSTRAINT pk_hesop_patient PRIMARY KEY (patid) USING INDEX TABLESPACE pg_default;
create index idx_hesop_patient_patid on {SOURCE_SCHEMA}.hesop_patient(patid) TABLESPACE pg_default;
cluster {SOURCE_SCHEMA}.hesop_patient using idx_hesop_patient_patid;
create index idx_hesop_patient_ethnicity on {SOURCE_SCHEMA}.hesop_patient(patid, gen_ethnicity) TABLESPACE pg_default;

