--tumour
ALTER TABLE {SOURCE_SCHEMA}.tumour ADD CONSTRAINT pk_tumour PRIMARY KEY (patid,cr_patid,cr_id) USING INDEX TABLESPACE pg_default;
create index idx_tumour_patid on {SOURCE_SCHEMA}.tumour (patid) TABLESPACE pg_default;