ALTER TABLE {TARGET_SCHEMA}.procedure_occurrence ADD CONSTRAINT fpk_procedure_v_detail FOREIGN KEY (visit_detail_id) REFERENCES {TARGET_SCHEMA}.visit_detail (visit_detail_id);

