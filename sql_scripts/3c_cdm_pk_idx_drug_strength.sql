ALTER TABLE {VOCABULARY_SCHEMA}.DRUG_STRENGTH ADD CONSTRAINT xpk_drug_strength PRIMARY KEY (drug_concept_id, ingredient_concept_id) USING INDEX TABLESPACE pg_default;

CREATE INDEX idx_drug_strength_id_1 ON {VOCABULARY_SCHEMA}.drug_strength (drug_concept_id ASC) TABLESPACE pg_default;
CLUSTER {VOCABULARY_SCHEMA}.drug_strength  USING idx_drug_strength_id_1;
CREATE INDEX idx_drug_strength_id_2 ON {VOCABULARY_SCHEMA}.drug_strength (ingredient_concept_id ASC) TABLESPACE pg_default;