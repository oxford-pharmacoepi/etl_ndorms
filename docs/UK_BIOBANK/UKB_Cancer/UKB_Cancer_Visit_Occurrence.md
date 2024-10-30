---
layout: default
title: Visit Occurrence
nav_order: 3
parent: UKB CANCER
has_children: true
description: "UKB Cancer to Visit Occurrence"
---

# CDM Table name: visit_occurrence

## Reading from visit_detail
Take all records from the VISIT_DETAIL table and create one VISIT_OCCURRENCE record for each PERSON_ID and VISIT_START_DATE combination. This will make it so that a person will have only one visit to their GP per day. After defining visits, go back and assign each VISIT_DETAIL record its associated VISIT_OCCURRENCE_ID.

| Destination Field | Source field | Logic | Comment field | 
| --- | --- | --- | --- |
| visit_occurrence_id | | | Autogenerate| 
| person_id | eid |  |  | 
| visit_concept_id | [38004268 - Ambulatory Health Care Facilities, Clinic / Center, Oncology](https://athena.ohdsi.org/search-terms/terms/38004268) | min(p40005) |  | 
| visit_start_date | p40005 | | |
| visit_start_datetime | p40005 |  |
| visit_end_date | | Set as visit_start_date | 
| visit_end_datetime | | Set as visit_start_datetime |
| visit_type_concept_id | [32879-Registry](https://athena.ohdsi.org/search-terms/terms/32879) | |
| provider_id | | |
| care_site_id | | |
| visit_source_value | [p40021](https://biobank.ndph.ox.ac.uk/ukb/search.cgi?wot=0&srch=40021&yfirst=2000&ylast=2024) | set as description of p40021 by joining [lookup1970](https://biobank.ndph.ox.ac.uk/ukb/coding.cgi?id=1970) | 
| visit_source_concept_id | | 0 | 
| admitted_from_concept_id | | |
| admitted_from_source_value | | | 
| discharged_to_source_value | | | 
| discharged_to_concept_id | | | 
| preceding_visit_occurrence_id | | Put the visit_occurrence_id of the last VISIT_OCCURRENCE | 
