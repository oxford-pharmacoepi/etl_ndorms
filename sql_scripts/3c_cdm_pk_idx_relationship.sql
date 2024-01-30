ALTER TABLE {VOCABULARY_SCHEMA}.RELATIONSHIP ADD CONSTRAINT xpk_relationship PRIMARY KEY (relationship_id) USING INDEX TABLESPACE pg_default;

CREATE UNIQUE INDEX idx_relationship_rel_id  ON {VOCABULARY_SCHEMA}.relationship (relationship_id ASC) TABLESPACE pg_default;
CLUSTER {VOCABULARY_SCHEMA}.relationship USING idx_relationship_rel_id;
