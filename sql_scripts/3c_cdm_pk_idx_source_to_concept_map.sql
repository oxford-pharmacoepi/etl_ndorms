ALTER TABLE {VOCABULARY_SCHEMA}.source_to_concept_map ADD CONSTRAINT xpk_source_to_concept_map PRIMARY KEY (source_vocabulary_id, source_code) USING INDEX TABLESPACE pg_default;

CREATE UNIQUE INDEX idx_source_to_concept_map ON {VOCABULARY_SCHEMA}.source_to_concept_map (source_vocabulary_id ASC, source_code ASC) TABLESPACE pg_default;
CLUSTER {VOCABULARY_SCHEMA}.source_to_concept_map USING idx_source_to_concept_map;
