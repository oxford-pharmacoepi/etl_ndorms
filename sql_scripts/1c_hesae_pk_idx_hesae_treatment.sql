--hesae_treatment
ALTER TABLE {SOURCE_SCHEMA}.hesae_treatment ADD CONSTRAINT pk_hesae_treatment PRIMARY KEY (patid, aekey) USING INDEX TABLESPACE pg_default;
create index idx_hesae_treatment_patid on {SOURCE_SCHEMA}.hesae_treatment(patid,aekey) TABLESPACE pg_default;
cluster {SOURCE_SCHEMA}.hesae_treatment using idx_hesae_treatment_patid;