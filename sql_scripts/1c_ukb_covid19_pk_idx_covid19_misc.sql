--Covid19_misc
ALTER TABLE {SOURCE_SCHEMA}.covid19_misc ADD CONSTRAINT pk_covid19_misc PRIMARY KEY (eid) USING INDEX TABLESPACE pg_default;
create index idx_covid19_misc_eid on {SOURCE_SCHEMA}.covid19_misc (eid) TABLESPACE pg_default;