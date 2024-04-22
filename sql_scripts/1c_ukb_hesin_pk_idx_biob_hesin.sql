--biob_hesin
ALTER TABLE {SOURCE_SCHEMA}.biob_hesin ADD CONSTRAINT pk_biob_hesin PRIMARY KEY (eid,ins_index) USING INDEX TABLESPACE pg_default;
create index idx_biob_hesin_eid on {SOURCE_SCHEMA}.biob_hesin (eid) TABLESPACE pg_default;