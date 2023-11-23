ALTER TABLE {VOCABULARY_SCHEMA}.CONCEPT_ANCESTOR ADD CONSTRAINT xpk_concept_ancestor PRIMARY KEY (ancestor_concept_id,descendant_concept_id) USING INDEX TABLESPACE pg_default;

CREATE INDEX idx_concept_ancestor_id_1  ON {VOCABULARY_SCHEMA}.concept_ancestor (ancestor_concept_id ASC) TABLESPACE pg_default;
CLUSTER {VOCABULARY_SCHEMA}.concept_ancestor  USING idx_concept_ancestor_id_1;
CREATE INDEX idx_concept_ancestor_id_2 ON {VOCABULARY_SCHEMA}.concept_ancestor (descendant_concept_id ASC) TABLESPACE pg_default;

