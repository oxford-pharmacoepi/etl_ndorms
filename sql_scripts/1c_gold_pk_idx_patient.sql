ALTER TABLE {SOURCE_SCHEMA}.patient ADD CONSTRAINT pk_patient PRIMARY KEY(patid);
CLUSTER {SOURCE_SCHEMA}.patient USING pk_patient;

CREATE INDEX IF NOT EXISTS idx_patient_accept on {SOURCE_SCHEMA}.patient(accept, yob);
