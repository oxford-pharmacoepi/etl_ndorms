How to run the ETL for CPRD Aurum to the OHDSI CDM

First time setup:
1. If you don't already have it, download the latest version of python 3.x from https://www.python.org/downloads/ and add the path to the directory containing the python executables to your environment variables.
2. Open a new command prompt and navigate to the root of the aurum_etl module.
3. Download the python-postgres client with `pip install psycopg2`.
4. Download the python sqlparse with `pip install sqlparse`.
5. If you don't already have it, request an EPI KEY to use with the ATHENA vocabularies from: https://uts.nlm.nih.gov/uts/umls/home

Download ATHENA Vocabularies:
1. Request vocabularies from: https://athena.ohdsi.org/vocabulary/list
2. Download the zipped file in an appropriate directory, unzip and follow the ATHENA instructions
3. Run	"java -Dumls-apikey=YOUR_EPI_KEY -jar cpt4.jar 5"

Create database:
1. In postgres, create a database with this comand
	CREATE DATABASE <db_name>
    WITH OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'English_United States.1252'
    LC_CTYPE = 'English_United States.1252'
    TABLESPACE = tablespace_e
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

Setup config file:
2.	Open `__postgres_db_conf.py` in an plain editor and change the settings to suit this particular ETL: i.e.
	username - String. The username for your postgresql account.
	password - String. The password for your postgresql account.
	database - String. The name of the database that you will be mapping in.
	source_schema - String. The name of the schema that you have created to contain the source data, e.g. 'source'.
	source_nok_schema - String. The name of the schema that you have created to contain unacceptable source data, e.g. 'source_nok'.
	target_schema - String. The name of the schema that you have created to contain your CDM tables, e.g. 'public'.
	vocabulary_schema - String. The name of the schema that you have created to contain your vocabulary tables, e.g. 'vocabulary'. This could be the same as target_schema if you want.
	chunk_size - Integer. This specifies the amount of patients to be processed in each chunk. 1000 patients seems to be a good medium.
	chunk_limit - Integer. If this number is greater than 0 then it will limit the number of chunks to be processed to this value. If the value is less than 1 then it will be ignored. Once these chunks have completed, the script will end unless all chunks have been processed, in which case the final queries will run.
	log_directory - String. The full path to the directory where log files will be written to. If the log directory does not already exist, then it will be created when a script that utilises logging is executed. The path leading up to the log directory, however, must already exist for the logging to work.
	source_data_directory - String. The full path to the directory that contains your source data. The script assumes that within this directory there will be sub-directories with the following names: consultation, drugissue, observation, patient, practice, problem, referral and staff; each containing their respective data (they could also be empty if you don't have data for a particular table).
	lookup_directory - String. The full path to the directory containing lookup tables and medical and drug dictionaries. These text files need to all be stored at the same level for the 2_load_lookups.py to work correctly.
	vocabulary_directory - String. The full path to the directory containing the CDM vocabulary files. Each of these text files should be stored at the same level.
	stcm_directory - String. The full path to the directory containing any source_to_concept_map files that you want to include in the ETL. These files should use a comma as their field delimiter and double quote as a text-qualifier if they are needed.
	medical_dictionary_filename - String. The name of the medical dictionary file (including the file extension).
	product_dictionary_filename - String. The name of the product dictionary file (including the file extension).

3.	Open a new command prompt and navigate to the root of the aurum_etl module using `cd <PATH\TO\AURUM_ETL\MODULE>` (e.g. D:\cprd\_nathan\aurum_etl_ndorms).
4.	Run `py 1_load_source_data.py`
5.	Run `py 2_load_lookup.py`
6.	Run `py 3_load_cdm_vocabulary.py`
7.	Run `py 4_map_aurum_in_chunk.py`
8.	Run `py 5_build_cdm_pk_idx_fk.py`
9.	Run `py 6_build_cdm_era_tbl.py`
	Note that you probably only need to run the first two sets of queries for condition_era and drug_era as I don't think dose_era inserts any data for this mapping.
10.	Run `py 7_count_cdm_records.py`
10.	Run `py 8_load_source_denominator.py` -- OPTIONAL
11. Run Achilles
12. Run DQD

