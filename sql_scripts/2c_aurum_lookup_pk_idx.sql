-- gender
alter table {SOURCE_SCHEMA}.gender add constraint pk_gender primary key (genderid) USING INDEX TABLESPACE pg_default;

-- region
alter table {SOURCE_SCHEMA}.region add constraint pk_region primary key (regionid) USING INDEX TABLESPACE pg_default;

-- numunit
alter table {SOURCE_SCHEMA}.numunit add constraint pk_numunit primary key (numunitid) USING INDEX TABLESPACE pg_default;

-- quantunit
alter table {SOURCE_SCHEMA}.quantunit add constraint pk_quantunit primary key (quantunitid) USING INDEX TABLESPACE pg_default;

-- refservicetype
alter table {SOURCE_SCHEMA}.refservicetype add constraint pk_refservicetype primary key (refservicetypeid) USING INDEX TABLESPACE pg_default;

-- jobcat
alter table {SOURCE_SCHEMA}.jobcat add constraint pk_jobcat primary key (jobcatid) USING INDEX TABLESPACE pg_default;

-- productdictionary
alter table {SOURCE_SCHEMA}.productdictionary add constraint pk_productdictionary primary key (prodcodeid) USING INDEX TABLESPACE pg_default;

-- medicaldictionary
alter table {SOURCE_SCHEMA}.medicaldictionary add constraint pk_medicaldictionary primary key (medcodeid) USING INDEX TABLESPACE pg_default;
create index idx_medicaldictionary_rcode on {SOURCE_SCHEMA}.medicaldictionary (cleansedreadcode) TABLESPACE pg_default;
create index idx_medicaldictionary_snomed on {SOURCE_SCHEMA}.medicaldictionary (snomedctconceptid) TABLESPACE pg_default;

--VisionToEmisMigrators
alter table {SOURCE_SCHEMA}.VisionToEmisMigrators add constraint pk_VisionToEmisMigrators primary key (gold_pracid) USING INDEX TABLESPACE pg_default;
