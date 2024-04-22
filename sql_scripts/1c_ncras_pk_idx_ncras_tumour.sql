--ncras_tumour
ALTER TABLE {SOURCE_SCHEMA}.ncras_tumour ADD CONSTRAINT pk_ncras_tumour PRIMARY KEY (e_patid,e_cr_patid,e_cr_id) USING INDEX TABLESPACE pg_default;
create index idx_ncras_tumour_e_patid on {SOURCE_SCHEMA}.ncras_tumour (e_patid) TABLESPACE pg_default;