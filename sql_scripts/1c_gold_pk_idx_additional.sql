ALTER TABLE {SOURCE_SCHEMA}.additional ADD CONSTRAINT pk_additional PRIMARY KEY(patid, adid) USING INDEX TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_add_patid ON {SOURCE_SCHEMA}.additional (patid) TABLESPACE pg_default;
CLUSTER {SOURCE_SCHEMA}.additional USING idx_add_patid ;

CREATE INDEX IF NOT EXISTS idx_add_enttype ON {SOURCE_SCHEMA}.additional (enttype) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_add_data1 ON {SOURCE_SCHEMA}.additional (data1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_add_data2 ON {SOURCE_SCHEMA}.additional (data2) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_add_data3 ON {SOURCE_SCHEMA}.additional (data3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_add_data4 ON {SOURCE_SCHEMA}.additional (data4) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_add_data5 ON {SOURCE_SCHEMA}.additional (data5) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_add_data6 ON {SOURCE_SCHEMA}.additional (data6) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_add_data7 ON {SOURCE_SCHEMA}.additional (data7) TABLESPACE pg_default;
