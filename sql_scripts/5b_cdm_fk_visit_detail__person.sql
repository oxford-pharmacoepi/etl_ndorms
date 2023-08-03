ALTER TABLE visit_detail ADD CONSTRAINT fpk_v_detail_person FOREIGN KEY (person_id)  REFERENCES person (person_id);
