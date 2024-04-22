--hesin_delivery
ALTER TABLE {SOURCE_SCHEMA}.hesin_delivery ADD CONSTRAINT pk_hesin_delivery PRIMARY KEY (eid,ins_index,arr_index) USING INDEX TABLESPACE pg_default;
create index idx_hesin_delivery_eid on {SOURCE_SCHEMA}.hesin_delivery (eid) TABLESPACE pg_default;