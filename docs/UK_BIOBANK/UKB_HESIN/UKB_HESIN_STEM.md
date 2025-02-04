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
| visit_occurrence_id |eid,<br>hesin.spell_index | |  |
| visit_detail_id|eid,<br>ins_index || |
| source_value| diag_icd9,<br>diag_icd10 |add dots when necessary | diag_icd9 and diag_icd10 are mutually exclusive; they are provided without dots|
| source_concept_id | diag_icd9,<br>diag_icd10 | | |
| type_concept_id |  | [32829 - EHR administration record](https://athena.ohdsi.org/search-terms/terms/32829)| | |
| start_date | hesin.epistart,<br>hesin.admidate | | use the first not null of (hesin.epistart, hesin.admidate) |
| start_datetime | hesin.epistart,<br>hesin.admidate|   | |
| end_date | hesin.epiend,<br>hesin.disdate,<br>hesin.epistart,<br>hesin.admidate | | use the first not null of (hesin.epiend,hesin.disdate,hesin.epistart,hesin.admidate)|
| end_datetime | hesin.epiend,<br>hesin.disdate,<br>hesin.epistart,<br>hesin.admidate | | |
| concept_id  |  diag_icd9,<br>diag_icd10 |   | use ICD9CM or ICD10 vocabulary depending on the presence of diag_icd9 or diag_icd10 |
| disease_status_source_value |level | | use  [32902](https://athena.ohdsi.org/search-terms/terms/32902) for primary diagnosis (level = 1) or [32908](https://athena.ohdsi.org/search-terms/terms/32908)  for secondary diagnosis (level > 1)|
| stem_source_table | | hesin_diag | |
 
## Reading from hesin_oper, hesin

![](images/ukb_oper_to_stem.png)


| Destination Field | Source field | Logic | Comment field |
| --- | --- | :---: | --- |
| id|||Autogenerate|
| domain_id | NULL | | | 
| person_id | eid | | | 
| visit_occurrence_id |eid,<br>hesin.spell_index | |  |
| visit_detail_id|eid,<br>ins_index |||
| source_value| oper4 | add dots when necessary| OPCS4 codes are provided without dots|
| source_concept_id | oper4 | | |
| type_concept_id |  | [32829 - EHR administration record](https://athena.ohdsi.org/search-terms/terms/32829)| | |
| modifier_source_value | level | | |
| start_date | opdate,<br>hesin.epistart | | use the first not null of (opdate,hesin.epistart)|
| start_datetime | opdate,<br>hesin.epistart |   | |
| end_date | opdate,<br>hesin.epistart | | use the first not null of (opdate,hesin.epistart) |
| end_datetime | opdate,<br>hesin.epistart  | | |
| concept_id  | oper4  |  | use OPSC4 vocabulary |
| stem_source_table | | hesin_oper | |