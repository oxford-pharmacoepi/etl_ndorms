--hesop_patient
ALTER TABLE {SOURCE_SCHEMA}.hesop_patient ADD CONSTRAINT pk_hesop_patient PRIMARY KEY (patid, match_rank) USING INDEX TABLESPACE pg_default;
create index idx_hesop_patient_patid on {SOURCE_SCHEMA}.hesop_patient(patid);
cluster {SOURCE_SCHEMA}.hesop_patient using idx_hesop_patient_patid;
create index idx_hesop_patient_ethnicity on {SOURCE_SCHEMA}.hesop_patient(patid, gen_ethnicity);

