--ALTER TABLE {SOURCE_SCHEMA}.test ADD CONSTRAINT pk_test PRIMARY KEY(id);
--I don't think we can have another PK instead

CREATE INDEX IF NOT EXISTS idx_test_patid_consid ON {SOURCE_SCHEMA}.test (patid, consid) TABLESPACE pg_default;
CLUSTER {SOURCE_SCHEMA}.test USING idx_test_patid_consid;

CREATE INDEX IF NOT EXISTS idx_test_medcode ON {SOURCE_SCHEMA}.test (medcode) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_test_enttype ON {SOURCE_SCHEMA}.test (enttype) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_test_data1 ON {SOURCE_SCHEMA}.test (data1) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_test_data3 ON {SOURCE_SCHEMA}.test (data3) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_test_data4 ON {SOURCE_SCHEMA}.test (data4) TABLESPACE pg_default;

