--treatment
ALTER TABLE {SOURCE_SCHEMA}.treatment ADD CONSTRAINT pk_treatment PRIMARY KEY (e_patid,e_cr_patid,e_cr_id) USING INDEX TABLESPACE pg_default;
create index idx_treatment_e_patid on {SOURCE_SCHEMA}.treatment (e_patid) TABLESPACE pg_default;