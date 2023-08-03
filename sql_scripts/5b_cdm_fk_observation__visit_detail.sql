ALTER TABLE observation ADD CONSTRAint fpk_observation_v_detail FOREIGN KEY (visit_detail_id) REFERENCES visit_detail (visit_detail_id);
