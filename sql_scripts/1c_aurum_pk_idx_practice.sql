--PRACTICE
alter table {SOURCE_SCHEMA}.practice add constraint pk_practice primary key (pracid) USING INDEX TABLESPACE pg_default;
create index idx_practice_region on {SOURCE_SCHEMA}.practice(region) TABLESPACE pg_default;
cluster {SOURCE_SCHEMA}.practice using idx_practice_region;
