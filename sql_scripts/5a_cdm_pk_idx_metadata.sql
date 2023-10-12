ALTER TABLE {TARGET_SCHEMA}.METADATA ADD CONSTRAINT xpk_METADATA PRIMARY KEY (metadata_concept_id);
CREATE INDEX idx_metadata_concept_id_1 ON {TARGET_SCHEMA}.metadata (metadata_concept_id ASC);
CLUSTER {TARGET_SCHEMA}.metadata USING idx_metadata_concept_id_1;
