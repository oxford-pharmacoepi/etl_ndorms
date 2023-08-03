ALTER TABLE measurement ADD CONSTRAINT fpk_measurement_v_detail FOREIGN KEY (visit_detail_id) REFERENCES visit_detail (visit_detail_id);
