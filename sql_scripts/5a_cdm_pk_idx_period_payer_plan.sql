ALTER TABLE PAYER_PLAN_PERIOD ADD CONSTRAINT xpk_PAYER_PLAN_PERIOD PRIMARY KEY (payer_plan_period_id);

CREATE INDEX idx_period_person_id_1  ON payer_plan_period  (person_id ASC);
CLUSTER payer_plan_period  USING idx_period_person_id_1 ;
