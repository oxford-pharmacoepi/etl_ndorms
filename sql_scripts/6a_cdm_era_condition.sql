-----------------------
-- BUILT CONDITION_ERA 
-----------------------
DROP TABLE IF EXISTS {TARGET_SCHEMA}.condition_era;

WITH cteConditionTarget (condition_occurrence_id, person_id, condition_concept_id, condition_start_date, condition_end_date) AS
(
	SELECT
		co.condition_occurrence_id
		, co.person_id
		, co.condition_concept_id
		, co.condition_start_date
		, COALESCE(NULLIF(co.condition_end_date,NULL), condition_start_date + INTERVAL '1 day') AS condition_end_date
	FROM {TARGET_SCHEMA}.condition_occurrence co
	/* Depending on the needs of your data, you can put more filters on to your code. We assign 0 to our unmapped condition_concept_id's,
	 * and since we don't want different conditions put in the same era, we put in the filter below.
 	 */
	WHERE condition_concept_id != 0
),
--------------------------------------------------------------------------------------------------------------
cteEndDates (person_id, condition_concept_id, end_date) AS -- the magic
(
	SELECT
		person_id
		, condition_concept_id
		, event_date - INTERVAL '30 days' AS end_date -- unpad the end date
	FROM
	(
		SELECT
			person_id
			, condition_concept_id
			, event_date
			, event_type
			, MAX(start_ordinal) OVER (PARTITION BY person_id, condition_concept_id ORDER BY event_date, event_type ROWS UNBOUNDED PRECEDING) AS start_ordinal -- this pulls the current START down from the prior rows so that the NULLs from the END DATES will contain a value we can compare with 
			, ROW_NUMBER() OVER (PARTITION BY person_id, condition_concept_id ORDER BY event_date, event_type) AS overall_ord -- this re-numbers the inner UNION so all rows are numbered ordered by the event date
		FROM
		(
			-- select the start dates, assigning a row number to each
			SELECT
				person_id
				, condition_concept_id
				, condition_start_date AS event_date
				, -1 AS event_type
				, ROW_NUMBER() OVER (PARTITION BY person_id
				, condition_concept_id ORDER BY condition_start_date) AS start_ordinal
			FROM cteConditionTarget
		
			UNION ALL
		
			-- pad the end dates by 30 to allow a grace period for overlapping ranges.
			SELECT
				person_id
				, condition_concept_id
				, condition_end_date + INTERVAL '30 days'
				, 1 AS event_type
				, NULL
			FROM cteConditionTarget
		) RAWDATA
	) e
	WHERE (2 * e.start_ordinal) - e.overall_ord = 0
),
--------------------------------------------------------------------------------------------------------------
cteConditionEnds (person_id, condition_concept_id, condition_start_date, era_end_date) AS
(
SELECT
	c.person_id
	, c.condition_concept_id
	, c.condition_start_date
	, MIN(e.end_date) AS era_end_date
FROM cteConditionTarget c
JOIN cteEndDates e ON c.person_id = e.person_id AND c.condition_concept_id = e.condition_concept_id AND e.end_date >= c.condition_start_date
GROUP BY
	c.condition_occurrence_id
	, c.person_id
	, c.condition_concept_id
	, c.condition_start_date
),
cte0 AS (
	SELECT CASE WHEN '{TARGET_SCHEMA_TO_LINK}' = '{TARGET_SCHEMA}'
		THEN 0 ELSE (SELECT COALESCE(max_id,0) from {TARGET_SCHEMA_TO_LINK}._max_ids 
		WHERE lower(tbl_name) = 'condition_era' ) 
		END as start_id
)
--------------------------------------------------------------------------------------------------------------
SELECT condition_era_id + cte0.start_id as condition_era_id, person_id, condition_concept_id,
	condition_era_start_date, condition_era_end_date, condition_occurrence_count
INTO {TARGET_SCHEMA}.condition_era	
	FROM cte0, (
	SELECT
		row_number() over (order by person_id, condition_concept_id) as condition_era_id
		, person_id
		, condition_concept_id
		, MIN(condition_start_date) AS condition_era_start_date
		, era_end_date::date AS condition_era_end_date
		, COUNT(*)::int AS condition_occurrence_count
	FROM cteConditionEnds
	GROUP BY person_id, condition_concept_id, era_end_date
	ORDER BY person_id, condition_concept_id) as t;

ALTER TABLE {TARGET_SCHEMA}.condition_era SET TABLESPACE pg_default;
-----------------------
-- Add PK / IDX / FK
-----------------------
ALTER TABLE {TARGET_SCHEMA}.condition_era ADD CONSTRAINT xpk_condition_era PRIMARY KEY (condition_era_id) USING INDEX TABLESPACE pg_default;

CREATE INDEX idx_condition_era_person_id  ON {TARGET_SCHEMA}.condition_era (person_id ASC) TABLESPACE pg_default;
CLUSTER {TARGET_SCHEMA}.condition_era  USING idx_condition_era_person_id;

CREATE INDEX idx_condition_era_concept_id ON {TARGET_SCHEMA}.condition_era (condition_concept_id ASC) TABLESPACE pg_default;

ALTER TABLE {TARGET_SCHEMA}.condition_era ADD CONSTRAINT fpk_condition_era_person FOREIGN KEY (person_id) REFERENCES {TARGET_SCHEMA}.person (person_id);

ALTER TABLE {TARGET_SCHEMA}.condition_era ADD CONSTRAINT fpk_condition_era_concept FOREIGN KEY (condition_concept_id) REFERENCES {VOCABULARY_SCHEMA}.concept (concept_id);

