---
layout: default
title: Visit Detail
nav_order: 3
parent: UKB HESIN
description: "visit_detail mapping from hesin_critical & hesin_psych tables"

---

# CDM Table name: visit_detail (CDM v5.4)

## Reading from source_ukb_hesin.hesin


![](../images/image12.png)


| Destination Field | Source field | Logic | Comment field |
| --- | --- | :---: | --- |
| visit_detail_id| | NEXTVAL('public.sequence_vd')| Autogenerate|
| person_id| eid | | |
| visit_detail_concept_id| | 9201 = Inpatient visit| |
| visit_detail_start_date | epistart,<br>admidate,<br>disdate | COALESCE(epistart, admidate, disdate)|    |
| visit_detail_start_datetime| epistart,<br>admidate,<br>disdate | COALESCE(epistart, admidate, disdate)|  |
| visit_detail_end_date | epiend,<br>epistart,<br>disdate| COALESCE(epiend, epistart, disdate)|  |
| visit_detail_end_datetime | epiend,<br>epistart,<br>disdate| COALESCE(epiend, epistart, disdate) | |
| visit_detail_type_concept_id| | 32818 = EHR administration record| |
| provider_id| NULL | | |
| care_site_id| NULL | | |
| visit_detail_source_value| ins_index | | |
| visit_detail_source_concept_id| NULL | | |
| admitted_from_concept_id | admisorc_uni | use admisorc_uni to retrieve the target_concept_id from source_to_standard_vocab_map by doing a INNER JOIN to source_to_standard_vocab_map as t1 on CONCAT('264-',hesin.admisorc_uni) = t1.source_code AND t1.target_domain_id = 'visit' AND t1.source_vocabulary_id = “UKB_ADMISORC_STCM”. |  |
| admitted_from_source_value | admisorc_uni | use admisorc_uni to retrieve the source_code_description from source_to_standard_vocab_map by doing a INNER JOIN to source_to_standard_vocab_map as t1 on CONCAT('264-',hesin.admisorc_uni) = t1.source_code AND t1.target_domain_id = 'visit' AND t1.source_vocabulary_id = “UKB_ADMISORC_STCM”.|  |
| discharged_to_concept_id | disdest_uni| use disdest_uni to retrieve the target_concept_id from source_to_standard_vocab_map by doing a INNER JOIN to source_to_standard_vocab_map as t1 on CONCAT('267-',hesin.disdest_uni) = t1.source_code AND t1.target_domain_id = 'visit' AND t1.source_vocabulary_id = “UKB_DISDEST_STCM”.|  |
| discharged_to_source_value | disdest_uni | use disdest_uni to retrieve the source_code_description from source_to_standard_vocab_map by doing a INNER JOIN to source_to_standard_vocab_map as t1 on CONCAT('267-',hesin.disdest_uni) = t1.source_code AND t1.target_domain_id = 'visit' AND t1.source_vocabulary_id = “UKB_DISDEST_STCM”.|  |
| preceding_visit_detail_id| NULL | | check for preceding_visit_detail_id by checking the max(visit_detail_id) for this patient using eid+ins_index |
| parent_visit_detail_id| NULL | | |
| visit_occurrence_id| ins_index,eid | |Use ins_index, eid to retrieve visit_occurrence_id from visit_occurrence |

## Reading from source_ukb_hesin.hesin_psych, source_ukb_hesin.hesin

![](../images/image5.png)

| Destination Field | Source field | Logic | Comment field |
| --- | --- | :---: | --- |
| visit_detail_id| | NEXTVAL('public.sequence_vd')| Autogenerate|
| person_id| eid | | |
| visit_detail_concept_id| | 9201 = Inpatient visit | |
| visit_detail_start_date | hesin.epistart,<br>hesin.admidate,<br>detndate,<br>hesin.disdate | COALESCE(hesin.epistart, hesin.admidate, detndate, hesin.disdate)|    |
| visit_detail_start_datetime| hesin.epistart,<br>hesin.admidate,<br>detndate,<br>hesin.disdate | COALESCE(hesin.epistart, hesin.admidate, detndate, hesin.disdate)|  |
| visit_detail_end_date | hesin.epiend,<br>hesin.epistart,<br>hesin.disdate,<br>detndate| COALESCE(hesin.epiend, hesin.epistart, detndate, disdate)|  |
| visit_detail_end_datetime | hesin.epiend,<br>hesin.epistart,<br>hesin.disdate,<br>detndate| COALESCE(hesin.epiend, hesin.epistart, detndate, hesin.disdate) | |
| visit_detail_type_concept_id| | 32818 = EHR administration record | |
| provider_id| NULL | | |
| care_site_id| NULL | | |
| visit_detail_source_value| ins_index  | | |
| visit_detail_source_concept_id| NULL | | |
| admitted_from_concept_id | hesin.admisorc_uni | use admisorc_uni from HESIN to retrieve the target_concept_id from source_to_standard_vocab_map by doing a INNER JOIN to source_to_standard_vocab_map as t1 on CONCAT('264-',hesin.admisorc_uni) = t1.source_code AND t1.target_domain_id = 'visit' AND t1.source_vocabulary_id = “UKB_ADMISORC_STCM”. |  |
| admitted_from_source_value | hesin.admisorc_uni | use admisorc_uni from HESIN to retrieve the source_code_description from source_to_standard_vocab_map by doing a INNER JOIN to source_to_standard_vocab_map as t1 on CONCAT('264-',hesin.admisorc_uni) = t1.source_code AND t1.target_domain_id = 'visit' AND t1.source_vocabulary_id = “UKB_ADMISORC_STCM”.|  |
| discharged_to_concept_id | hesin.disdest_uni| use disdest_uni from HESIN to retrieve the target_concept_id from source_to_standard_vocab_map by doing a INNER JOIN to source_to_standard_vocab_map as t1 on CONCAT('267-',hesin.disdest_uni) = t1.source_code AND t1.target_domain_id = 'visit' AND t1.source_vocabulary_id = “UKB_DISDEST_STCM”.|  |
| discharged_to_source_value | hesin.disdest_uni | use disdest_uni from HESIN  to retrieve the source_code_description from source_to_standard_vocab_map by doing a INNER JOIN to source_to_standard_vocab_map as t1 on CONCAT('267-',hesin.disdest_uni) = t1.source_code AND t1.target_domain_id = 'visit' AND t1.source_vocabulary_id = “UKB_DISDEST_STCM”.|  |
| preceding_visit_detail_id| | | check for preceding_visit_detail_id by checking the max(visit_detail_id) for this patient using eid+ins_index|
| parent_visit_detail_id| NULL | | |
| visit_occurrence_id| ins_index,<br>eid | |Use ins_index, eid to retrieve visit_occurrence_id from visit_occurrence |

