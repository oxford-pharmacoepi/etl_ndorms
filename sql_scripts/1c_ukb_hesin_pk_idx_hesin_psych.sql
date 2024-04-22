--hesin_psych
ALTER TABLE {SOURCE_SCHEMA}.hesin_psych ADD CONSTRAINT pk_hesin_psych PRIMARY KEY (eid,ins_index) USING INDEX TABLESPACE pg_default;
create index idx_hesin_psych_eid on {SOURCE_SCHEMA}.hesin_psych (eid) TABLESPACE pg_default;