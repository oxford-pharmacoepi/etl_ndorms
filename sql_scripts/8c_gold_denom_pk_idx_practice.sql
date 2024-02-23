alter table {SOURCE_SCHEMA}.gold_allpractices add constraint pk_denom_prac primary key (pracid) USING INDEX TABLESPACE pg_default;
