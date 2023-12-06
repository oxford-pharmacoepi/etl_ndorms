---
layout: default
title: HES AE
nav_order: 3
description: "Hospital Episode Statistics (HES) Admitted Patient Care (APC) ETL Documentation"
has_children: true
permalink: /docs/HES_AE
---

# Hospital Episode Statistics (HES) Accident & Emergency ETL Documentation

These materials are meant to serve as documentation and reference for how the [HES AE](https://cprd.com/sites/default/files/2022-02/Documentation_HES_AE_set21.pdf) dataset was converted to the [OMOP Common Data Model (CDM)](https://ohdsi.github.io/CommonDataModel/).

The image below (Figure.1) shows a high-level diagram of how the native tables in the HES AE database were mapped to the OMOP CDM. The main HES AE tables converted include: (hesae_patient, hesae_diagnosis, hesae_investigation, hesae_hrg, hesae_attendance, hesae_pathway and hesae_patient).

