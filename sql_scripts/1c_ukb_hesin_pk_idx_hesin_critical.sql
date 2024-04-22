--hesin_critical
ALTER TABLE {SOURCE_SCHEMA}.hesin_critical ADD CONSTRAINT pk_hesin_critical PRIMARY KEY (eid,ins_index,arr_index) USING INDEX TABLESPACE pg_default;
create index idx_hesin_critical_eid on {SOURCE_SCHEMA}.hesin_critical (eid) TABLESPACE pg_default;