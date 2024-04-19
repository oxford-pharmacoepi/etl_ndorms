--Covid19_result_scotland
ALTER TABLE {SOURCE_SCHEMA}.covid19_result_scotland ADD CONSTRAINT pk_covid19_result_scotland PRIMARY KEY (eid,specdate) USING INDEX TABLESPACE pg_default;
create index idx_covid19_result_scotland_eid on {SOURCE_SCHEMA}.covid19_result_scotland (eid) TABLESPACE pg_default;