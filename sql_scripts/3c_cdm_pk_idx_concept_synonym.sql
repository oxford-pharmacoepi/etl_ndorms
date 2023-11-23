CREATE INDEX idx_concept_synonym_id ON {VOCABULARY_SCHEMA}.concept_synonym (concept_id ASC) TABLESPACE pg_default;
CLUSTER {VOCABULARY_SCHEMA}.concept_synonym  USING idx_concept_synonym_id;
