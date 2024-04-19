--Covid19_result_england
ALTER TABLE {SOURCE_SCHEMA}.covid19_result_england ADD CONSTRAINT pk_covid19_result_england PRIMARY KEY (eid,specdate,spectype) USING INDEX TABLESPACE pg_default;
create index idx_covid19_result_england_eid on {SOURCE_SCHEMA}.covid19_result_england (eid) TABLESPACE pg_default;
