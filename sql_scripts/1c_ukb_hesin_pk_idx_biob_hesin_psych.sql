--biob_hesin_psych
ALTER TABLE {SOURCE_SCHEMA}.biob_hesin_psych ADD CONSTRAINT pk_biob_hesin_psych PRIMARY KEY (eid,ins_index) USING INDEX TABLESPACE pg_default;
create index idx_biob_hesin_psych_eid on {SOURCE_SCHEMA}.biob_hesin_psych (eid) TABLESPACE pg_default;