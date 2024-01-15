--hes_diagnosis_epi
alter table {SOURCE_SCHEMA}.hes_diagnosis_epi add constraint pk_hes_diagnosis_epi primary key (patid,epikey,d_order) USING INDEX TABLESPACE pg_default;
create index idx_hesapc_diagnosis_epi_patid on {SOURCE_SCHEMA}.hes_diagnosis_epi (patid,epikey,d_order);
cluster {SOURCE_SCHEMA}.hes_diagnosis_epi using idx_hesapc_diagnosis_epi_patid;
