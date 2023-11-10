ALTER TABLE {TARGET_SCHEMA}.visit_detail ADD CONSTRAINT fpk_v_detail_concept FOREIGN KEY (visit_detail_concept_id) REFERENCES {VOCABULARY_SCHEMA}.concept (concept_id);
ALTER TABLE {TARGET_SCHEMA}.visit_detail ADD CONSTRAINT fpk_v_detail_type_concept FOREIGN KEY (visit_detail_type_concept_id) REFERENCES {VOCABULARY_SCHEMA}.concept (concept_id);
ALTER TABLE {TARGET_SCHEMA}.visit_detail ADD CONSTRAINT fpk_v_detail_discharge FOREIGN KEY (discharge_to_concept_id) REFERENCES {VOCABULARY_SCHEMA}.concept (concept_id);
ALTER TABLE {TARGET_SCHEMA}.visit_detail ADD CONSTRAINT fpk_v_detail_concept_s FOREIGN KEY (visit_detail_source_concept_id) REFERENCES {VOCABULARY_SCHEMA}.concept (concept_id);
ALTER TABLE {TARGET_SCHEMA}.visit_detail ADD CONSTRAINT fpk_v_detail_admitting FOREIGN KEY (admitting_source_concept_id) REFERENCES {VOCABULARY_SCHEMA}.concept (concept_id);
