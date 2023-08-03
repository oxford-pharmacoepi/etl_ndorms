ALTER TABLE {VOCABULARY_SCHEMA}.CONCEPT_CLASS ADD CONSTRAINT xpk_concept_class PRIMARY KEY (concept_class_id);

CREATE UNIQUE INDEX idx_concept_class_class_id  ON {VOCABULARY_SCHEMA}.concept_class  (concept_class_id ASC);
CLUSTER {VOCABULARY_SCHEMA}.concept_class  USING idx_concept_class_class_id ;