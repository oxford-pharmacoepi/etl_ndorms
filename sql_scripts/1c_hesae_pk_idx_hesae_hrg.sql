--hesae_hrg
ALTER TABLE {SOURCE_SCHEMA}.hesae_hrg ADD CONSTRAINT pk_hesae_hrg PRIMARY KEY (patid, aekey) USING INDEX TABLESPACE pg_default;
create index idx_hesae_hrg_patid on {SOURCE_SCHEMA}.hesae_hrg(patid,aekey) TABLESPACE pg_default;
cluster {SOURCE_SCHEMA}.hesae_hrg using idx_hesae_hrg_patid;