--hesin_oper
ALTER TABLE {SOURCE_SCHEMA}.hesin_oper ADD CONSTRAINT pk_hesin_oper PRIMARY KEY (eid,ins_index) USING INDEX TABLESPACE pg_default;
create index idx_hesin_oper_eid on {SOURCE_SCHEMA}.hesin_oper (eid) TABLESPACE pg_default;