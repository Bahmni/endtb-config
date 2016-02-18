#!/bin/bash

# This file exports a CSV of concept short names in english
# Inputs are the local database name and credentials from which to run this export, and the file name to export into
# Each row contains the concept uuid, followed by the english concept short name
# The format is Magento CSV, for compatibility with Transifex (http://docs.transifex.com/formats/magento-csv/)
# Each entry is double-quoted.  Any double quotes found within an entry are represented as ""
# So, if the database entry is "failed" MDR regimen, this is represneted in the CSV as """failed"" MDR regimen"

CURRENT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

read -e -p "Database Name: " -i "openmrs" DB_NAME
read -e -p "Database User: " -i "openmrs" DB_USER
read -e -p "Database Password: " -i "openmrs" DB_PW
read -e -p "Output File: " -i "$CURRENT_DIR/locale_en.csv" OUTPUT_FILE

QUERY="
	select c.uuid, n.name
	from concept c
	inner join concept_name n ON c.concept_id=n.concept_id
	where n.concept_name_type='SHORT'
	and n.locale = 'en'
	and n.voided = 0
	and trim(n.name) <> ''
	order by c.date_created, c.uuid
"

mysql -u $DB_USER -p$DB_PW $DB_NAME -B -se "${QUERY}" > $OUTPUT_FILE

# Escape all " in results with ""
sed -i 's/"/""/g' $OUTPUT_FILE

# Change from TSV to CSV with quotes around each entry
sed -i 's/\t/","/g' $OUTPUT_FILE
sed -i 's/^/"/' $OUTPUT_FILE
sed -i 's/$/"/' $OUTPUT_FILE