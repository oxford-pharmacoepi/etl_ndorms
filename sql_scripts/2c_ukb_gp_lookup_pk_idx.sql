alter table {SOURCE_SCHEMA}.lookup626 add constraint pk_626 primary key (code) USING INDEX TABLESPACE pg_default;
alter table {SOURCE_SCHEMA}.gold_product add constraint pk_gold_product primary key (prodcode) USING INDEX TABLESPACE pg_default;
alter table {SOURCE_SCHEMA}.gold_daysupply_decodes add constraint pk_gold_daysupply_decodes primary key (id) USING INDEX TABLESPACE pg_default;
alter table {SOURCE_SCHEMA}.gold_daysupply_modes add constraint pk_gold_daysupply_modes primary key (id) USING INDEX TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_gold_product_1 ON {SOURCE_SCHEMA}.gold_product(dmdcode) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_gold_product_2 ON {SOURCE_SCHEMA}.gold_product(productname) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_gold_daysupply_decodes_1 ON {SOURCE_SCHEMA}.gold_daysupply_decodes(prodcode) TABLESPACE pg_default;
CREATE INDEX IF NOT EXISTS idx_gold_daysupply_decodes_2 ON {SOURCE_SCHEMA}.gold_daysupply_decodes(qty, numpacks) TABLESPACE pg_default;

CREATE INDEX IF NOT EXISTS idx_gold_daysupply_modes_1 ON {SOURCE_SCHEMA}.gold_daysupply_modes(prodcode) TABLESPACE pg_default;