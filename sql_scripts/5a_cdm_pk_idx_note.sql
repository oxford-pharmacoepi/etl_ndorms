ALTER TABLE {TARGET_SCHEMA}.NOTE ADD CONSTRAINT xpk_NOTE PRIMARY KEY (note_id) USING INDEX TABLESPACE pg_default;

CREATE INDEX idx_note_person_id_1 ON {TARGET_SCHEMA}.note (person_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.note USING idx_note_person_id_1;
CREATE INDEX idx_note_concept_id_1 ON {TARGET_SCHEMA}.note (note_type_concept_id ASC) TABLESPACE pg_default;
CREATE INDEX idx_note_visit_id_1 ON {TARGET_SCHEMA}.note (visit_occurrence_id ASC) TABLESPACE pg_default;
