ALTER TABLE {TARGET_SCHEMA}.payer_plan_period ADD CONSTRAINT xpk_PAYER_PLAN_PERIOD PRIMARY KEY (payer_plan_period_id) USING INDEX TABLESPACE pg_default;

CREATE INDEX idx_period_person_id_1 ON {TARGET_SCHEMA}.payer_plan_period (person_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.payer_plan_period USING idx_period_person_id_1;
