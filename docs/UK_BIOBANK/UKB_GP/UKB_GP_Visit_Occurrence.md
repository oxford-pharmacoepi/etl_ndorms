---
layout: default
title: Visit Occurrence
nav_order: 3
parent: UKB GP
has_children: true
description: "UKB GP to Visit Occurrence"
---

# CDM Table name: visit_occurrence

## Reading from visit_detail
Take all records from the VISIT_DETAIL table and create one VISIT_OCCURRENCE record for each PERSON_ID and VISIT_START_DATE combination. This will make it so that a person will have only one visit to their GP per day. After defining visits, go back and assign each VISIT_DETAIL record its associated VISIT_OCCURRENCE_ID.

| Destination Field | Source field | Logic | Comment field | 
| --- | --- | --- | --- |
| visit_occurrence_id | | | Autogenerate| 
| person_id | eid |  |  | 
| visit_concept_id | [581477 - Office Visit](https://athena.ohdsi.org/search-terms/terms/581477) | | | 
| visit_start_date | reg_date<br>event_dt<br>issue_date | | |
| visit_start_datetime | reg_date<br>event_dt<br>issue_date |  |
| visit_end_date | | Set as visit_start_date | 
| visit_end_datetime | | Set as visit_start_datetime |
| visit_type_concept_id | [32817-EHR](https://athena.ohdsi.org/search-terms/terms/32817) | |
| provider_id | | |
| care_site_id | | |
| visit_source_value | data_provider | set as description of data_provider by joining [lookup626](https://biobank.ndph.ox.ac.uk/ukb/coding.cgi?id=626) | 
| visit_source_concept_id | | 0 | 
| admitted_from_concept_id | | |
| admitted_from_source_value | | | 
| discharged_to_source_value | | | 
| discharged_to_concept_id | | | 
| preceding_visit_occurrence_id | | Put the visit_occurrence_id of the last VISIT_OCCURRENCE | 
