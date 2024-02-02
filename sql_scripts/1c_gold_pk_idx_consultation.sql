ALTER TABLE {SOURCE_SCHEMA}.consultation ADD CONSTRAINT pk_consultation PRIMARY KEY(patid, consid, constype) USING INDEX TABLESPACE pg_default;
CLUSTER {SOURCE_SCHEMA}.consultation USING pk_consultation;
