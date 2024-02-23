alter table {SOURCE_SCHEMA}.gold_acceptable_pats add constraint pk_accept_pat primary key (patid, gender, yob) USING INDEX TABLESPACE pg_default;
