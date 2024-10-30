--tumour
ALTER TABLE {SOURCE_SCHEMA}.tumour ADD CONSTRAINT pk_tumour PRIMARY KEY (e_patid,e_cr_patid,e_cr_id) USING INDEX TABLESPACE pg_default;
create index idx_tumour_e_patid on {SOURCE_SCHEMA}.tumour (e_patid) TABLESPACE pg_default;