---
layout: default
title: CDM v5.4
nav_order: 2
parent: Visit_Detail
grand_parent: HES APC
description: "Visit_detail v5.4 description"
---

# CDM Table name: Visit_detail (CDM v5.4)

## Reading from hes_episodes to Visit_Detail CDM v5.4 table:
![](images/image9.png)

**Figure.1**

| Destination Field | Source field | Logic | Comment field |
| --- | --- | :---: | --- |
| visit_detail_id |  |  nextval('public.sequence_vd') AS visit_detail_id | A sequence named "sequence_vd" is created in the public schema to uniquely generate "visit_detail_id"s. It initializes by fetching the highest ID from the {TARGET_SCHEMA_TO_LINK}._max_ids table where "tbl_name" equals "visit_detail". This table, located in the schema to be linked to the target schema, stores the maximum IDs for all CDM tables to help set the starting point for the next ID in a given sequence.|
| person_id | patid |  |  |
| visit_detail_concept_id |  | 9201 = Inpatient visit |  |
| visit_detail_start_date | epistart | COALESCE(epistart, admidate, epiend)| If epistart is not null then epistart else use admidate if not null else use epiend  |
| visit_detail_start_datetime | epistart | COALESCE(epistart, admidate, epiend)| If epistart is not null then epistart else use admidate if not null else use epiend |
| visit_detail_end_date | epiend | COALESCE(epiend, discharged, epistart)| If epiend is not null then use epiend else use discharged if not null else use epistart  |
| visit_detail_end_datetime | epiend | COALESCE(epiend, discharged, epistart) | If epiend is not null then use epiend else use discharged if not null else use epistart  |
| visit_detail_type_concept_id |  | 32818 = "EHR administration record” |  |
| provider_id | pconsult | use hes_episode.pconsult inorder to retrieve the provider_id from provider by LEFT JOINING provider as t1 on  t1.provider_source_value = hes_episode.pconsult. | |
| care_site_id |NULL |  |  |
| visit_detail_source_value | epikey | | This will allow us to retrieve visit_detail_id using patid. |
| visit_detail_source_concept_id |NULL  |  |  |
| admitting_from_source_concept_id | admimeth | use admimeth to retrieve the target_concept_id from source_to_standard_vocab_map by doing a LEFT JOIN to source_to_standard_vocab_map as t1 on hes_hospital.admimeth = t1.source_code AND t1.source_vocabulary_id = “HESAPC_ADMIMETH_STCM”. | Check for OMOP codes from admimeth |
| admitting_from_source_value | admimeth | use admimeth to retrieve the source_code_description from source_to_standard_vocab_map by doing a LEFT JOIN to source_to_standard_vocab_map as t1 on hes_hospital.admimeth = t1.source_code AND t1.source_vocabulary_id = “HESAPC_ADMIMETH_STCM”.| Definition to be added instead of number |
| discharge_to_concept_id | dismeth | use dismeth to retrieve the target_concept_id from source_to_standard_vocab_map by doing a LEFT JOIN to source_to_standard_vocab_map as t1 on hes_hospital.dismeth = t1.source_code AND t1.source_vocabulary_id = “HESAPC_DISMETH_STCM”. | Check for OMOP codes from dismeth |
| discharge_to_source_value | dismeth | use dismeth to retrieve the source_code_description from source_to_standard_vocab_map by doing a LEFT JOIN to source_to_standard_vocab_map as t1 on hes_hospital.dismeth = t1.source_code AND t1.source_vocabulary_id = “HESAPC_DISMETH_STCM”. | Definition to be added instead of number |
| preceding_visit_detail_id | eorder | If eorder = 1 then 0 else check for preceding_visit_detail_id by using eorder for this patient using patid+epikey+spno. |  |
| visit_detail_parent_id | NULL |  |  |
| visit_occurrence_id |  |  | Use spno to retrieve visit_occurrence_id from visit_occurrence.visit_source_value |

## Reading from hes_acp to Visit_Detail CDM v5.4 table:
![](images/image11.png)

**Figure.2**

