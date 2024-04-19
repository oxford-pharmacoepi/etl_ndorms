--Covid19_result_wales
ALTER TABLE {SOURCE_SCHEMA}.covid19_result_wales ADD CONSTRAINT pk_covid19_result_wales PRIMARY KEY (eid,specdate,spectype) USING INDEX TABLESPACE pg_default;
create index idx_covid19_result_wales_eid on {SOURCE_SCHEMA}.covid19_result_wales (eid) TABLESPACE pg_default;