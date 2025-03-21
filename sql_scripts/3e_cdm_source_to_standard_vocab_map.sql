drop table if exists {VOCABULARY_SCHEMA}.source_to_standard_vocab_map CASCADE;

CREATE TABLE IF NOT EXISTS {VOCABULARY_SCHEMA}.source_to_standard_vocab_map
(
    source_code varchar(500),
    source_concept_id integer,
    source_code_description varchar(500),
    source_vocabulary_id varchar(30),
    source_domain_id varchar(20),
    source_concept_class_id varchar(20),
    source_valid_start_date date,
    source_valid_end_date date,
    source_invalid_reason varchar(1),
    target_concept_id integer,
    target_concept_name varchar(500),
    target_vocabulary_id varchar(30),
    target_domain_id varchar(20),
    target_concept_class_id varchar(20),
    target_invalid_reason varchar(1),
    target_standard_concept varchar(1)
)TABLESPACE pg_default;

WITH CTE_VOCAB_MAP AS (
       SELECT c.concept_code AS SOURCE_CODE, c.concept_id AS SOURCE_CONCEPT_ID, c.concept_name AS SOURCE_CODE_DESCRIPTION, c.vocabulary_id AS SOURCE_VOCABULARY_ID,
                           c.domain_id AS SOURCE_DOMAIN_ID, c.CONCEPT_CLASS_ID AS SOURCE_CONCEPT_CLASS_ID,
                                                   c.VALID_START_DATE AS SOURCE_VALID_START_DATE, c.VALID_END_DATE AS SOURCE_VALID_END_DATE, c.INVALID_REASON AS SOURCE_INVALID_REASON,
                           c1.concept_id AS TARGET_CONCEPT_ID, c1.concept_name AS TARGET_CONCEPT_NAME, c1.VOCABULARY_ID AS TARGET_VOCABULARY_ID, c1.domain_id AS TARGET_DOMAIN_ID, c1.concept_class_id AS TARGET_CONCEPT_CLASS_ID,
                           c1.INVALID_REASON AS TARGET_INVALID_REASON, c1.standard_concept AS TARGET_STANDARD_CONCEPT
       FROM {VOCABULARY_SCHEMA}.CONCEPT C
             JOIN {VOCABULARY_SCHEMA}.CONCEPT_RELATIONSHIP CR
                        ON C.CONCEPT_ID = CR.CONCEPT_ID_1
                        AND CR.invalid_reason IS NULL
                        AND lower(cr.relationship_id) = 'maps to'
              JOIN {VOCABULARY_SCHEMA}.CONCEPT C1
                        ON CR.CONCEPT_ID_2 = C1.CONCEPT_ID
                        AND (C1.INVALID_REASON IS NULL OR C1.INVALID_REASON = '')
       UNION
       SELECT source_code, SOURCE_CONCEPT_ID, SOURCE_CODE_DESCRIPTION, source_vocabulary_id, c1.domain_id AS SOURCE_DOMAIN_ID, c2.CONCEPT_CLASS_ID AS SOURCE_CONCEPT_CLASS_ID,
                                        c1.VALID_START_DATE AS SOURCE_VALID_START_DATE, c1.VALID_END_DATE AS SOURCE_VALID_END_DATE,
                     stcm.INVALID_REASON AS SOURCE_INVALID_REASON,target_concept_id, c2.CONCEPT_NAME AS TARGET_CONCEPT_NAME, target_vocabulary_id, c2.domain_id AS TARGET_DOMAIN_ID, c2.concept_class_id AS TARGET_CONCEPT_CLASS_ID,
                     c2.INVALID_REASON AS TARGET_INVALID_REASON, c2.standard_concept AS TARGET_STANDARD_CONCEPT
       FROM {VOCABULARY_SCHEMA}.source_to_concept_map stcm
              LEFT OUTER JOIN {VOCABULARY_SCHEMA}.CONCEPT c1
                     ON c1.concept_id = stcm.source_concept_id
              LEFT OUTER JOIN {VOCABULARY_SCHEMA}.CONCEPT c2
                     ON c2.CONCEPT_ID = stcm.target_concept_id
       WHERE stcm.INVALID_REASON IS NULL OR stcm.INVALID_REASON = ''
)
INSERT INTO {VOCABULARY_SCHEMA}.source_to_standard_vocab_map
select * from CTE_VOCAB_MAP;

ALTER TABLE {VOCABULARY_SCHEMA}.source_to_standard_vocab_map ADD CONSTRAINT xpk_source_to_standard_vocab_map PRIMARY KEY (source_code, source_vocabulary_id, target_concept_id) USING INDEX TABLESPACE pg_default;

create index idx_vocab_map_source_code on {VOCABULARY_SCHEMA}.source_to_standard_vocab_map (source_code) TABLESPACE pg_default;
create index idx_vocab_map_source_vocab_id on {VOCABULARY_SCHEMA}.source_to_standard_vocab_map (source_vocabulary_id) TABLESPACE pg_default;
create index idx_vocab_map_source_concept_id on {VOCABULARY_SCHEMA}.source_to_standard_vocab_map (source_concept_id) TABLESPACE pg_default;
