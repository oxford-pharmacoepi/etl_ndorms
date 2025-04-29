--hesop_operation
alter table {SOURCE_SCHEMA}.hesop_operation add constraint pk_hesop_operation primary key (patid, attendkey, operation, opertn_order) USING INDEX TABLESPACE pg_default;
create index idx_hesop_operation_patid on {SOURCE_SCHEMA}.hesop_operation (patid, attendkey, operation, opertn_order) TABLESPACE pg_default;
cluster {SOURCE_SCHEMA}.hesop_operation using idx_hesop_operation_patid;

create index idx_hesop_operation_specialty on {SOURCE_SCHEMA}.hesop_operation (tretspef, mainspef) TABLESPACE pg_default;

