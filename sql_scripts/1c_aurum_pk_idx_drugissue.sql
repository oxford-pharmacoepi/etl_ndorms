--DRUGISSUE
alter table {SOURCE_SCHEMA}.drugissue add constraint pk_drugissue primary key (issueid) USING INDEX TABLESPACE pg_default;
create index idx_drugissue_patid on {SOURCE_SCHEMA}.drugissue (patid) TABLESPACE pg_default;
cluster {SOURCE_SCHEMA}.drugissue using idx_drugissue_patid;
create index idx_drugissue_prodcodeid on {SOURCE_SCHEMA}.drugissue (prodcodeid) TABLESPACE pg_default;
create index idx_drugissue_probobsid on {SOURCE_SCHEMA}.drugissue (probobsid) TABLESPACE pg_default;
create index idx_drugissue_quantunitid on {SOURCE_SCHEMA}.drugissue (quantunitid) TABLESPACE pg_default;
create index idx_drugissue_staffid on {SOURCE_SCHEMA}.drugissue (staffid) TABLESPACE pg_default;
