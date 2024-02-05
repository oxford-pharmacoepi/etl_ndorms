--OBSERVATION
alter table {SOURCE_SCHEMA}.observation add constraint pk_observation primary key (obsid) USING INDEX TABLESPACE pg_default;
create index idx_observation_patid on {SOURCE_SCHEMA}.observation (patid) TABLESPACE pg_default;
cluster {SOURCE_SCHEMA}.observation using idx_observation_patid;
create index idx_observation_medcodeid on {SOURCE_SCHEMA}.observation (medcodeid) TABLESPACE pg_default;
create index idx_observation_consid on {SOURCE_SCHEMA}.observation (consid) TABLESPACE pg_default;
create index idx_observation_numunitid on {SOURCE_SCHEMA}.observation (numunitid) TABLESPACE pg_default;
create index idx_observation_staffid on {SOURCE_SCHEMA}.observation (staffid) TABLESPACE pg_default;
create index idx_observation_obsdate on {SOURCE_SCHEMA}.observation (obsdate) TABLESPACE pg_default;
