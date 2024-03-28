With icd10 as(
	select source_code, source_concept_id, target_concept_id
	from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map
	where source_vocabulary_id = 'ICD10'
	and target_standard_concept = 'S' 
	and target_invalid_reason is null
)
INSERT INTO {TARGET_SCHEMA}.death_ons
SELECT patid,
	COALESCE(dod, dor),
	COALESCE(dod, dor), 
	32815,
	COALESCE(target_concept_id, 0),
	cause,
	COALESCE(source_concept_id, 0)
FROM {SOURCE_SCHEMA}.death_patient as t1
left join icd10 as t2 on t1.cause = t2.source_code;