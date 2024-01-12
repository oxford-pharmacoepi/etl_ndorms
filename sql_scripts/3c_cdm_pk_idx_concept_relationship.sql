ALTER TABLE {VOCABULARY_SCHEMA}.CONCEPT_RELATIONSHIP ADD CONSTRAINT xpk_concept_relationship PRIMARY KEY (concept_id_1,concept_id_2,relationship_id) USING INDEX TABLESPACE pg_default;

CREATE INDEX idx_concept_relationship_id_1 ON {VOCABULARY_SCHEMA}.concept_relationship (concept_id_1 ASC) TABLESPACE pg_default;
CLUSTER {VOCABULARY_SCHEMA}.concept_relationship USING idx_concept_relationship_id_1;
CREATE INDEX idx_concept_relationship_id_2 ON {VOCABULARY_SCHEMA}.concept_relationship (concept_id_2 ASC) TABLESPACE pg_default;
CREATE INDEX idx_concept_relationship_id_3 ON {VOCABULARY_SCHEMA}.concept_relationship (relationship_id ASC) TABLESPACE pg_default;
