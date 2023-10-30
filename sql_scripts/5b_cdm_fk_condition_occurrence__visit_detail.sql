ALTER TABLE {TARGET_SCHEMA}.condition_occurrence ADD CONSTRAINT fpk_condition_v_detail FOREIGN KEY (visit_detail_id) REFERENCES {TARGET_SCHEMA}.visit_detail (visit_detail_id);
