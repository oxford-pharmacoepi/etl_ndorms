--hesae_investigation
ALTER TABLE {SOURCE_SCHEMA}.hesae_investigation ADD CONSTRAINT pk_hesae_investigation PRIMARY KEY (patid, aekey, invest_order) USING INDEX TABLESPACE pg_default;
create index idx_hesae_investigation_patid on {SOURCE_SCHEMA}.hesae_investigation(patid,aekey, invest_order) TABLESPACE pg_default;
cluster {SOURCE_SCHEMA}.hesae_investigation using idx_hesae_investigation_patid;