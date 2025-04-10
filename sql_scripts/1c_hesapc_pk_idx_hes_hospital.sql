--hes_hospital
alter table {SOURCE_SCHEMA}.hes_hospital add constraint pk_hes_hospital primary key (patid, spno) USING INDEX TABLESPACE pg_default;
create index idx_hesapc_hospital_patid on {SOURCE_SCHEMA}.hes_hospital (patid, spno) TABLESPACE pg_default;
cluster {SOURCE_SCHEMA}.hes_hospital using idx_hesapc_hospital_patid;
