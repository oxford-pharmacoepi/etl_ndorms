ALTER TABLE {TARGET_SCHEMA}.measurement ADD CONSTRAINT fpk_measurement_v_detail FOREIGN KEY (visit_detail_id) REFERENCES {TARGET_SCHEMA}.visit_detail (visit_detail_id);
