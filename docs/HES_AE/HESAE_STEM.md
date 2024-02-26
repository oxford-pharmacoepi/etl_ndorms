---
layout: default
title: HES AE to STEM
nav_order: 8
parent: HES A&E
has_children: true
description: "Stem table description"
---

# CDM Table name: stem_table (CDM v5.3 / v5.4)

The stem_table is a staging area where HES A&E source codes like Read codes will first be mapped to concept_ids.

**Reading from hes_diagnosis_epi**

![](images/image12.png)
**Figure.1**

| Destination Field | Source field | Logic | Comment field |
| --- | 
| id|||Removed for performance reasons|
| domain_id | NULL | | |
| person_id | patid| | |
| visit_occurrence_id |aekey,patid| | Use patid and aekey to retrieve visit_occurrence_id |
| visit_detail_id|aekey,patid||Use patid+aekey to retrieve visit_detail_id |
| provider_id | NULL| | |
| start_datetime | NULL | | |
| concept_id | diag | | If there is no mapping then set to 0 and set domain_id as ‘Observation’.otherwise left join Source_to_Source_vocab_map AS s ON s.SOURCE_CODE = (SELECT CASE WHEN LENGTH(t2.diag) = 4 AND RIGHT(t2.diag, 1) IN ('X', '.')THEN LEFT(t2.diag, 3) WHEN LENGTH(t2.diag) = 4 THEN CONCAT(LEFT(t2.diag, 3), '.', RIGHT(t2.diag, 1))ELSE t2.diag END AS source_value FROM {SOURCE_SCHEMA}.hesae_diagnosis) AND s.SOURCE_VOCABULARY_ID=’ICD10’  ALSO left join Source_to_Source_vocab_map AS s ON s.SOURCE_CODE = ( SELECT t2.cleansedreadcode as source_value, FROM {SOURCE_SCHEMA}.hesae_diagnosis AS t1 INNER JOIN source.medicaldictionary AS t2 ON LEFT(t2.cleansedreadcode, 5) = LEFT(t1.diag, 5)) AND s.SOURCE_VOCABULARY_ID=’READ’|
| source_value| diag ||SELECT CASE WHEN LENGTH(t2.diag) = 4 AND RIGHT(t2.diag, 1) IN ('X', '.')THEN LEFT(t2.diag, 3)WHEN LENGTH(t2.diag) = 4 THEN CONCAT(LEFT(t2.diag, 3), '.', RIGHT(t2.diag, 1))ELSE t2.diag END AS source_value FROM {SOURCE_SCHEMA}.hesae_diagnosis|
| source_concept_id | diag | concept_id of diag | |
| type_concept_id |  | |32829 |
| operator_concept_id |NULL | | |
| unit_concept_id |NULL  | | |
| unit_source_value |NULL | | |
| start_date | patid, aekey | | Use patid and aekey to retrieve hesae_attendance.arrivaldate.
| end_date | NULL | | |
| range_high | NULL | | |
| range_low |NULL | | |
| value_as_number | NULL| | |
| value_as_string |NULL | | |
| value_as_concept_id |NULL | | |
| value_source_value |NULL | | |
| end_datetime | NULL| | |
| verbatim_end_date | NULL| | | 
| days_supply |NULL | | |
| dose_unit_source_value |NULL | | |
| lot_number | NULL| | |
| modifier_concept_id |NULL  | | |
| modifier_source_value |NULL | | |
| quantity | NULL| | |
| refills |NULL | | |
| route_concept_id |NULL | | |
| route_source_value | NULL| | |
| sig | NULL | | |
| stop_reason |NULL | | |
| unique_device_id |NULL | | |
| anatomic_site_concept_id |NULL | | |
| disease_status_concept_id |NULL  | | |
| specimen_source_id |NULL| | |
| anatomic_site_source_value |NULL | | |
| disease_status_source_value | NULL| | |
| condition_status_concept_id | diag_order | | 32902 if diag_order = 1,32908 if diag_order > 1|
| condition_status_source_value | diag_order | | |