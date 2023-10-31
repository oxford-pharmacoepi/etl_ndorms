delete from {VOCABULARY_SCHEMA}.source_to_concept_map
where source_vocabulary_id = %s and source_code = %s;

delete from {VOCABULARY_SCHEMA}.source_to_source_vocab_map
where source_vocabulary_id = %s and source_code = %s;

delete from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map ss
where source_vocabulary_id = %s and source_code = %s;