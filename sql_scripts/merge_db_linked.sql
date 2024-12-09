--create or replace procedure public.merge_db_linked(
--	IN schema1 NAME, Add parameters at a later stage and remove local variables
--	IN schema2 NAME,
--	IN schema3 NAME
--) LANGUAGE plpgsql AS 
-- CREATE PROCEDURE OR USE DO
DO
$$
DECLARE
	schema1 TEXT;
	schema2 TEXT;
	schema3 TEXT;
	tbl_to_delete TEXT;
	query1 TEXT;
	results INTEGER;
BEGIN
	schema1 := 'public_aurum_hesapc'; -- primary source
	schema2 := 'public_ncrascr';-- linked source
	schema3 := 'public';

--	schema1 := 'public_gold_hesapc';
--	schema2 := 'public_ncrascr';
--	schema3 := 'public';
	tbl_to_delete := '_patid_deleted';
------------------------------------------------------
-- 1A. Vocabularies needs to be built BEFORE running the following code
------------------------------------------------------
-- If not possible to build the vocabularies because the content is wrong, copy them
--    FOR query1 IN 
--		SELECT format('CREATE TABLE IF NOT EXISTS %I.%I (LIKE %I.%I EXCLUDING CONSTRAINTS) TABLESPACE pg_default;', schema2, tablename, schema1, tablename)
--		FROM pg_tables 
--		WHERE schemaname = schema1
--		AND upper(tablename) IN ('CONCEPT', 'CONCEPT_ANCESTOR', 'CONCEPT_CLASS', 'CONCEPT_RELATIONSHIP', 'CONCEPT_SYNONYM', 'DOMAIN',
--							'DRUG_STRENGTH', 'FACT_RELATIONSHIP', 'METADATA', 'RELATIONSHIP', 'SOURCE_TO_CONCEPT_MAP', 
--							'SOURCE_TO_SOURCE_VOCAB_MAP', 'SOURCE_TO_STANDARD_VOCAB_MAP', 'VOCABULARY')
--	LOOP
--		RAISE NOTICE 'appliying %', query1;
--		EXECUTE query1;
--   END LOOP;
------------------------------------------------------
-- 1B. Vocabularies needs to be built BEFORE running the following code
------------------------------------------------------
-- If not possible to build the vocabularies because the content is wrong, copy them
--   FOR query1 IN 
--		SELECT format('INSERT INTO %I.%I SELECT * FROM %I.%I;', schema2, tablename, schema1, tablename)
--		FROM pg_tables WHERE schemaname = schema1
--		AND upper(tablename) IN ('CONCEPT', 'CONCEPT_ANCESTOR', 'CONCEPT_CLASS', 'CONCEPT_RELATIONSHIP', 'CONCEPT_SYNONYM', 'DOMAIN',
--							'DRUG_STRENGTH', 'FACT_RELATIONSHIP', 'METADATA', 'RELATIONSHIP', 'SOURCE_TO_CONCEPT_MAP', 
--							'SOURCE_TO_SOURCE_VOCAB_MAP', 'SOURCE_TO_STANDARD_VOCAB_MAP', 'VOCABULARY')
--    LOOP
--		RAISE NOTICE 'appliying %', query1;
--		EXECUTE query1;
--    END LOOP;
------------------------------------------------------
-- 2. Create all tables in schema3 without constraints as they are in schema1
-- Vocabulary tables will not be affected as already created
------------------------------------------------------
    FOR query1 IN 
		SELECT format('CREATE TABLE IF NOT EXISTS %I.%I (LIKE %I.%I EXCLUDING CONSTRAINTS) TABLESPACE pg_default;', schema3, tablename, schema1, tablename)
		FROM pg_tables 
		WHERE schemaname = schema1
		AND RIGHT(tablename,4) <> '_tmp'
		AND RIGHT(tablename,4) <> '_old'
    LOOP
		RAISE NOTICE 'appliying %', query1;
		EXECUTE query1;
    END LOOP;
