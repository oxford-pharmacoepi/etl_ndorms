ALTER TABLE {SOURCE_SCHEMA}.consultation ADD CONSTRAINT pk_consultation PRIMARY KEY(patid, consid, constype);
CLUSTER {SOURCE_SCHEMA}.consultation USING pk_consultation;
