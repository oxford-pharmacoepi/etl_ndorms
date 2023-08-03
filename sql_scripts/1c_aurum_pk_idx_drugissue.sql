--DRUGISSUE
alter table {SOURCE_SCHEMA}.drugissue add constraint pk_drugissue primary key (issueid);
create index idx_drugissue_patid on {SOURCE_SCHEMA}.drugissue (patid);
cluster {SOURCE_SCHEMA}.drugissue using idx_drugissue_patid;
create index idx_drugissue_prodcodeid on {SOURCE_SCHEMA}.drugissue (prodcodeid);
create index idx_drugissue_probobsid on {SOURCE_SCHEMA}.drugissue (probobsid);
create index idx_drugissue_quantunitid on {SOURCE_SCHEMA}.drugissue (quantunitid);
create index idx_drugissue_staffid on {SOURCE_SCHEMA}.drugissue (staffid);