------------------------------------------------------
-- 3. Insert content to schema3 from schema1 of all CDM tables non-patient related
------------------------------------------------------
   FOR query1 IN 
		SELECT format('INSERT INTO %I.%I SELECT * FROM %I.%I;', schema3, tablename, schema1, tablename)
		FROM pg_tables WHERE schemaname = schema1
		AND tablename IN ('cdm_source', 'provider', 'care_site', 'location')
    LOOP
		RAISE NOTICE 'appliying %', query1;
		EXECUTE query1;
    END LOOP;
------------------------------------------------------
-- 4. Insert content to schema3 from schema1 of all CDM tables patient related and exclude those records belonging to `tbl_to_delete`
------------------------------------------------------
--EPISODE_EVENT NEEDS TO BE ADDED IN A SEPARATE QUERY
    FOR query1 IN 
		SELECT format('INSERT INTO %I.%I 
			SELECT t1.* FROM %I.%I AS t1
			LEFT JOIN %I.%I AS t2 on t1.person_id = t2.patid
			WHERE t2.patid is null;', schema3, tablename, schema1, tablename, schema1, tbl_to_delete)
		FROM pg_tables WHERE schemaname = schema1
		AND tablename IN ('condition_era', 'condition_occurrence', 'death', 'device_exposure', 'drug_era', 'drug_exposure', 'episode', 'measurement', 'observation', 'observation_period', 'person', 'procedure_occurrence', 'specimen', 'visit_detail', 'visit_occurrence')
   LOOP
		RAISE NOTICE 'appliying %', query1;
		EXECUTE query1;
    END LOOP;
------------------------------------------------------
-- 5. Add INDEX to PERSON
------------------------------------------------------
	query1 = format('CREATE UNIQUE INDEX IF NOT EXISTS idx_person_id ON %I.person (person_id ASC) TABLESPACE pg_default;',schema3);
	EXECUTE query1;
------------------------------------------------------
-- 6. Update schema3.PERSON table with race information taken from schema2 if not already present
------------------------------------------------------
	query1 = format('UPDATE %I.person AS t1
					SET race_concept_id = t2.race_concept_id,
					race_source_value = t2.race_source_value
					FROM %I.person AS t2 
					WHERE t1.person_id = t2.person_id
					AND (t1.race_concept_id = 0 OR t1.race_concept_id is null);', schema3, schema2);
	RAISE NOTICE 'appliying %', query1;
	EXECUTE query1;
------------------------------------------------------
-- 7. Insert content from schema2 of all CDM tables patient related (escluding DEATH, OBSERVATION_PERIOD, PERSON) 
--    and exclude those records belonging to `tbl_to_delete`
------------------------------------------------------
    FOR query1 IN 
		SELECT format('INSERT INTO %I.%I 
			SELECT t1.* FROM %I.%I AS t1
			LEFT JOIN %I.%I AS t2 on t1.person_id = t2.patid
			WHERE t2.patid is null;', schema3, tablename, schema2, tablename, schema1, tbl_to_delete)
		FROM pg_tables WHERE schemaname = schema2
		AND tablename IN ('condition_era', 'condition_occurrence', 'device_exposure', 'drug_era', 'drug_exposure', 'episode', 'measurement', 'observation', 'procedure_occurrence', 'specimen', 'visit_detail', 'visit_occurrence')
    LOOP
		RAISE NOTICE 'appliying %', query1;
		EXECUTE query1;
    END LOOP;
------------------------------------------------------
-- 8. Insert content to schema3 from schema2.PROVIDER
------------------------------------------------------
	query1 = format('INSERT INTO %I.provider SELECT * FROM %I.provider;', schema3, schema2);
	RAISE NOTICE 'appliying %', query1;
	EXECUTE query1;
------------------------------------------------------
-- 9. Insert content to schema3 from schema2.EPISODE_EVENT
------------------------------------------------------
	query1 = format('INSERT INTO %I.episode_event 
					SELECT t1.* FROM %I.episode_event as t1
					INNER JOIN %I.episode AS t2 on t1.episode_id = t2.episode_id
					LEFT JOIN %I.%I AS t3 on t2.person_id = t3.patid
					WHERE t3.patid is null;', schema3, schema2, schema2, schema1, tbl_to_delete);
	RAISE NOTICE 'appliying %', query1;
	EXECUTE query1;

------------------------------------------------------
-- 10. Insert content to schema3._PATID_DELETED from schema1._PATID_DELETED (always present)
------------------------------------------------------
	query1 = format('INSERT INTO %I.%I SELECT * FROM %I.%I;', schema3, tbl_to_delete, schema1, tbl_to_delete);
	RAISE NOTICE 'appliying %', query1;
	EXECUTE query1;
------------------------------------------------------
-- 11. Update schema3.OBSERVATION_PERIOD to consider all merged data sources (schema1, schema2)
-- We leave the OBSERVATION_PERIOD records from Primary Care (GOLD/AURUM) unchanged (period_type_concept_id=32880)
-- We insert/update an OBSERVATION_PERIOD record per patient with the "summary" of all observation_periods (period_type_concept_id=32882)
------------------------------------------------------
	query1 = format('WITH cte as (SELECT 1 FROM %I.%I WHERE period_type_concept_id = 32882 LIMIT 1) SELECT count(*) FROM cte;', schema3, 'observation_period');
	EXECUTE query1 INTO results;
	IF results = 0
		THEN 
			query1 = format('DROP SEQUENCE IF EXISTS %I.sequence_op;',schema3);
			EXECUTE query1;
			query1 = format('CREATE SEQUENCE %I.sequence_op INCREMENT 1;',schema3);
			EXECUTE query1;
			query1 = format('SELECT SETVAL(''%I.sequence_op'', (SELECT max_id from %I._max_ids WHERE lower(tbl_name) = ''observation_period''));',schema3, schema1);
			EXECUTE query1;
			query1 = format('INSERT INTO %I.observation_period
				SELECT 
				NEXTVAL(''%I.sequence_op'') AS observation_period_id, 
				t1.person_id,
				LEAST(t1.observation_period_start_date, t2.observation_period_start_date) as observation_period_start_date,
				GREATEST(t1.observation_period_end_date, t2.observation_period_end_date) as observation_period_end_date,
				32882 as period_type_concept_id
				FROM %I.observation_period AS t1
				LEFT JOIN %I.observation_period AS t2 ON t1.person_id = t2.person_id
				LEFT JOIN %I.%I AS t3 on t1.person_id = t3.patid
				WHERE t3.patid is null
				ORDER BY t1.person_id;', schema3, schema3, schema1, schema2, schema3, tbl_to_delete);
			EXECUTE query1;
			query1 = format('DROP SEQUENCE IF EXISTS %I.sequence_op;',schema3);
			EXECUTE query1;
		ELSE 
			query1 = format('WITH cte AS (
					SELECT t1.observation_period_id,
					LEAST(t1.observation_period_start_date, t2.observation_period_start_date) as observation_period_start_date,
					GREATEST(t1.observation_period_end_date, t2.observation_period_end_date) as observation_period_end_date
					FROM %I.observation_period AS t1
					INNER JOIN %I.observation_period AS t2 ON t1.person_id = t2.person_id
					AND t1.period_type_concept_id = 32882
					AND t2.period_type_concept_id = 32880
				)
				UPDATE %I.observation_period AS t1
				SET 
				observation_period_start_date = t2.observation_period_start_date,
				observation_period_end_date = t2.observation_period_end_date
				FROM cte as t2
				WHERE t1.observation_period_id = t2.observation_period_id;', schema3, schema2, schema3);
			EXECUTE query1;
	END IF;
------------------------------------------------------
-- 12. Update schema3.CDM_SOURCE
------------------------------------------------------
	query1 = format('UPDATE %I.cdm_source 
					SET source_description = CONCAT(upper(source_description), '' + '', upper(substring(''%I'', ''[^_]*$'')));', schema3, schema3);
	RAISE NOTICE 'appliying %', query1;
	EXECUTE query1;
-- 12. Add CONSTRAINTS for CDM (py 5_build_cdm_pk_idx_fk.py -FD:\cprd\...)
-- 13. Create table _records (py 7_count_cdm_records.py -FD:\cprd\...)
-- When all merges are complete, 
-- 		14. Check Tablespaces
-- 		15. Run Achilles, DQD
END
$$;
