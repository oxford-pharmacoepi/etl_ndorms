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
BEGIN
	schema1 := 'public_old';
	schema2 := 'public_hesae';
	schema3 := 'public';
	tbl_to_delete := '_patid_deleted';
------------------------------------------------------
-- 1. Create all tables in schema3 without constraints as they are in the main data source (schema1)
------------------------------------------------------
    FOR query1 IN 
		SELECT format('CREATE TABLE IF NOT EXISTS %I.%I (LIKE %I.%I EXCLUDING CONSTRAINTS) TABLESPACE pg_default;', schema3, tablename, schema1, tablename)
		FROM pg_tables WHERE schemaname = schema1
    LOOP
		RAISE NOTICE 'appliying %', query1;
		EXECUTE query1;
    END LOOP;
------------------------------------------------------
-- 2. Insert content to all vocabularies in schema3 (in this case from the linked source, as more recent, schema2)
------------------------------------------------------
    FOR query1 IN 
		SELECT format('INSERT INTO %I.%I SELECT * FROM %I.%I', schema3, tablename, schema2, tablename)
		FROM pg_tables WHERE schemaname = schema2
		AND tablename IN ('drug_strength', 'concept', 'concept_relationship', 'concept_ancestor', 'concept_synonym', 'vocabulary', 'relationship', 'concept_class', 'domain')
    LOOP
		RAISE NOTICE 'appliying %', query1;
		EXECUTE query1;
    END LOOP;
------------------------------------------------------
-- 3. Insert content to schema3 from primary source (schema1) of all CDM tables non-patient related
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
-- 4. Insert content to schema3 from primary source (schema1) of all CDM tables patient related and exclude those records belonging to `tbl_to_delete`
------------------------------------------------------
    FOR query1 IN 
		SELECT format('INSERT INTO %I.%I SELECT t1.* FROM %I.%I AS t1
			LEFT JOIN %I.%I AS t2 on t1.person_id = t2.patid
			WHERE t2.patid is null;', schema3, tablename, schema1, tablename, schema1, tbl_to_delete)
		FROM pg_tables WHERE schemaname = schema1
		AND tablename IN ('condition_era', 'condition_occurrence', 'death', 'device_exposure', 'drug_era', 'drug_exposure', 'measurement', 'observation', 'observation_period', 'person', 'procedure_occurrence', 'visit_detail', 'visit_occurrence')
    LOOP
		RAISE NOTICE 'appliying %', query1;
		EXECUTE query1;
    END LOOP;
------------------------------------------------------
-- 5. Update schema3.PERSON table with race information taken from the linked source (source2) if not already present
------------------------------------------------------
	query1 = format('UPDATE %I.%I AS t1
					SET race_concept_id = t2.race_concept_id,
					race_source_value = t2.race_source_value
					FROM %I.%I AS t2 
					WHERE t1.person_id = t2.person_id
					AND t1.race_concept_id is null;', schema3, 'person', schema2, 'person');
	EXECUTE query1;
------------------------------------------------------
-- 6. Insert content from linked source (schema2) of all CDM tables patient related (escluding DEATH, OBSERVATION_PERIOD, PERSON) and exclude those records belonging to `tbl_to_delete`
------------------------------------------------------
    FOR query1 IN 
		SELECT format('INSERT INTO %I.%I SELECT t1.* FROM %I.%I AS t1
			LEFT JOIN %I.%I AS t2 on t1.person_id = t2.patid
			WHERE t2.patid is null;', schema3, tablename, schema2, tablename, schema1, tbl_to_delete)
		FROM pg_tables WHERE schemaname = schema1
		AND tablename IN ('condition_era', 'condition_occurrence', 'device_exposure', 'drug_era', 'drug_exposure', 'measurement', 'observation', 'procedure_occurrence', 'visit_detail', 'visit_occurrence')
    LOOP
		RAISE NOTICE 'appliying %', query1;
		EXECUTE query1;
    END LOOP;
------------------------------------------------------
-- 7. Insert content to source3.PROVIDER from source2.PROVIDER
------------------------------------------------------
   FOR query1 IN 
		SELECT format('INSERT INTO %I.%I SELECT * FROM %I.%I;', schema3, tablename, schema2, tablename)
		FROM pg_tables WHERE schemaname = schema1
		AND tablename IN ('provider')
    LOOP
		RAISE NOTICE 'appliying %', query1;
		EXECUTE query1;
    END LOOP;
------------------------------------------------------
-- 8. Update source3.OBSERVATION_PERIOD to consider all merged data sources (schema1, schema2)
-- NOT SURE WE HAVE TO CHANGE OBSERVATION_PERIOD in PUBLIC
------------------------------------------------------
--	query1 = format('UPDATE %I.%I AS t1
--					SET 
--					observation_period_start_date = LEAST(t2.observation_period_start_date, t3.observation_period_start_date),
--					observation_period_end_date = GREATEST(t2.observation_period_end_date, t3.observation_period_end_date)
--					FROM %I.%I AS t2 
--					INNER JOIN %I.%I AS t3 ON t2.person_id = t3.person_id
--					WHERE t1.person_id = t2.person_id;', schema3, 'observation_period', schema1, 'observation_period', schema2, 'observation_period');
--	EXECUTE query1;
------------------------------------------------------
-- 9. Insert content to source3._PATID_DELETED from source1._PATID_DELETED, if present
------------------------------------------------------
   FOR query1 IN 
		SELECT format('INSERT INTO %I.%I SELECT * FROM %I.%I;', schema3, tablename, schema1, tablename)
		FROM pg_tables WHERE schemaname = schema1
		AND tablename IN ('_patid_deleted')
    LOOP
		RAISE NOTICE 'appliying %', query1;
		EXECUTE query1;
    END LOOP;
-- 10. Add CONSTRAINTS for VOCABULARY AND recreate source_to_concept_map + related tables (py 3_load_cdm_vocabulary.py -FD:\cprd\...)
-- 11. Add CONSTRAINTS for CDM (py 5_build_cdm_pk_idx_fk.py -FD:\cprd\...)
-- 12. Create table _records (py 7_count_cdm_records.py -FD:\cprd\...)
-- 13. Run Achilles
-- 14. Check Tablespaces
END
$$;
