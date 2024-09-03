alter table {SOURCE_SCHEMA}.gp_clinical add constraint pk_gp_clinical primary key (id) USING INDEX TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_gp_clinical_eid ON {SOURCE_SCHEMA}.gp_clinical (eid) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_gp_clinical_read_2 ON {SOURCE_SCHEMA}.gp_clinical (read_2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_gp_clinical_read_3 ON {SOURCE_SCHEMA}.gp_clinical (read_3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_gp_clinical_eid_dp_edate ON {SOURCE_SCHEMA}.gp_clinical (eid, data_provider, event_dt) TABLESPACE pg_default;