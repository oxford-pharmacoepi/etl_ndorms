ALTER TABLE {TARGET_SCHEMA}.visit_detail ADD CONSTRAINT fpk_v_detail_person FOREIGN KEY (person_id) REFERENCES {TARGET_SCHEMA}.person (person_id);
