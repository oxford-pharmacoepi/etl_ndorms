--biob_hesin_delivery
ALTER TABLE {SOURCE_SCHEMA}.biob_hesin_delivery ADD CONSTRAINT pk_biob_hesin_delivery PRIMARY KEY (eid,ins_index,arr_index) USING INDEX TABLESPACE pg_default;
create index idx_biob_hesin_delivery_eid on {SOURCE_SCHEMA}.biob_hesin_delivery (eid) TABLESPACE pg_default;