DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.sequence_mesurement;
CREATE SEQUENCE {TARGET_SCHEMA}.sequence_mesurement INCREMENT 1;
SELECT setval('{TARGET_SCHEMA}.sequence_mesurement', (SELECT next_id from {TARGET_SCHEMA}._next_ids WHERE lower(tbl_name) = 'measurement'));

--------------------------------
--insert into measurement - No Visit_occurrence / visit_details attached as there is no date
--------------------------------
INSERT INTO {TARGET_SCHEMA}.measurement (measurement_id, person_id, measurement_concept_id, measurement_date, measurement_datetime, 
measurement_type_concept_id, operator_concept_id, value_as_number, measurement_source_value)
select 
NEXTVAL('{TARGET_SCHEMA}.sequence_mesurement') AS measurement_id, 
t2.person_id, 
715996 as measurement_concept_id, 
t2.observation_period_start_date as measurement_date,
t2.observation_period_start_date::timestamp as measurement_datetime,
32817 as measurement_type_concept_id, 
4172703 as operator_concept_id,
t1.uk2011_townsend_10 as value_as_number,
'uk2011_townsend_10' as measurement_source_value
from {LINKAGE_SCHEMA}.patient_townsend as t1
inner join {TARGET_SCHEMA}.observation_period as t2 on t1.patid = t2.person_id;

DROP SEQUENCE IF EXISTS {TARGET_SCHEMA}.sequence_mesurement;

