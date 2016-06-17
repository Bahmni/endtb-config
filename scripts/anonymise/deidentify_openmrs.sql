SET FOREIGN_KEY_CHECKS=0;
-- these tables will not be used, so drop their contents 
truncate table concept_proposal_tag_map;
truncate table concept_proposal;
truncate table hl7_in_archive;
truncate table hl7_in_error;
truncate table hl7_in_queue;
truncate table user_property;
truncate table notification_alert_recipient;
truncate table notification_alert;
SET FOREIGN_KEY_CHECKS=1;

-- randomize the person names (given_name and family_name to contain random 8 alpha-numeric characters)
update person_name set given_name = upper(substring(uuid(),1,8)), family_name = upper(substring(uuid(),1,8));

-- Randomize the birth dates and months (leave years the same)
-- randomize +/- 0-6 months (~182 days) for persons older than ~15 yrs old
update person set birthdate = date_add(birthdate, interval cast(rand()*182*2-182 as signed) day) where birthdate is not null and datediff(now(), birthdate) > 15*365;
-- randomize +/- 0-3 months (~91 days) for persons between 15 and 5 years old
update person set birthdate = date_add(birthdate, interval cast(rand()*91*2-91 as signed) day) where birthdate is not null and datediff(now(), birthdate) between 15*365 and 5*365;
-- randomize +/- 0-30 days for persons less than ~5 years old
update person set birthdate = date_add(birthdate, interval cast(rand()*30*2-30 as signed) day) where birthdate is not null and datediff(now(), birthdate) < 5*365;

-- randomize the estimation on DOB (true or false)
update person set birthdate_estimated = cast(rand() as signed);

-- Update person address in person_attributes (text fields)
-- Add if you need more text field person attributes to be randomized
UPDATE person_attribute
	INNER JOIN person_attribute_type on person_attribute_type.person_attribute_type_id = person_attribute.person_attribute_type_id
	AND person_attribute_type.name in ('patientAddress','patientAddressLine2','patientDistrict','patientCountry')
	SET person_attribute.value = upper(substring(uuid(),1,8));

-- Update patient telephone number and National Identification Number (numeric fields)
-- Add if you need more numeric field person attributes to be randomized
UPDATE person_attribute
	INNER JOIN person_attribute_type on person_attribute_type.person_attribute_type_id = person_attribute.person_attribute_type_id
	AND person_attribute_type.name in ('telephoneNumber','nationalIdentificationNumber')
	SET person_attribute.value = round(rand() * 3294967296)+1000000000;

-- identifiers (Assumes patient_identifier have been truncated)
UPDATE  patient_identifier SET identifier = concat(if((select count(*) from idgen_seq_id_gen) !=0, (select prefix from idgen_seq_id_gen order by rand() limit 1), 'ETB'), patient_id);

-- Randomize the treatment ID
update patient_program_attribute 
	set value_reference = upper(substring(uuid(),1,8))
	where attribute_type_id = 
	(select program_attribute_type_id from program_attribute_type where name = 'Registration Number');


-- Randomize the IDs captured as observations 
-- For text fields (uncomment the below section and add more fields which you want to be randomized)
/*
update obs set value_text = upper(substring(uuid(),1,8)) where concept_id in 
	(select concept_id from concept_view 
		where concept_full_name in 
		('Specimen Id') and concept_datatype_name = 'Text');
*/

-- For numberic fields (uncomment the below section and add more fields which you want to be randomized)
/*update obs set value_numeric = ROUND(RAND() * 32949672)+10000000 where concept_id in
	(select concept_id from concept_view 
                where concept_full_name in 
                ('Lab, Sample ID') and concept_datatype_name = 'Numeric');
*/
