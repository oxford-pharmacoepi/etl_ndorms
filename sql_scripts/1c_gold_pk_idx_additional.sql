ALTER TABLE {SOURCE_SCHEMA}.additional ADD CONSTRAINT pk_additional PRIMARY KEY(patid, adid);

CREATE INDEX IF NOT EXISTS idx_add_patid ON {SOURCE_SCHEMA}.additional (patid);
CLUSTER {SOURCE_SCHEMA}.additional USING idx_add_patid ;

CREATE INDEX IF NOT EXISTS idx_add_enttype ON {SOURCE_SCHEMA}.additional (enttype);

CREATE INDEX IF NOT EXISTS idx_add_data1 ON {SOURCE_SCHEMA}.additional (data1);
CREATE INDEX IF NOT EXISTS idx_add_data2 ON {SOURCE_SCHEMA}.additional (data2);
CREATE INDEX IF NOT EXISTS idx_add_data3 ON {SOURCE_SCHEMA}.additional (data3);
CREATE INDEX IF NOT EXISTS idx_add_data4 ON {SOURCE_SCHEMA}.additional (data4);
CREATE INDEX IF NOT EXISTS idx_add_data5 ON {SOURCE_SCHEMA}.additional (data5);
CREATE INDEX IF NOT EXISTS idx_add_data6 ON {SOURCE_SCHEMA}.additional (data6);
CREATE INDEX IF NOT EXISTS idx_add_data7 ON {SOURCE_SCHEMA}.additional (data7);
