ALTER TABLE {VOCABULARY_SCHEMA}.CONCEPT_CLASS ADD CONSTRAINT xpk_concept_class PRIMARY KEY (concept_class_id) USING INDEX TABLESPACE pg_default;

CREATE UNIQUE INDEX idx_concept_class_class_id ON {VOCABULARY_SCHEMA}.concept_class (concept_class_id ASC) TABLESPACE pg_default;
CLUSTER {VOCABULARY_SCHEMA}.concept_class USING idx_concept_class_class_id;