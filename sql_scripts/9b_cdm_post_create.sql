-----------------------------------------------------
CREATE TABLE IF NOT EXISTS {RESULT_SCHEMA}.achilles_analysis
(
    analysis_id integer,
    analysis_name varchar(255),
    stratum_1_name varchar(255),
    stratum_2_name varchar(255),
    stratum_3_name varchar(255),
    stratum_4_name varchar(255),
    stratum_5_name varchar(255),
    is_default integer,
    category varchar(255)
)
TABLESPACE tablespace_e;

-------------------------------------------
CREATE TABLE IF NOT EXISTS {RESULT_SCHEMA}.achilles_results
(
    analysis_id integer,
    stratum_1 character varying,
    stratum_2 character varying,
    stratum_3 character varying,
    stratum_4 character varying,
    stratum_5 character varying,
    count_value bigint
)
TABLESPACE tablespace_e;

----------------------------------------
CREATE TABLE IF NOT EXISTS {RESULT_SCHEMA}.achilles_results_dist
(
    analysis_id integer,
    stratum_1 character varying,
    stratum_2 character varying,
    stratum_3 character varying,
    stratum_4 character varying,
    stratum_5 character varying,
    count_value bigint,
    min_value numeric,
    max_value numeric,
    avg_value numeric,
    stdev_value numeric,
    median_value numeric,
    p10_value numeric,
    p25_value numeric,
    p75_value numeric,
    p90_value numeric
)
TABLESPACE tablespace_e;

-----------------------
CREATE TABLE IF NOT EXISTS {RESULT_SCHEMA}.dqd_results
(
    num_violated_rows bigint,
    pct_violated_rows numeric,
    num_denominator_rows bigint,
    execution_time character varying(255),
    query_text character varying(8000),
    check_name character varying(255),
    check_level character varying(255),
    check_description character varying(8000),
    cdm_table_name character varying(255),
    cdm_field_name character varying(255),
    concept_id character varying(255),
    unit_concept_id character varying(255),
    sql_file character varying(255),
    category character varying(255),
    subcategory character varying(255),
    context character varying(255),
    warning character varying(255),
    error character varying(8000),
    checkid character varying(1024),
    is_error integer,
    not_applicable integer,
    failed integer,
    passed integer,
    not_applicable_reason character varying(8000),
    threshold_value integer,
    notes_value character varying(8000)
)
TABLESPACE tablespace_e;
