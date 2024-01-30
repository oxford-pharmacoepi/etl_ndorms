---
layout: default
title: HES OP
nav_order: 4
description: "Hospital Episode Statistics (HES) Out Patient (OP) ETL Documentation"
has_children: true
permalink: /docs/HES_OP
---

# Hospital Episode Statistics (HES)Outpatient Care ETL Documentation

These materials are meant to serve as documentation and reference for how the [HES OP](https://cprd.com/sites/default/files/2022-02/Documentation_HES_OP_set21.pdf) dataset was converted to the [OMOP Common Data Model (CDM)](https://ohdsi.github.io/CommonDataModel/).

The image below (Figure.1) shows a high-level diagram of how the native tables in the HES OP database were mapped to the OMOP CDM. The main HES OP tables converted include: (hesop_patient, hesop_appointment, hesop_clinical).

*HES OP source Data Mapping for CDM v5.3 & CDM v5.4*

![](images/image1.png)
**Figure.1**

## Change log

### 12-Dec-2023
- Creation of documentation