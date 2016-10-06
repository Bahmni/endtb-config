update global_property set property_value = ('SELECT ppa.value_reference as identifier,
  concat(pn.given_name,'' '', pn.family_name) AS name,
  prog.name AS Treatment,
  p.gender AS gender,
  floor(datediff(now(), p.birthdate)/365) AS age,
  concat("",p.uuid) AS uuid,
  pi.identifier AS "EMR ID"
FROM patient_program pp
  INNER JOIN program prog ON pp.program_id = prog.program_id
  INNER JOIN patient_program_attribute ppa ON pp.patient_program_id = ppa.patient_program_id
  INNER JOIN program_attribute_type pat ON ppa.attribute_type_id = pat.program_attribute_type_id
  INNER JOIN person_name pn ON pp.patient_id = pn.person_id
  INNER JOIN person p ON p.person_id = pn.person_id
  INNER JOIN patient_identifier pi ON pn.person_id = pi.patient_id AND pi.identifier_type = (SELECT patient_identifier_type_id FROM patient_identifier_type WHERE name = ''Patient Identifier'')
WHERE pat.name = ''Registration Number'' AND p.voided = 0 AND pn.voided = 0 AND prog.retired=0 AND pp.voided = 0
GROUP BY ppa.value_reference')
where property = "emrapi.sqlSearch.allPatients";

