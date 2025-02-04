---
layout: default
title: Visit Detail
nav_order: 3
parent: UKB HESIN
description: "visit_detail mapping from hesin_critical & hesin_psych tables"

---

# CDM Table name: visit_detail (CDM v5.4)

## Reading from hesin


![](images/ukb_hesin_to_vd.png)


| Destination Field | Source field | Logic | Comment field |
| --- | --- | :---: | --- |
| visit_detail_id| | | Autogenerate|
| person_id| eid | | |
| visit_detail_concept_id| | [9201- Standard algorithm](https://athena.ohdsi.org/search-terms/terms/9201)| | |
| visit_detail_start_date | epistart,<br>admidate | Use the first not null of epistart and admidate. |    |
| visit_detail_start_datetime| epistart,<br>admidate | |  |
| visit_detail_end_date | epiend,<br>disdate,<br>epistart,<br>admidate| use the first not null of (epiend,disdate,epstart,admidate)|  |
| visit_detail_end_datetime | epiend,<br>disdate,<br>epistart,<br>admidate| | |
| visit_detail_type_concept_id| | [32818- Standard algorithm](https://athena.ohdsi.org/search-terms/terms/32818)| |
| provider_id |tretspef,<br>mainspef | use the first available of (tretspef,mainspef) to retrieve the provider_id from the provider table.|  |
| care_site_id| NULL | | |
| visit_detail_source_value| ins_index | | |
| visit_detail_source_concept_id| NULL | | |
| admitted_from_concept_id | admisorc_uni | admisorc_uni will be mapped to Athena Standard Concept by using UKB_ADMISORC_STCM. |  |
| admitted_from_source_value | admisorc_uni | |  |
| discharged_to_concept_id | disdest_uni| disdest_uni will be mapped to Athena Standard Concept by using UKB_DISDEST_STCM.|  |
| discharged_to_source_value | disdest_uni | use disdest_uni to retrieve the source_code_description from source_to_standard_vocab_map by doing a INNER JOIN to source_to_standard_vocab_map as t1 on CONCAT('267-',hesin.disdest_uni) = t1.source_code AND t1.target_domain_id = 'visit' AND t1.source_vocabulary_id = “UKB_DISDEST_STCM”.|  |
| preceding_visit_detail_id| NULL | |  |
| parent_visit_detail_id| NULL | | |
| visit_occurrence_id| eid, ins_index | Use eid, ins_index||


