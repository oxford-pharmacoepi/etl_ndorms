--hesin_maternity
ALTER TABLE {SOURCE_SCHEMA}.hesin_maternity ADD CONSTRAINT pk_hesin_maternity PRIMARY KEY (eid,ins_index) USING INDEX TABLESPACE pg_default;
create index idx_hesin_maternity_eid on {SOURCE_SCHEMA}.hesin_maternity (eid) TABLESPACE pg_default;