How to run the ETL for OMOP CDM 5.3 for Windows in Python (v. 3.2 onwards) using Postgresql

First time setup:
1. If you don't already have it, download the latest version of python 3.x from https://www.python.org/downloads/ and add the path to the directory containing the python executables to your environment variables.
2. Open a new command prompt as ADMINSTRATOR and navigate to the root of the aurum_etl module.
3. Download the python-postgres client with `pip install psycopg2`.
4. Download the python sqlparse with `pip install sqlparse`.
5. If you don't already have it, request an EPI KEY to use with the ATHENA vocabularies from: https://uts.nlm.nih.gov/uts/umls/home

Download ATHENA Vocabularies:
1. Request vocabularies from: https://athena.ohdsi.org/vocabulary/list
2. Download the zipped file in an appropriate directory, unzip and follow the ATHENA instructions
3. Run	"java -Dumls-apikey=YOUR_EPI_KEY -jar cpt4.jar 5"

Run the ETL:
1. In postgres, create a database 
	<!--
	with this comand CREATE DATABASE \<db_name\>
	WITH
	OWNER = postgres
	ENCODING = 'UTF8'
	LC_COLLATE = 'English_United States.1252'
	LC_CTYPE = 'English_United States.1252'
	TABLESPACE = \<appropriate_tablespece\>	#Only if you need the define a tablespace different from the default one
	CONNECTION LIMIT = -1
	IS_TEMPLATE = False;-->

2.	Move the file `__postgres_db_conf.py` to the \<full project_directory\>, open it with a plain editor and customise to suit your particular ETL
3.	Open a new command prompt where you have deployed the python code
4.	if db_type == 'gold': Run `py 0_manage_gold_files.py` -F\<full project_directory\> <br><br>
	A full project_directory (e.g. D:\dir1\dir2\dir3\dir4\hesapc) has at least the following subfolders: data, lookups, source_to_concept_map, vocabulary
5.	Run `py 1_load_source_data.py` -F\<full project_directory\>
6.	Run `py 2_load_lookup.py` -F\<full project_directory\>
7.	Run `py 3_load_cdm_vocabulary.py` -F\<full project_directory\>
8.	if db_type == 'gold': Run CREATE FILE FOR DAYSUPPLY
9.	if db_type == 'gold': Run C\# (Teen)<br>
	else Run `py 4_map_source_in_chunk.py` -F\<full project_directory\><br>
10.	Run `py 5_build_cdm_pk_idx.py` -F\<full project_directory\>
11.	Run `py 6_build_cdm_era_tbl.py` -F\<full project_directory\>
12.	Run `py 7_count_cdm_records.py` -F\<full project_directory\>
13.	If needed, Run `py 8_load_source_denominator.py` -F\<full project_directory\>

Check data quality:<br>
1. Run Achilles<br>
2. Run DQD

