--baseline
alter table {SOURCE_SCHEMA}.baseline add constraint pk_baseline primary key (eid) USING INDEX TABLESPACE pg_default;