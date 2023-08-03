ALTER TABLE visit_detail ADD CONSTRAINT fpk_v_detail_preceding FOREIGN KEY (preceding_visit_detail_id) REFERENCES visit_detail (visit_detail_id);

ALTER TABLE visit_detail ADD CONSTRAINT fpk_v_detail_parent FOREIGN KEY (visit_detail_parent_id) REFERENCES visit_detail (visit_detail_id);
