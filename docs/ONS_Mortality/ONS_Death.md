---
layout: default
title: Death 
nav_order: 1
parent: ONS Mortality
description: "Death mapping from ONS Death table"
---

# CDM Table name: DEATH (Tentative name: Death_ONS in database)

## Reading from ONS.Death

Linkage between ONS Mortality data and CPRD primary care data uses an eight-step deterministic linkage algorithm based on four identifiers, shown in Table 1 below. Postcode in the ONS data is based on the usual residence of the deceased as recorded in the death registration data. The linkage is undertaken by NHS Digital, acting as a trusted-third party, on behalf of CPRD. No personal identifiers are held by CPRD, or included in the CPRD GOLD, CPRD Aurum, or linked death registration data.

| Step | Match |
| --- | --- |
| 1 | Exact NHS number, sex, date of birth (DOB), postcode |
| 2 | Exact NHS number, sex, DOB |
| 3 | Exact NHS number, sex, postcode, partial DOB |
| 4 | Exact NHS number, sex, partial DOB |
| 5 | Exact NHS number, postcode |
| 6 | Exact sex, DOB and postcode(where the NHS number does not contradict the match, the DOB is not 1st of January and the postcode is not on the communal establishment list) |
| 7 | Exact sex, DOB and postcode(where the NHS number does not contradict the match and the DOB is not 1st of January) |
| 8 | Exact NHS number | 

The matching steps are applied sequentially. If a CPRD GOLD or CPRD Aurum patient record is matched in one step, it is no longer available for matching in subsequent steps.

CPRD provides users with a match_rank variable which corresponds to the step at which the match was established. In general, a lower value for the match_rank is considered stronger evidence for a positive match. 

**ONLY ONS death data with match_rank =1 or 2, within the linkage_coverage period and valid in the database linked (i.e. patients do not exists in the source_nok) to are used in our mapping.**
For Details, please refer to the [paper](https://pubmed.ncbi.nlm.nih.gov/32078979/). 

![](images/image02.png)

| Destination Field | Source field | Logic | Comment field |
| --- | --- | --- | --- |
| person_id | patid | | |
| death_date | dod | | |
| death_datetime | dod | | |
| death_type_concept_id | | [**32815** - Death Certificate](https://athena.ohdsi.org/search-terms/terms/32815) | |
| cause_concept_id | cause | cause_source_value will be mapped to SNOMED Concept_id by using ONS_DEATH_CAUSE_STCM, ICD10 and ICD9CM | Map cause_source_value by using ONS_DEATH_CAUSE_STCM, ICD10 and ICD9CM in follwoing sequence and conditions. <br><br>1. map the cause_source_value by ONS_DEATH_CAUSE_STCM.<br>2. If it does not match, map by ICD10 and ICD9CM.<br>3. If it does not match, map SUBSTRING(cause_source_value from 0 for 4) by ICD10.<br><br>It does not allow multiple death records for a single person in CDM Death. However,  some ICD10 and ICD9CM codes map to multiple standard concepts in Athena. ONS_DEATH_CAUSE_STCM, an STCM-tailored vocabulary, contains the mapping information between these codes and standard concepts.<br><br>ICD10 and ICD9CM codes with multiple 'Maps to' associations (i.e., maps to multiple standard concepts), ICD10 codes co-exist in ONS_DEATH_CAUSE_STCM, and ICD9CM codes co-exist in ICD10 or/and ONS_DEATH_CAUSE_STCM are disregarded in the mapping.  |
| cause_source_value | cause | | |
| cause_source_concept_id | cause | | |
