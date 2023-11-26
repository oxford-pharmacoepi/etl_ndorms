---
layout: default
title: HESAPC to STEM
nav_order: 8
parent: HES APC
has_children: true
description: "Stem table description"
---

# CDM Table name: stem_table (CDM v5.3 / v5.4)

The stem_table is a staging area where HESAPC source codes like Read codes will first be mapped to concept_ids.

**Reading from hes_diagnosis_epi**

![](images/image7.png)

**Figure.1**

| Destination Field | Source field | Logic | Comment field |
| --- | 
| id|||Removed for performance reasons|
| domain_id |  | | |
| person_id | patid| | |
| visit_occurrence_id | | | Use spno to retrieve visit_occurrence_id |
| visit_detail_id|||Use patid+epikey to retrieve visit_detail_id |
| provider_id | | | |
| start_datetime | epistart | | |
| concept_id | icd | | If there is no mapping then set to 0 and set domain_id as ‘Observation’.otherwise left join Source_to_Source_vocab_map AS s ON d.ICD=s.SOURCE_CODE AND s.SOURCE_VOCABULARY_ID='ICD10' AND target_standard_concept = 'S' AND target_invalid_reason is NULL.|
| source_value| icd |||
| source_concept_id | icd | concept_id of icd | |
| type_concept_id |  | |32829 |
| operator_concept_id | | | |
| unit_concept_id |  | | |
| unit_source_value | | | |
| start_date | epistart | | |
| end_date | epiend | | |
| range_high |  | | |
| range_low | | | |
| value_as_number | | | |
| value_as_string | | | |
| value_as_concept_id | | | |
| value_source_value | | | |
| end_datetime | epiend| | |
| verbatim_end_date | | | | 
| days_supply | | | |
| dose_unit_source_value | | | |
| lot_number | | | |
| modifier_concept_id |  | | |
| modifier_source_value | | | |
| quantity | | | |
| refills | | | |
| route_concept_id | | | |
| route_source_value | | | |
| sig |  | | |
| stop_reason | | | |
| unique_device_id | | | |
| anatomic_site_concept_id | | | |
| disease_status_concept_id |  | | |
| specimen_source_id || | |
| anatomic_site_source_value | | | |
| disease_status_source_value | | | |
| condition_status_concept_id | d_order | | 32902 if d_order = 1,32908 if d_order > 1|
| condition_status_source_value | d_order | | | 

**Reading from hes_procedures_epi**

![](images/image8.png)

**Figure.2**

| Destination Field | Source field | Logic | Comment field |
| --- | 
| id|||Removed for performance reasons|
| domain_id |  | | |
| person_id | patid| | |
| visit_occurrence_id | | | Use spno to retrieve visit_occurrence_id |
| visit_detail_id|||Use patid+epikey to retrieve visit_detail_id |
| provider_id | | | |
| start_datetime | evdate, epistart | | |
| concept_id | opcs | | The codes in the opcs field are four digits with no decimal. To map these. add a decimal between the third and fourth digit.  LFFT JOIN Source_to_Source_vocab_map AS ss  ON psts.opcs4 = ss.source_code AND ss.source_vocabulary_id = 'OPCS4'  AND target_standard_concept = 'S' AND target_invalid_reason is NULL If domain_id is zero set to 'Observation' |
| source_value|opcs|||
| source_concept_id | opcs | concept_id of opcs | |
| type_concept_id |  | |32829 |
| operator_concept_id | | | |
| unit_concept_id |  | | |
| unit_source_value | | | |
| start_date | evdate | | |
| end_date | evend | | |
| range_high |  | | |
| range_low | | | |
| value_as_number | | | |
| value_as_string | | | |
| value_as_concept_id | | | |
| value_source_value | | | |
| end_datetime | | | |
| verbatim_end_date | | | | 
| days_supply | | | |
| dose_unit_source_value | | | |
| lot_number | | | |
| modifier_concept_id |  | | |
| modifier_source_value | p_order| | |
| quantity | | | |
| refills | | | |
| route_concept_id | | | |
| route_source_value | | | |
| sig |  | | |
| stop_reason | | | |
| unique_device_id | | | |
| anatomic_site_concept_id | | | |
| disease_status_concept_id |  | | |
| specimen_source_id || | |
| anatomic_site_source_value | | | |
| disease_status_source_value | | | |
| condition_status_concept_id | | | |
| condition_status_source_value |  | | |

