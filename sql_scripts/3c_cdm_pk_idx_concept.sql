ALTER TABLE {VOCABULARY_SCHEMA}.CONCEPT ADD CONSTRAINT xpk_concept PRIMARY KEY (concept_id) USING INDEX TABLESPACE pg_default;

CREATE UNIQUE INDEX idx_concept_concept_id  ON {VOCABULARY_SCHEMA}.CONCEPT (concept_id ASC) TABLESPACE pg_default;
CLUSTER {VOCABULARY_SCHEMA}.CONCEPT  USING idx_concept_concept_id;
CREATE INDEX idx_concept_code ON {VOCABULARY_SCHEMA}.CONCEPT (concept_code ASC) TABLESPACE pg_default;
CREATE INDEX idx_concept_vocabulary_id ON {VOCABULARY_SCHEMA}.CONCEPT (vocabulary_id ASC) TABLESPACE pg_default;
CREATE INDEX idx_concept_domain_id ON {VOCABULARY_SCHEMA}.CONCEPT (domain_id ASC) TABLESPACE pg_default;
CREATE INDEX idx_concept_class_id ON {VOCABULARY_SCHEMA}.CONCEPT (concept_class_id ASC) TABLESPACE pg_default;
