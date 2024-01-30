-- it should run before 3d_cdm_source_to_source_vocab_map.sql 
-- to speed up creation of source_to_source_vocab_map and source_to_standard_vocab_map
CREATE INDEX idx_source_to_concept_map_3 ON {VOCABULARY_SCHEMA}.source_to_concept_map (target_concept_id ASC) TABLESPACE pg_default; 
CLUSTER {VOCABULARY_SCHEMA}.source_to_concept_map USING idx_source_to_concept_map_3;

CREATE INDEX idx_source_to_concept_map_1 ON {VOCABULARY_SCHEMA}.source_to_concept_map (source_vocabulary_id ASC) TABLESPACE pg_default;
CREATE INDEX idx_source_to_concept_map_2 ON {VOCABULARY_SCHEMA}.source_to_concept_map (target_vocabulary_id ASC) TABLESPACE pg_default;
CREATE INDEX idx_source_to_concept_map_c ON {VOCABULARY_SCHEMA}.source_to_concept_map (source_code ASC) TABLESPACE pg_default;

ALTER TABLE {VOCABULARY_SCHEMA}.source_to_concept_map ADD CONSTRAINT fpk_source_to_concept_map_source_concept_id FOREIGN KEY (source_concept_id) REFERENCES {VOCABULARY_SCHEMA}.concept (concept_id);
ALTER TABLE {VOCABULARY_SCHEMA}.source_to_concept_map ADD CONSTRAINT fpk_source_to_concept_map_target_concept_id FOREIGN KEY (target_concept_id) REFERENCES {VOCABULARY_SCHEMA}.concept (concept_id);
ALTER TABLE {VOCABULARY_SCHEMA}.source_to_concept_map ADD CONSTRAINT fpk_source_to_concept_map_target_vocabulary_id FOREIGN KEY (target_vocabulary_id) REFERENCES {VOCABULARY_SCHEMA}.vocabulary (vocabulary_ID);
