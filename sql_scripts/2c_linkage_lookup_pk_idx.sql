-- linkage_coverage
alter table {LINKAGE_SCHEMA}.linkage_coverage add constraint pk_linkage_coverage primary key (data_source) USING INDEX TABLESPACE pg_default;;

-- linkage_eligibility
alter table {LINKAGE_SCHEMA}.linkage_eligibility add constraint pk_linkage_eligibility primary key (patid) USING INDEX TABLESPACE pg_default;;
CREATE INDEX IF NOT EXISTS idx_linkage_eligibility ON {LINKAGE_SCHEMA}.linkage_eligibility (lsoa_e, hes_apc_e, ons_e) TABLESPACE pg_default;
