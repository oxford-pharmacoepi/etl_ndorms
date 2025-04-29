--hesop_clinical
alter table {SOURCE_SCHEMA}.hesop_clinical add constraint pk_hesop_clinical primary key (patid, attendkey, diagnosis, diag_order) USING INDEX TABLESPACE pg_default;
create index idx_hesop_clinical_patid on {SOURCE_SCHEMA}.hesop_clinical (patid, attendkey, diagnosis, diag_order) TABLESPACE pg_default;
cluster {SOURCE_SCHEMA}.hesop_clinical using idx_hesop_clinical_patid;

create index idx_hesop_clinical_specialty on {SOURCE_SCHEMA}.hesop_clinical (tretspef, mainspef) TABLESPACE pg_default;

