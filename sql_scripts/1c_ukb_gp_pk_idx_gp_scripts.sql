alter table {SOURCE_SCHEMA}.gp_scripts add constraint pk_gp_scripts primary key (id) USING INDEX TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_gp_scripts_eid ON {SOURCE_SCHEMA}.gp_scripts (eid) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_gp_scripts_read_2 ON {SOURCE_SCHEMA}.gp_scripts (read_2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_gp_scripts_drug_name ON {SOURCE_SCHEMA}.gp_scripts (drug_name) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_gp_scripts_eid_dp_idate ON {SOURCE_SCHEMA}.gp_scripts (eid, data_provider, issue_date) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_gp_scripts_quantity ON {SOURCE_SCHEMA}.gp_scripts (quantity) TABLESPACE pg_default;