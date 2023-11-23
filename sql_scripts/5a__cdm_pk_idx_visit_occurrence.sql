alter table {TARGET_SCHEMA}.visit_occurrence add constraint xpk_visit_occurrence primary key (visit_occurrence_id) USING INDEX TABLESPACE pg_default;;
create index idx_visit_occ1 on {TARGET_SCHEMA}.visit_occurrence (person_id, visit_start_date, care_site_id) TABLESPACE pg_default;
CLUSTER visit_occurrence USING idx_visit_occ1;
CREATE INDEX idx_visit_concept_id ON visit_occurrence (visit_concept_id ASC) TABLESPACE pg_default;
