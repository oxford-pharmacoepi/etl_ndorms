ALTER TABLE {TARGET_SCHEMA}.DOSE_ERA ADD CONSTRAINT fpk_DOSE_ERA_drug_concept_id FOREIGN KEY (drug_concept_id) REFERENCES {TARGET_SCHEMA}.CONCEPT (CONCEPT_ID);
ALTER TABLE {TARGET_SCHEMA}.DOSE_ERA ADD CONSTRAINT fpk_DOSE_ERA_unit_concept_id FOREIGN KEY (unit_concept_id) REFERENCES {TARGET_SCHEMA}.CONCEPT (CONCEPT_ID);