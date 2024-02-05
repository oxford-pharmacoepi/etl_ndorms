ALTER TABLE {SOURCE_SCHEMA}.patient ADD CONSTRAINT pk_patient PRIMARY KEY(patid) USING INDEX TABLESPACE pg_default;
CLUSTER {SOURCE_SCHEMA}.patient USING pk_patient;

CREATE INDEX IF NOT EXISTS idx_patient_accept on {SOURCE_SCHEMA}.patient(accept, yob) TABLESPACE pg_default;
