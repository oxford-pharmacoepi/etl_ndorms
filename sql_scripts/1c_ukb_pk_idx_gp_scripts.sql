CREATE INDEX IF NOT EXISTS idx_gp_scripts_eid ON {SOURCE_SCHEMA}.gp_scripts (eid) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_gp_scripts_read_2 ON {SOURCE_SCHEMA}.gp_scripts (read_2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_gp_scripts_bnf ON {SOURCE_SCHEMA}.gp_scripts (bnf_code) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_gp_scripts_dmd ON {SOURCE_SCHEMA}.gp_scripts (dmd_code) TABLESPACE pg_default;