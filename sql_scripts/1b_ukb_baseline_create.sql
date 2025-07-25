CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.baseline (
	eid				bigint 		not null, --patientID	
	p31				smallint, 	--Sex
	p34				smallint, 	--Year of birth
	p52				smallint, 	--Month of birth
	p53_i0			date, 		--Date of attending assessment centre(Baseline assessment visit date)
	p53_i1			date, 		--Date of attending assessment centre(First repeat assessment date)
	p53_i2			date, 		--Date of attending assessment centre(Imaging visit date)
	p53_i3			date, 		--Date of attending assessment centre(Repeat imaging visit date)
	p54_i0			NUMERIC, 	--UK Biobank assessment centre(Assessment centre at baseline)
	p54_i1			NUMERIC, 	--UK Biobank assessment centre(Centre at first repeat assessment)
	p54_i2			NUMERIC, 	--UK Biobank assessment centre(Centre at imaging visit)
	p54_i3			NUMERIC, 	--UK Biobank assessment centre(Centre at repeat imaging assessment)
	p200			date, 		--Date of consenting to join UK Biobank	
	p20143			date, 		--Date of last personal contact with UK Biobank
	p21000_i0		NUMERIC, 	--Ethnic background(Baseline assessment)
	p21000_i1		NUMERIC, 	--Ethnic background(Repeat assessment)
	p21000_i2		NUMERIC, 	--Ethnic background(Imaging assessment)
	p21000_i3		NUMERIC, 	--Ethnic background(Repeat imaging assessment)
	p21022			int, 		--Age at recruitment
	p22189			NUMERIC, 	--Townsend deprivation index at recruitment
	p26410			NUMERIC, 	--Index of Multiple Deprivation (England)
	p26426			NUMERIC, 	--Index of Multiple Deprivation (Wales)
	p26427			NUMERIC, 	--Index of Multiple Deprivation (Scotland)
	p20116 			NUMERIC,	--Smoking status
    p1558 			NUMERIC,	--Alcohol intake frequency.
    p30620 			NUMERIC,	--Alanine aminotransferase
    p30600 			NUMERIC,	--Albumin
    p30610 			NUMERIC,	--Alkaline phosphatase
    p30630 			NUMERIC,	--Apolipoprotein A
    p30640 			NUMERIC,	--Apolipoprotein B
    p30650 			NUMERIC,	--Aspartate aminotransferase
    p30710 			NUMERIC,	--C-reactive protein
    p30680 			NUMERIC,	--Calcium
    p30690 			NUMERIC,	--Cholesterol
    p30700 			NUMERIC,	--Creatinine
    p30720 			NUMERIC,	--Cystatin C
    p30660 			NUMERIC,	--Direct bilirubin	
    p30730 			NUMERIC,	--Gamma glutamyltransferase
    p30740 			NUMERIC,	--Glucose
    p30750 			NUMERIC,	--Glycated haemoglobin (HbA1c)
    p30760 			NUMERIC,	--HDL cholesterol
    p30770 			NUMERIC,	--IGF-1
    p30780 			NUMERIC,	--LDL direct
    p30790 			NUMERIC,	--Lipoprotein A	
    p30800 			NUMERIC,	--Oestradiol
    p30810 			NUMERIC,	--Phosphate
    p30820 			NUMERIC,	--Rheumatoid factor
    p30830 			NUMERIC,	--SHBG
    p30850 			NUMERIC,	--Testosterone
    p30840 			NUMERIC,	--Total bilirubin
    p30860 			NUMERIC,	--Total protein
    p30870 			NUMERIC,	--Triglycerides
    p30880 			NUMERIC,	--Urate
    p30670 			NUMERIC,	--Urea
    p30890 			NUMERIC		--Vitamin D
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.death (
	eid					bigint,	
	ins_index			int,
	dsource				VARCHAR(4),
	source				int,
	date_of_death		date
)TABLESPACE pg_default;

CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}.death_cause (
	eid					bigint,	
	ins_index			int,
	arr_index			int,
	level				int,
	cause_icd10			VARCHAR(8)
)TABLESPACE pg_default;


CREATE TABLE IF NOT EXISTS {SOURCE_SCHEMA}._patid_deleted (
	patid			bigint 		not null,	
	reason			VARCHAR(1)
)TABLESPACE pg_default;