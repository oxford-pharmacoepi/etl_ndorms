--Covid19_vaccination
ALTER TABLE {SOURCE_SCHEMA}.covid19_vaccination ADD CONSTRAINT pk_covid19_vaccination PRIMARY KEY (eid,vacc_date,product) USING INDEX TABLESPACE pg_default;
create index idx_covid19_vaccination_eid on {SOURCE_SCHEMA}.covid19_vaccination (eid) TABLESPACE pg_default;