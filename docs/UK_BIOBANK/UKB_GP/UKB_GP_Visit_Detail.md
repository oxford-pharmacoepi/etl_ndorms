---
layout: default
title: Visit Detail
nav_order: 2
parent: UKB GP
has_children: true
description: "UKB GP to Visit Detail"
---

# CDM Table name: visit_detail

## Reading from ukb_gp.gp_registrations, ukb_gp.gp_clinical, ukb_gp.gp_scripts

![](images/ukb_cancer_to_visit_detail.png)

| Destination Field | Source field | Logic | Comment field | 
| --- | --- | --- | --- |
| visit_detail_id | | | Autogenerate| 
| person_id | eid |  |  | 
| visit_detail_concept_id | [581477 - Office Visit](https://athena.ohdsi.org/search-terms/terms/581477) | | | 
| visit_detail_start_date | reg_date<br>event_dt<br>issue_date | | |
| visit_detail_start_datetime | reg_date<br>event_dt<br>issue_date |  |
| visit_detail_end_date | | Set as visit_detail_start_date | 
| visit_detail_end_datetime | | Set as visit_detail_start_datetime |
| visit_detail_type_concept_id | [32817-EHR](https://athena.ohdsi.org/search-terms/terms/32817) | |
| provider_id | | |
| care_site_id | | |
| visit_detail_source_value | data_provider<br>SOURCE_TABLE_NAME | description of data_provider by joining [lookup626](https://biobank.ndph.ox.ac.uk/ukb/coding.cgi?id=626) - Type of source data: <br>SOURCE_TABLE_NAME = 'gp_registrations' THEN 'Registration'<br>SOURCE_TABLE_NAME = 'gp_clinical' THEN 'Clinical'<br>SOURCE_TABLE_NAME = 'gp_scripts' THEN 'Drug Prescription' | 
| visit_detail_source_concept_id | | 0 | 
| admitted_from_concept_id | | |
| admitted_from_source_value | | | 
| discharged_to_source_value | | | 
| discharged_to_concept_id | | | 
| preceding_visit_detail_id | | Put the visit_detail_id of the last VISIT_DETAIL | 
| parent_visit_detail_id | | |
| visit_occurrence_id | | Put the visit_occurrence_id of the VISIT_OCCURRENCE record that the VISIT_DETAIL record belongs to | 
