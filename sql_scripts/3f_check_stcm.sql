With base AS(
	select * 
	from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map AS ss
	left join {VOCABULARY_SCHEMA}.concept_relationship cr on cr.concept_id_1 = ss.target_concept_id
	where ss.source_vocabulary_id = %s
	and (ss.target_standard_concept is null or ss.target_invalid_reason is not null)
), map_to AS(
	select b.source_code, b.source_concept_id, b.source_vocabulary_id, b.source_code_description, 
	b.concept_id_2 as target_concept_id, c.vocabulary_id,  c.valid_start_date, c.valid_end_date, c.invalid_reason 
	from base AS b
	join {VOCABULARY_SCHEMA}.concept_relationship cr on cr.concept_id_1 = b.target_concept_id
	join {VOCABULARY_SCHEMA}.concept c on b.concept_id_2 = c.concept_id
	where b.relationship_id = 'Maps to'
), rep_by AS(
	select b.source_code, b.source_concept_id, b.source_vocabulary_id, b.source_code_description, b.concept_id_2
	from base AS b
	left join map_to mt on mt.source_code = b.source_code and mt.source_vocabulary_id = b.source_vocabulary_id
	where mt.source_code is null 
	and b.relationship_id = 'Concept replaced by'
)
select r.source_code, r.source_concept_id, r.source_vocabulary_id, r.source_code_description, 
cr.concept_id_2 as target_concept_id, c.vocabulary_id,  c.valid_start_date, c.valid_end_date, c.invalid_reason 
from rep_by r
join {VOCABULARY_SCHEMA}.concept_relationship cr on cr.concept_id_1 = r.concept_id_2
join {VOCABULARY_SCHEMA}.concept c on r.concept_id_2 = c.concept_id
where cr.relationship_id = 'Maps to'
UNION 
select * from map_to;

With base AS(
	select * 
	from {VOCABULARY_SCHEMA}.source_to_standard_vocab_map AS ss
	left join {VOCABULARY_SCHEMA}.concept_relationship cr on cr.concept_id_1 = ss.target_concept_id
	where ss.source_vocabulary_id = %s
	and (ss.target_standard_concept is null or ss.target_invalid_reason is not null)
), map_to AS(
	select b.source_code, b.source_concept_id, b.source_vocabulary_id, b.source_code_description, 
	b.concept_id_2 as target_concept_id, c.vocabulary_id,  c.valid_start_date, c.valid_end_date, c.invalid_reason 
	from base AS b
	join {VOCABULARY_SCHEMA}.concept_relationship cr on cr.concept_id_1 = b.target_concept_id
	join {VOCABULARY_SCHEMA}.concept c on b.concept_id_2 = c.concept_id
	where b.relationship_id = 'Maps to'
), rep_by AS(
	select b.source_code, b.source_concept_id, b.source_vocabulary_id, b.source_code_description, b.concept_id_2
	from base AS b
	left join map_to mt on mt.source_code = b.source_code and mt.source_vocabulary_id = b.source_vocabulary_id
	where mt.source_code is null 
	and b.relationship_id = 'Concept replaced by'
), map_to_rep_by AS(
	select r.source_code, r.source_concept_id, r.source_vocabulary_id, r.source_code_description, 
	cr.concept_id_2 as target_concept_id, c.vocabulary_id,  c.valid_start_date, c.valid_end_date, c.invalid_reason 
	from rep_by r
	join {VOCABULARY_SCHEMA}.concept_relationship cr on cr.concept_id_1 = r.concept_id_2
	join {VOCABULARY_SCHEMA}.concept c on r.concept_id_2 = c.concept_id
	where cr.relationship_id = 'Maps to'
	UNION 
	select * from map_to
)
select distinct sc.*
from base AS b
left join map_to_rep_by mtrb on mtrb.source_code = b.source_code and mtrb.source_vocabulary_id = b.source_vocabulary_id
join {VOCABULARY_SCHEMA}.source_to_concept_map sc on sc.source_code = b.source_code and sc.source_vocabulary_id = b.source_vocabulary_id
where mtrb.source_code is null;