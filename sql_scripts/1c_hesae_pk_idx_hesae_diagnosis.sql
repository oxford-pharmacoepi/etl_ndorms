--hesae_diagnosis
ALTER TABLE {SOURCE_SCHEMA}.hesae_diagnosis ADD CONSTRAINT pk_hesae_diagnosis PRIMARY KEY (patid, aekey,diag_order) USING INDEX TABLESPACE pg_default;
create index idx_hesae_diagnosis_patid on {SOURCE_SCHEMA}.hesae_diagnosis(patid,aekey) TABLESPACE pg_default;
cluster {SOURCE_SCHEMA}.hesae_diagnosis using idx_hesae_diagnosis_patid;