ALTER TABLE {LINKAGE_SCHEMA}.patient_townsend ADD CONSTRAINT pk_townsend_patient PRIMARY KEY (patid) USING INDEX TABLESPACE pg_default;
