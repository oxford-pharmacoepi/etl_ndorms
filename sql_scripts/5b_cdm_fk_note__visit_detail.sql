ALTER TABLE {TARGET_SCHEMA}.NOTE ADD CONSTRAINT fpk_NOTE_visit_detail_id FOREIGN KEY (visit_detail_id) REFERENCES {TARGET_SCHEMA}.VISIT_DETAIL (VISIT_DETAIL_ID);
