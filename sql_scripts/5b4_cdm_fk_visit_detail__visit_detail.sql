ALTER TABLE {TARGET_SCHEMA}.visit_detail ADD CONSTRAINT fpk_v_detail_preceding FOREIGN KEY (preceding_visit_detail_id) REFERENCES {TARGET_SCHEMA}.visit_detail (visit_detail_id);
ALTER TABLE {TARGET_SCHEMA}.visit_detail ADD CONSTRAINT fpk_v_detail_parent FOREIGN KEY (parent_visit_detail_id) REFERENCES {TARGET_SCHEMA}.visit_detail (visit_detail_id);

