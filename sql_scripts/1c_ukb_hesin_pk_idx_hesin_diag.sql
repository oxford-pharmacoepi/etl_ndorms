--hesin_diag
ALTER TABLE {SOURCE_SCHEMA}.hesin_diag ADD CONSTRAINT pk_hesin_diag PRIMARY KEY (eid,ins_index,arr_index) USING INDEX TABLESPACE pg_default;
create index idx_hesin_diag on {SOURCE_SCHEMA}.hesin_diag (eid) TABLESPACE pg_default;