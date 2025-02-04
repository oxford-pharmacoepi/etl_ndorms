---
layout: default
title: UKB HESIN to STEM
nav_order: 6
parent: UKB HESIN
description: "Stem table description"

---

# CDM Table name: stem_table (CDM v5.4)

## Reading from hesin_diag, hesin

![](images/ukb_diag_to_stem.png)


| Destination Field | Source field | Logic | Comment field |
| --- | --- | :---: | --- |
| id|||Autogenerate|
| domain_id | NULL | | | 
| person_id | eid | | | 
| visit_occurrence_id |eid,<br>hesin.spell_index | | Use eid, hesin.spell_index to retrieve visit_occurrence_id |
| visit_detail_id|eid,<br>ins_index ||Use eid, ins_index to retrieve visit_detail_id |
| source_value| diag_icd9,<br>diag_icd10 |Add dots when necessary | ICD9 & ICD10 codes provided without dots|
| source_concept_id | diag_icd9,<br>diag_icd10 | | |
| type_concept_id |  | 32829 | |
| start_date | hesin.epistart,<br>hesin.admidate | | If hesin.epistart is null use hesin.admidate|
| start_datetime | hesin.epistart,<br>hesin.admidate|   | |
| end_date | hesin.epiend,<br>hesin.disdate,<br>hesin.epistart,<br>hesin.admidate | | Use the first not null of (hesin.epiend,hesin.disdate,hesin.epistart,hesin.admidate)|
| end_datetime | hesin.epiend,<br>hesin.disdate,<br>hesin.epistart,<br>hesin.admidate | | |
| concept_id  | NULL |  |  |
| disease_status_source_value | | | |
| stem_source_table | | "hesin_diag" | |
 
## Reading from hesin_oper, hesin

![](images/ukb_oper_to_stem.png)


| Destination Field | Source field | Logic | Comment field |
| --- | --- | :---: | --- |
| id|||Autogenerate|
| domain_id | NULL | | | 
| person_id | eid | | | 
| visit_occurrence_id |eid,<br>hesin.spell_index | | Use eid, hesin.spell_index to retrieve visit_occurrence_id |
| visit_detail_id|eid,<br>ins_index ||Use eid, ins_index to retrieve visit_detail_id |
| source_value| oper4 | Add dots when necessary| OPCS4 Codes are provided without dots|
| source_concept_id | oper4 | | |
| type_concept_id |  | 32829 | |
| modifier_source_value |  | | |
| start_date | opdate,<br>hesin.epistart | | If opdate is null then use hesin.epistart|
| start_datetime | opdate,<br>hesin.epistart |   | |
| end_date | opdate,<br>hesin.epiend | | If opdate is null then use hesin.epiend |
| end_datetime | opdate,<br>hesin.epistart  | | |
| concept_id  | NULL  |  |  |
| stem_source_table | | "hesin_oper" | |