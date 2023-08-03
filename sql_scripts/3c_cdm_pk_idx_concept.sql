ALTER TABLE {VOCABULARY_SCHEMA}.CONCEPT ADD CONSTRAINT xpk_concept PRIMARY KEY (concept_id);

CREATE UNIQUE INDEX idx_concept_concept_id  ON {VOCABULARY_SCHEMA}.CONCEPT  (concept_id ASC);
CLUSTER {VOCABULARY_SCHEMA}.CONCEPT  USING idx_concept_concept_id ;
CREATE INDEX idx_concept_code ON {VOCABULARY_SCHEMA}.CONCEPT (concept_code ASC);
CREATE INDEX idx_concept_vocabulary_id ON {VOCABULARY_SCHEMA}.CONCEPT (vocabulary_id ASC);
CREATE INDEX idx_concept_domain_id ON {VOCABULARY_SCHEMA}.CONCEPT (domain_id ASC);
CREATE INDEX idx_concept_class_id ON {VOCABULARY_SCHEMA}.CONCEPT (concept_class_id ASC);
