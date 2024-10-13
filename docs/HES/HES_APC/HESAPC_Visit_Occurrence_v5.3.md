---
layout: default
title: CDM v5.3
nav_order: 1
parent: Visit_Occurrence
grand_parent: HES_APC
description: "Visit_occurrence v5.3 description"
---

# CDM Table name: Visit_Occurrence (CDM v5.3)

## Reading from hes_hospital to Visit_Occurrence CDM v5.3 table:
![](../images/image6.png)

**Figure.1**

| Destination Field | Source field | Logic | Comment field |
| --- | --- | :---: | --- |
| visit_occurrence_id |  |  nextval('public.sequence_vo') AS visit_occurrence_id | Autogenerate| 
| person_id | patid |  |  |
| visit_concept_id |  | 9201 = Inpatient visit  | |
| visit_start_date | admidate | COALESCE(admidate, MIN(epistart), discharged)|    |
| visit_start_datetime | admidate | COALESCE(admidate, MIN(epistart), discharged)|  |
| visit_end_date | discharged | COALESCE(discharged, MAX(epiend), admidate, MIN(epistart))|  |
| visit_end_datetime | discharged | COALESCE(discharged, MAX(epiend), admidate, MIN(epistart)) | |
| visit_type_concept_id |  | 32818 = EHR administration record |  |
| provider_id |NULL | |  |
| care_site_id | NULL| |  |
| visit_source_value | spno |  | This will allow us to retrieve Visit_occurrence_id. |
| visit_source_concept_id |NULL  |  |  |
| admitting_source_concept_id | admimeth | use admimeth to retrieve the target_concept_id from source_to_standard_vocab_map by doing a LEFT JOIN to source_to_standard_vocab_map as t1 on hes_hospital.admimeth = t1.source_code AND t1.source_vocabulary_id = “HESAPC_ADMIMETH_STCM”. |  |
| admitting_source_value | admimeth | use admimeth to retrieve the source_code_description from source_to_standard_vocab_map by doing a LEFT JOIN to source_to_standard_vocab_map as t1 on hes_hospital.admimeth = t1.source_code AND t1.source_vocabulary_id = “HESAPC_ADMIMETH_STCM”.|  |
| discharge_to_concept_id | dismeth | use adismeth to retrieve the target_concept_id from source_to_standard_vocab_map by doing a LEFT JOIN to source_to_standard_vocab_map as t1 on hes_hospital.dismeth = t1.source_code AND t1.source_vocabulary_id = “HESAPC_DISMETH_STCM”. |  |
| discharge_to_source_value | dismeth | use dismeth to retrieve the source_code_description from source_to_standard_vocab_map by doing a LEFT JOIN to source_to_standard_vocab_map as t1 on hes_hospital.dismeth = t1.source_code AND t1.source_vocabulary_id = “HESAPC_DISMETH_STCM”. |  |
| preceding_visit_occurrence_id |  |Using person_id, look up the hospitalisation that occurs prior to this and put the visit_occurrence_id here. |  |
