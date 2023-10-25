update {VOCABULARY_SCHEMA}.source_to_concept_map
set target_concept_id = %s,
target_vocabulary_id = %s,
valid_start_date = %s,
valid_end_date = %s
where source_vocabulary_id = %s and source_code = %s;

update {VOCABULARY_SCHEMA}.source_to_source_vocab_map
set target_concept_id = %s,
target_concept_name = %s,
target_vocabulary_id = %s,
target_domain_id = %s,
target_concept_class_id = %s,
target_invalid_reason = null,
target_standard_concept = 'S'
where source_vocabulary_id = %s and source_code = %s;

update {VOCABULARY_SCHEMA}.source_to_standard_vocab_map
set target_concept_id = %s,
target_concept_name = %s,
target_vocabulary_id = %s,
target_domain_id = %s,
target_concept_class_id = %s,
target_invalid_reason = null,
target_standard_concept = 'S'
where source_vocabulary_id = %s and source_code = %s;