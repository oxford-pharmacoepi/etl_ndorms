-- gender
alter table {SOURCE_SCHEMA}.gender add constraint pk_gender primary key (genderid);

-- region
alter table {SOURCE_SCHEMA}.region add constraint pk_region primary key (regionid);

-- numunit
alter table {SOURCE_SCHEMA}.numunit add constraint pk_numunit primary key (numunitid);

-- quantunit
alter table {SOURCE_SCHEMA}.quantunit add constraint pk_quantunit primary key (quantunitid);

-- refservicetype
alter table {SOURCE_SCHEMA}.refservicetype add constraint pk_refservicetype primary key (refservicetypeid);

-- jobcat
alter table {SOURCE_SCHEMA}.jobcat add constraint pk_jobcat primary key (jobcatid);

-- productdictionary
alter table {SOURCE_SCHEMA}.productdictionary add constraint pk_productdictionary primary key (prodcodeid);

-- medicaldictionary
alter table {SOURCE_SCHEMA}.medicaldictionary add constraint pk_medicaldictionary primary key (medcodeid);
create index idx_medicaldictionary_rcode on {SOURCE_SCHEMA}.medicaldictionary (cleansedreadcode);
create index idx_medicaldictionary_snomed on {SOURCE_SCHEMA}.medicaldictionary (snomedctconceptid);

--VisionToEmisMigrators
alter table {SOURCE_SCHEMA}.VisionToEmisMigrators add constraint pk_VisionToEmisMigrators primary key (gold_pracid);