| Destination Field | Source field | Logic | Comment field |
| --- | --- | :---: | --- |
| visit_detail_id |  |  nextval('public.sequence_vd') AS visit_detail_id | A sequence named “sequence_vd” is created in the public schema to uniquely generate “visit_detail_id”s. It initializes by fetching the highest ID from the {TARGET_SCHEMA_TO_LINK}._max_ids table where “tbl_name” equals “visit_detail”. This table, located in the schema to be linked to the target schema, stores the maximum IDs for all CDM tables to help set the starting point for the next ID in a given sequence.|
| person_id | patid |  |  |
| visit_detail_concept_id |  | 32037 = Intensive care |  |
| visit_detail_start_date | acpstar,epistart | COALESCE(acpstar,epistart) | If acpstar in not null then acpstar else epistart |
| visit_detail_start_datetime | acpstar, epistart | COALESCE(acpstar,epistart) | If acpstar in not null then acpstar else epistart  |
| visit_detail_end_date | acpend, epiend | COALESCE(acpend, epiend) | If acpend is null then acpend else epiend |
| visit_detail_end_datetime | acpend, epiend | COALESCE(acpend,epiend) | If acpend is not null then acpend else epiend  |
| visit_detail_type_concept_id |  | 32818 = "EHR administration record” |  |
| provider_id | hes_episodes.pconsult |  | Use patid+epikey to get it (only if efficient and provider populated) |
| care_site_id |NULL |  |  |
| visit_detail_source_value | epikey | | This will allow to retrieve visit_details_id using patid If acpn = 1 then 0 else use acpn with patid+epikey and visit_detail_source_value = “Augmented care period (ACP)” to find the preceding_visit_detail_id  |
| visit_detail_source_concept_id | NULL |  |  |
| admitting_from_source_concept_id | acpsour | use acpsour to retrieve the target_concept_id from source_to_concept_map by doing a LEFT JOIN to source_to_concept_map as t1 on t1.source_code = hes_apc.acpsour AND t1.source_vocabulary_id = “HESAPC_ACPSOUR_STCM”. | Definition to be added instead of number |
| admitting_from_source_value | acpsour | use acpsour to retrieve the source_code_description from source_to_concept_map by doing a LEFT JOIN to source_to_concept_map as t1 on t1.source_code = hes_apc.acpsour AND t1.source_vocabulary_id = “HESAPC_ACPSOUR_STCM”. | Check for OMOP codes from acpsour |
| discharge_to_concept_id | acpdisp | use acpdisp to retrieve the target_concept_id from source_to_concept_map by doing a LEFT JOIN to source_to_concept_map as t1 on t1.source_code = hes_apc.acpdisp AND t1.source_vocabulary_id = “HESAPC_ACPDISP_STCM”. | Definition to be added instead of number |
| discharge_to_source_value | acpdisp | use acpdisp to retrieve the source_code_description from source_to_concept_map by doing a LEFT JOIN to source_to_concept_map as t1 on t1.source_code = hes_apc.acpdisp AND t1.source_vocabulary_id = “HESAPC_ACPDISP_STCM”. | Check for OMOP codes from acpdisp |
| preceding_visit_detail_id | | If acpn = 1 then 0 else use acpn with patid+epikey and visit_detail_source_value = “Augmented care period (ACP)” to find the preceding_visit_detail_id |  |
| visit_detail_parent_id |  |  | Use patid + epikey where visit_detail_source_value= “Visit episode” to get the visit_detail_parent_id  |
| visit_occurrence_id |  |  | Use spno to retrieve visit_occurrence_id from visit_occurrence.visit_source_value   |



## Reading from hes_ccare to Visit_Detail CDM v5.4 table:
![](images/image10.png)

**Figure.3**

| Destination Field | Source field | Logic | Comment field |
| --- | --- | :---: | --- |
| visit_detail_id |  |  nextval('public.sequence_vd') AS visit_detail_id | A sequence named “sequence_vd” is created in the public schema to uniquely generate “visit_detail_id”s. It initializes by fetching the highest ID from the {TARGET_SCHEMA_TO_LINK}._max_ids table where “tbl_name” equals “visit_detail”. This table, located in the schema to be linked to the target schema, stores the maximum IDs for all CDM tables to help set the starting point for the next ID in a given sequence.|
| person_id | patid |  |  |
| visit_detail_concept_id |  | 32037 = Intensive care |  |
| visit_detail_start_date | ccstartdate | | |
| visit_detail_start_datetime | ccstartdate | use ccstartdate if ccstarttime is null else ccstartdate::timestamp + ccstarttime::time as visit_detail_start_datetime. | |
| visit_detail_end_date | ccdisdate | | |
| visit_detail_end_datetime | ccdisdate | use ccdisdate if ccdistime is null else ccdisdate::timestamp + ccdistime::time as visit_detail_end_datetime.  |  |
| visit_detail_type_concept_id |  | 32818 = "EHR administration record” |  |
| provider_id | hes_episodes.pconsult |  | Use patid+epikey to get it (only if efficient and provider populated) |
| care_site_id | NULL|  |  |
| visit_detail_source_value | epikey | | This will allow to retrieve visit_details_id set to 0 at the end |
| visit_detail_source_concept_id | NULL |  |  |
| admitting_from_source_concept_id | ccadmisorc | use ccadmisorc to retrieve the target_concept_id from source_to_concept_map by doing a LEFT JOIN to source_to_concept_map as t1 on t1.source_code = hes_ccare.ccadmisorc AND t1.source_vocabulary_id = “HESAPC_ADMISORC_STCM”. | Definition to be added instead of number |
| admitting_from_source_value | ccadmisorc | use ccadmisorc to retrieve the source_code_description from source_to_concept_map by doing a LEFT JOIN to source_to_concept_map as t1 on t1.source_code = hes_ccare.ccadmisorc AND t1.source_vocabulary_id = “HESAPC_ADMISORC_STCM”. | Check for OMOP codes from ccadmisorc |
| discharge_to_concept_id | ccdisdest | use ccdisdest to retrieve the target_concept_id from source_to_concept_map by doing a LEFT JOIN to source_to_concept_map as t1 on t1.source_code = hes_ccare.ccdisdest AND t1.source_vocabulary_id = “HESAPC_DISDEST_STCM”. | Definition to be added instead of number |
| discharge_to_source_value | ccdisdest | use ccdisdest to retrieve the source_code_description from source_to_concept_map by doing a LEFT JOIN to source_to_concept_map as t1 on t1.source_code = hes_ccare.ccdisdest AND t1.source_vocabulary_id = “HESAPC_DISDEST_STCM”. | Check for OMOP codes from ccdisdest |
| preceding_visit_detail_id | | If eorder = 1 then 0 else use eorder with patid+epikey to find the preceding_visit_detail_id |  |
| visit_detail_parent_id |  |  | Use patid + epikey where visit_detail_source_value= “Visit episode” to get the visit_detail_parent_id  |
| visit_occurrence_id |  |  | Use spno to retrieve visit_occurrence_id from visit_occurrence.visit_source_value   |