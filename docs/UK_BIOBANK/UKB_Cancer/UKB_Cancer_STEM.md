---
layout: default
title: UKB Cancer STEM
nav_order: 1
parent: UKB CANCER
has_children: true
description: "UKB Cancer to STEM"
---

# CDM Table name: stem_table

The STEM table is a staging area where CPRD source codes like Read codes will first be mapped to concept_ids. The STEM table itself is an amalgamation of the OMOP event tables to facilitate record movement. This means that all fields present across the OMOP event tables are present in the STEM table. After a record is mapped and staged, the domain of the concept_id dictates which OMOP table (Condition_occurrence, Drug_exposure, Procedure_occurrence, Measurement, Observation, Device_exposure) the record will move to. Please see the STEM -> CDM mapping files for a description of which STEM fields move to which STEM tables. 

**Fields in the STEM table**

| Field |
| --- |
| id | 
| domain_id |  
| person_id | 
| visit_occurrence_id | 
| visit_detail_id |
| concept_id | 
| source_value |
| source_concept_id |
| type_concept_id | 
| start_date |  
| end_date |  
| start_time | 
| measurement_event_id | 
| meas_event_field_concept_id | 

The cancer data in ukb_cancer.cancer is stored in a latitudinal format, meaning that all cancer records for a single patient are stored in a single row. This structure makes the ETL process challenging and inefficient. To address this, a transformation is required before performing the ETL, converting the data into a longitudinal format, which stores the cancer records in ukb_cancer.cancer2.

## Reading from ukb_cancer.cancer2 (transform from ukb_cancer.cancer)

![](images/ukb_cancer_to_stem.png)

| Destination Field | Source field | Logic | Comment field | 
| --- | --- | --- | --- |
| id | | | Autogenerate| 
| domain_id | | This should be the domain_id of the standard concept in the concept_id field. If an entity type is mapped to concept_id 0, put the domain_id as Observation. |
| person_id | eid |  |  | 
| visit_occurrence_id | | from visit_detail  |  | 
| visit_detail_id | eid<br>[p40005](https://biobank.ndph.ox.ac.uk/ukb/field.cgi?id=40005)<br>[p40021](https://biobank.ndph.ox.ac.uk/ukb/field.cgi?id=40021) | Look up visit_detail_id based on the unique combination of eid, p40005 and p40021.| |
| concept_id | [p40011](https://biobank.ndph.ox.ac.uk/ukb/field.cgi?id=40011)<br>[p40012](https://biobank.ndph.ox.ac.uk/ukb/field.cgi?id=40012)<br>[p40006](https://biobank.ndph.ox.ac.uk/ukb/field.cgi?id=40006)<br>[p40013](https://biobank.ndph.ox.ac.uk/ukb/field.cgi?id=40013) | source_value will be mapped to either ICDO3 or SNOMED Concept(s) by using ICDO3, ICD10 and ICD9CM and CANCER_ICDO3_STCM |Map source_value by using ICDO3, ICD10 and ICD9CM and CANCER_ICDO3_STCM in the follwoing sequence and conditions.<br><br>1. map the source_value: p40011/p40012-COALESCE(p40006, t1.p40013) by ICDO3.<br><br>2a. If it does not match, map p40011/p40012 by ICDO3.<br>2b. If it does not match, map p40011/p40012 by CANCER_ICDO3_STCM.<br>And step 3:<br>3a. map COALESCE(p40006, p40013) by ICDO3<br>3b. If it does not match, map p40006 by ICD10<br>3c. If it does not match, map p40013 by ICD9CM|
| source_value | [p40011](https://biobank.ndph.ox.ac.uk/ukb/field.cgi?id=40011)<br>[p40012](https://biobank.ndph.ox.ac.uk/ukb/field.cgi?id=40012)<br>[p40006](https://biobank.ndph.ox.ac.uk/ukb/field.cgi?id=40006)<br>[p40013](https://biobank.ndph.ox.ac.uk/ukb/field.cgi?id=40013) | |
| source_concept_id | source_value | Concept_id represents source_value in Athena |
| type_concept_id | | [****32879 - Registry****](https://athena.ohdsi.org/search-terms/terms/32879) |
| start_date | [p40005](https://biobank.ndph.ox.ac.uk/ukb/field.cgi?id=40005) | |
| end_date | [p40005](https://biobank.ndph.ox.ac.uk/ukb/field.cgi?id=40005) | |
| start_time | | 00:00:00 |
| measurement_event_id | cancer2.id<br>source_value |  Link the [Condition Modifiers](https://ohdsi.github.io/OncologyWG/conventions.html#:~:text=Overview%20of%20Condition%20Modifiers&text=What%20we%20are%20calling%20'Condition,using%20the%20Cancer%20Modifier%20vocabulary) by using cancer2.id | | 
| meas_event_field_concept_id | domain_id | domain_id = 'Condition' [1147127](https://athena.ohdsi.org/search-terms/terms/1147127)<br>domain_id = 'Procedure' [1147810](https://athena.ohdsi.org/search-terms/terms/1147810)<br>domain_id = 'Observation' [1147762](https://athena.ohdsi.org/search-terms/terms/1147762) | | 