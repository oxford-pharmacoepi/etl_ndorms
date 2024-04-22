--biob_hesin_critical
ALTER TABLE {SOURCE_SCHEMA}.biob_hesin_critical ADD CONSTRAINT pk_biob_hesin_critical PRIMARY KEY (eid,ins_index,arr_index) USING INDEX TABLESPACE pg_default;
create index idx_biob_hesin_critical_eid on {SOURCE_SCHEMA}.biob_hesin_critical (eid) TABLESPACE pg_default;