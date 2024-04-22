--hesin
ALTER TABLE {SOURCE_SCHEMA}.hesin ADD CONSTRAINT pk_hesin PRIMARY KEY (eid,ins_index) USING INDEX TABLESPACE pg_default;
create index idx_hesin_eid on {SOURCE_SCHEMA}.hesin (eid) TABLESPACE pg_default;