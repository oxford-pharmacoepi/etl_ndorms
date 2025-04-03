---
layout: default
title: STEM to Episode
nav_order: 6
parent: NCRASCR
has_children: true
description: "NCRASCR to Episode"
---

# CDM Table name: Episode

## Reading from STEM  

### Disease Episode

All mapped cancer diagnoses are additionally mapped to the CDM Episode, with episode_concept_id set to [32533 (Disease Episode)](https://athena.ohdsi.org/search-terms/terms/32533) and episode_object_concept_id assigned to the corresponding condition_concept_id. 
Furthermore, all related cancer diagnosis modifiers, regardless of their target domain, are linked to the CDM Episode using the same episode_id via episode_event. Please refer to STEM to Episode Event for more details.

![](images/ncrascr_stem_to_episode_32533.png)

| Destination Field | Source field | Logic | Comment field | 
| --- | --- | --- | --- |
| episode_id | | | Autogenerate| 
| person_id | STEM.person_id |  |  | |
| episode_concept_id |  | [32533 Disease Episode](https://athena.ohdsi.org/search-terms/terms/32533) |  |
| episode_type_concept_id |  | [32879 Registry](https://athena.ohdsi.org/search-terms/terms/32879) |  |
| episode_start_date | STEM.start_date |  | |
| episode_start_datetime | STEM.start_date |  | |
| episode_end_date |  | NULL | |
| episode_end_datetime |  | NULL | |
| episode_number |  | NULL | |
| episode_object_concept_id | STEM.concept_id | mapped Condition concepts representing cancer diagnoses | |
| episode_parent_id |  | NULL |  |
| episode_source_value |  | NULL |  |
| episode_source_concept_id |  | NULL |  |


### Treatment Regimen Episode

All mapped cancer treatments are additionally mapped to the CDM Episode, with episode_concept_id set to [32531 (Treatment Regimen Episode)](https://athena.ohdsi.org/search-terms/terms/32531) and episode_object_concept_id assigned to the corresponding procedure_concept_id. 
Treatments not initially mapped to Procedure concepts are remapped to Procedure or Regimen concepts based on the eventcode or eventdesc fields by using NCRAS_TREATMENT_EPISODE_STCM.

Where possible, cancer treatments are associated with diagnoses using the e_cr_id field in the source data. This relationship is represented in the CDM Episode structure via episode_parent_id for Treatment Regimen Episodes.

![](images/ncrascr_stem_to_episode_32531.png)

| Destination Field | Source field | Logic | Comment field | 
| --- | --- | --- | --- |
| episode_id | | | Autogenerate| 
| person_id | STEM.person_id |  |  | |
| episode_concept_id |  | [32531 Treatment Regimen Episode](https://athena.ohdsi.org/search-terms/terms/32531) |  |
| episode_type_concept_id |  | [32879 Registry](https://athena.ohdsi.org/search-terms/terms/32879) |  |
| episode_start_date | STEM.start_date |  | |
| episode_start_datetime | STEM.start_date |  | |
| episode_end_date |  | NULL | |
| episode_end_datetime |  | NULL | |
| episode_number |  | NULL | |
| episode_object_concept_id | STEM.concept_id | mapped Procedure concepts representing treatment. For those not initially mapped to Procedure concepts are remapped to Procedure or Regimen concepts based on the eventcode or eventdesc fields by using NCRAS_TREATMENT_EPISODE_STCM. | |
| episode_parent_id | STEM.id | Look up STEM based on the unique stem_source_id and concept_id = 32533. |  |
| episode_source_value | STEM.source_value |  | eventdesc |
| episode_source_concept_id | STEM.source_value | 0 |  |