## Reading from source_ukb_hesin.hesin_critical, source_ukb_hesin.hesin


![](../images/image4.png)


| Destination Field | Source field | Logic | Comment field |
| --- | --- | :---: | --- |
| visit_detail_id| | NEXTVAL('public.sequence_vd')| Autogenerate|
| person_id| eid | | |
| visit_detail_concept_id| | 9201 = Inpatient visit| |
| visit_detail_start_date | hesin.epistart,<br>hesin.admidate,<br>ccstartdate,<br>hesin.disdate | COALESCE(hesin.epistart, hesin.admidate, ccstartdate, hesin.disdate)|    |
| visit_detail_start_datetime| hesin.epistart,<br>hesin.admidate,<br>ccstartdate,<br>hesin.disdate | COALESCE(hesin.epistart, hesin.admidate, ccstartdate, hesin.disdate)|  |
| visit_detail_end_date | hesin.epiend,<br>hesin.epistart,<br>ccdisdate,<br>hesin.disdate| COALESCE(hesin.epiend, hesin.epistart, ccdisdate, hesin.disdate)|  |
| visit_detail_end_datetime | hesin.epiend,<br>hesin.epistart,<br>ccdisdate,<br>hesin.disdate| COALESCE(hesin.epiend, hesin.epistart, ccdisdate, hesin.disdate) | |
| visit_detail_type_concept_id| | 32818 = EHR administration record| |
| provider_id| NULL | | |
| care_site_id| NULL | | |
| visit_detail_source_value| ins_index | | |
| visit_detail_source_concept_id| NULL | | |
| admitted_from_concept_id | hesin.admisorc_uni | use admisorc_uni from HESIN to retrieve the target_concept_id from source_to_standard_vocab_map by doing a INNER JOIN to source_to_standard_vocab_map as t1 on CONCAT('264-',hesin.admisorc_uni) = t1.source_code AND t1.target_domain_id = 'visit' AND t1.source_vocabulary_id = “UKB_ADMISORC_STCM”. |  |
| admitted_from_source_value | hesin.admisorc_uni | use admisorc_uni from HESIN to retrieve the source_code_description from source_to_standard_vocab_map by doing a INNER JOIN to source_to_standard_vocab_map as t1 on CONCAT('264-',hesin.admisorc_uni) = t1.source_code AND t1.target_domain_id = 'visit' AND t1.source_vocabulary_id = “UKB_ADMISORC_STCM”.|  |
| discharged_to_concept_id | hesin.disdest_uni| use disdest_uni from HESIN to retrieve the target_concept_id from source_to_standard_vocab_map by doing a INNER JOIN to source_to_standard_vocab_map as t1 on CONCAT('267-',hesin.disdest_uni) = t1.source_code AND t1.target_domain_id = 'visit' AND t1.source_vocabulary_id = “UKB_DISDEST_STCM”.|  |
| discharged_to_source_value | hesin.disdest_uni | use disdest_uni from HESIN  to retrieve the source_code_description from source_to_standard_vocab_map by doing a INNER JOIN to source_to_standard_vocab_map as t1 on CONCAT('267-',hesin.disdest_uni) = t1.source_code AND t1.target_domain_id = 'visit' AND t1.source_vocabulary_id = “UKB_DISDEST_STCM”.|  |
| preceding_visit_detail_id| NULL | | check for preceding_visit_detail_id by checking the max(visit_detail_id) for this patient using eid+ins_index|
| parent_visit_detail_id| NULL | | |
| visit_occurrence_id| ins_index,<br>eid | |Use ins_index, eid to retrieve visit_occurrence_id from visit_occurrence |

