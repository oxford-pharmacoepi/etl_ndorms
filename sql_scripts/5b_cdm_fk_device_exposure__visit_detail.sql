ALTER TABLE device_exposure ADD CONSTRAINT fpk_device_v_detail FOREIGN KEY (visit_detail_id) REFERENCES visit_detail (visit_detail_id);
