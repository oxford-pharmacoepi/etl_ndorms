ALTER TABLE {TARGET_SCHEMA}.provider ADD CONSTRAINT xpk_provider PRIMARY KEY (provider_id) USING INDEX TABLESPACE pg_default;

CREATE INDEX idx_provider_id_1 ON {TARGET_SCHEMA}.provider (provider_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.provider USING idx_provider_id_1;