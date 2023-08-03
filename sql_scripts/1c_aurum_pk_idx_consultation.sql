--CONSULTATION
alter table {SOURCE_SCHEMA}.consultation add constraint pk_consultation primary key (consid);
create index idx_consultation_patid on {SOURCE_SCHEMA}.consultation(patid);
cluster {SOURCE_SCHEMA}.consultation using idx_consultation_patid;
create index idx_consultation_consmedcodeid on {SOURCE_SCHEMA}.consultation (consmedcodeid);
create index idx_consultation_staffid on {SOURCE_SCHEMA}.consultation (staffid);
create index idx_consultation_consdate on {SOURCE_SCHEMA}.consultation (consdate);
