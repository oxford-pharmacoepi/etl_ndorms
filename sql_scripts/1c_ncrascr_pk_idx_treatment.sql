--treatment
ALTER TABLE {SOURCE_SCHEMA}.treatment ADD CONSTRAINT pk_treatment PRIMARY KEY (treatment_id) USING INDEX TABLESPACE pg_default;
create index idx_treatment_e_patid on {SOURCE_SCHEMA}.treatment(e_patid) TABLESPACE pg_default;