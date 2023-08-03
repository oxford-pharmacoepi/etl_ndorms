--PRACTICE
alter table {SOURCE_SCHEMA}.practice add constraint pk_practice primary key (pracid);
create index idx_practice_region on {SOURCE_SCHEMA}.practice(region);
cluster {SOURCE_SCHEMA}.practice using idx_practice_region;
