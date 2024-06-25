DROP TABLE IF EXISTS {VOCABULARY_SCHEMA}.temp_stcm;

CREATE TABLE IF NOT EXISTS {VOCABULARY_SCHEMA}.temp_stcm (
		source_code varchar(255) NOT NULL,
		source_concept_id integer NOT NULL,
		source_vocabulary_id varchar(30) NOT NULL,
		source_code_description varchar(300) NULL,
		target_concept_id integer NOT NULL,
		target_vocabulary_id varchar(30) NOT NULL,
		valid_start_date date NOT NULL,
		valid_end_date date NOT NULL,
		invalid_reason varchar(1) NULL,
		PRIMARY KEY(source_code, source_vocabulary_id, target_concept_id)
)TABLESPACE pg_default;