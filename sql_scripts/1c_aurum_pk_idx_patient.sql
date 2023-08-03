--PATIENT
alter table {SOURCE_SCHEMA}.patient add constraint pk_patient primary key (patid);
create index idx_patient_staffid on {SOURCE_SCHEMA}.patient(usualgpstaffid);
