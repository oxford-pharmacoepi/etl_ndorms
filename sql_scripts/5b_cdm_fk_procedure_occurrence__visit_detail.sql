ALTER TABLE procedure_occurrence ADD CONSTRAINT fpk_procedure_v_detail FOREIGN KEY (visit_detail_id) REFERENCES visit_detail (visit_detail_id);

