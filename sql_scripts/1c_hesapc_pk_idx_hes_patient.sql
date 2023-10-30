--hes_patient
ALTER TABLE {SOURCE_SCHEMA}.hes_patient ADD CONSTRAINT pk_hes_patient PRIMARY KEY (patid, match_rank);
create index idx_hesapc_patient_patid on {SOURCE_SCHEMA}.hes_patient(patid);
cluster {SOURCE_SCHEMA}.hes_patient using idx_hesapc_patient_patid;
create index idx_hesapc_patient_ethnicity on {SOURCE_SCHEMA}.hes_patient(gen_ethnicity);
