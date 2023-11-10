ALTER TABLE {TARGET_SCHEMA}.metadata ADD CONSTRAINT xpk_METADATA PRIMARY KEY (metadata_id);
CREATE INDEX idx_metadata_id_1 ON {TARGET_SCHEMA}.metadata (metadata_id ASC);
CLUSTER {TARGET_SCHEMA}.metadata USING idx_metadata_id_1;
