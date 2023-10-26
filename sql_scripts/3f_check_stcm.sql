select ss.source_code, ss.source_concept_id, ss.source_vocabulary_id, ss.source_code_description, 
cr.concept_id_2 as target_concept_id, c.vocabulary_id,  c.valid_start_date, c.valid_end_date, c.invalid_reason
from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map ss
join {VOCABULARY_SCHEMA}.concept_relationship cr on cr.concept_id_1 = ss.target_concept_id
left join {VOCABULARY_SCHEMA}.concept c on cr.concept_id_2 = c.concept_id
where ss.source_vocabulary_id = %s
and (ss.target_standard_concept is null or ss.target_invalid_reason is not null)
and ss.target_concept_id != 0
and cr.relationship_id = 'Maps to'
order by ss.source_code;