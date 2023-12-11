--hesop_appointment
alter table {SOURCE_SCHEMA}.hesop_appointment add constraint pk_hesop_appointment primary key (patid, attendkey);
create index idx_hesop_appointment_patid on {SOURCE_SCHEMA}.hesop_appointment (patid, attendkey);
cluster {SOURCE_SCHEMA}.hesop_appointment using idx_hesop_appointment_patid;