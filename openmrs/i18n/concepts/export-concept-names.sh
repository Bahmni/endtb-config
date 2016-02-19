#!/bin/bash

# This file exports a message properties file of concept short names in english
# Inputs are the local database name and credentials from which to run this export, and the file name to export into
# This format was chosen for consistently and compatilibity with other OpenMRS metadata localization efforts

CURRENT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

read -e -p "Database Name: " -i "openmrs" DB_NAME
read -e -p "Database User: " -i "openmrs" DB_USER
read -e -p "Database Password: " -i "openmrs" DB_PW
read -e -p "Output File: " -i "$CURRENT_DIR/locale_en.properties" OUTPUT_FILE

QUERY="
	select concat('ui.i18n.Concept.name.', c.uuid), n.name
	from concept c
	inner join concept_name n ON c.concept_id=n.concept_id
	where n.concept_name_type='SHORT'
	and n.locale = 'en'
	and n.voided = 0
	and trim(n.name) <> ''
	order by c.date_created, c.uuid
"

mysql -u $DB_USER -p$DB_PW $DB_NAME -B -se "${QUERY}" > $OUTPUT_FILE

# Change from TSV to Properties file format with quotes around each entry
sed -i 's/\t/=/g' $OUTPUT_FILE