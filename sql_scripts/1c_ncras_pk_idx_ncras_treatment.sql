--ncras_treatment
ALTER TABLE {SOURCE_SCHEMA}.ncras_treatment ADD CONSTRAINT pk_ncras_treatment PRIMARY KEY (e_patid,e_cr_patid) USING INDEX TABLESPACE pg_default;
create index idx_ncras_treatment_e_patid on {SOURCE_SCHEMA}.ncras_treatment (e_patid) TABLESPACE pg_default;