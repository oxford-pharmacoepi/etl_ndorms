ALTER TABLE {TARGET_SCHEMA}.metadata ADD CONSTRAINT xpk_METADATA PRIMARY KEY (metadata_concept_id) USING INDEX TABLESPACE pg_default;
CREATE INDEX idx_metadata_concept_id_1 ON {TARGET_SCHEMA}.metadata (metadata_concept_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.metadata USING idx_metadata_concept_id_1;
