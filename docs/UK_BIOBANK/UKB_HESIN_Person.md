---
layout: default
title: Person
nav_order: 1
parent: UKB HESIN
description: "Person mapping from HES AE hesae_patient table"

---

# CDM Table name: PERSON (CDM v5.4)

## Reading from hesin

![](images/image2.png)

**Figure.1**

| Destination Field | Source field | Logic | Comment field |
| --- | --- | :---: | --- |
| person_id | eid |  |  Data like gender, year_of_birth, month_of_birth, race_source_value comes from ukb baseline as the data are linked.|
| gender_concept_id | 0 | | |
| year_of_birth | baseline.p34 | | |
| month_of_birth |baseline.p52 |  | |
| day_of_birth |NULL  |  |  |
| birth_datetime |NULL  |  |  |
| race_concept_id |  | | |
| ethnicity_concept_id | 0 |  |   |
| location_id |NULL  |  |  |
| provider_id |NULL  |  |  |
| care_site_id |NULL | |  |
| person_source_value | eid |  |  |
| gender_source_value |baseline.p31  | CONCAT('9-', baseline.p31)  | |
| gender_source_concept_id | baseline.p31 |  gender_source_concept_id will be mapped to a standard Concept_id by using baseline.p31 to retrieve the target_concept_id from source_to_standard_vocab_map where source_code = CONCAT(‘9-‘, baseline.p31) AND vocabulary_id = 'UK Biobank'|  |
| race_source_value | baseline.p21000_i0| CONCAT('1001-', baseline.p21000_i0)| |
| race_source_concept_id | baseline.p21000_i0 |race_source_concept_id will be mapped to a standard Concept_id by using baseline.p21000_i0 to retrieve the target_concept_id from source_to_standard_vocab_map where source_code = CONCAT('1001-', baseline.p21000_i0::integer) AND vocabulary_id = 'UK Biobank'|
| ethnicity_source_value | NULL |  |  | 
