--hes_hospital
alter table {SOURCE_SCHEMA}.hes_hospital add constraint pk_hes_hospital primary key (spno);
create index idx_hesapc_hospital_patid on {SOURCE_SCHEMA}.hes_hospital (patid, spno);
cluster {SOURCE_SCHEMA}.hes_hospital using idx_hesapc_hospital_patid;