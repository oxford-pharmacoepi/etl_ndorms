--hesae_patient
ALTER TABLE {SOURCE_SCHEMA}.hesae_patient ADD CONSTRAINT pk_hesae_patient PRIMARY KEY (patid, match_rank) USING INDEX TABLESPACE pg_default;
create index idx_hesae_patient_patid on {SOURCE_SCHEMA}.hesae_patient(patid);
cluster {SOURCE_SCHEMA}.hesae_patient using idx_hesae_patient_patid;
create index idx_hesae_patient_ethnicity on {SOURCE_SCHEMA}.hesae_patient(gen_ethnicity);

