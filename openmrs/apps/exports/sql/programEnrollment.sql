SELECT
  o.identifier as 'id_emr',
  o.age as 'age',
  o.code as 'sex',
  o.program_name as 'tbregtype',
  MAX(IF(pat.program_attribute_type_id = '2', IF( pat.datatype LIKE "%Concept%", o.concept_name ,o.attr_value), NULL)) AS `regnum`,
  DATE_FORMAT(o.date_enrolled, '%d/%b/%Y') as 'd_reg',
  MAX(IF(pat.program_attribute_type_id = '6', IF( pat.datatype LIKE "%Concept%", o.concept_name ,o.attr_value), NULL)) AS `reg_facility`,
  o.outcome
  FROM
   (SELECT
      pi.identifier,
      floor(datediff(CURDATE(), p.birthdate) / 365) AS age,
      mcd.code,
      prog.name as program_name,
      attr.attribute_type_id,
      attr.value_reference as attr_value,
      pp.date_enrolled as date_enrolled,
      pp.patient_id,
      prog.program_id,
      cn.name as concept_name,
      outcome_concept.name as outcome,
      pp.patient_program_id
      FROM  patient_program pp
      JOIN program prog ON pp.program_id = prog.program_id
      and(
          (cast(pp.date_enrolled AS DATE) <=  '#endDate#')
           AND (cast(pp.date_completed AS DATE) >= '#startDate#' OR  pp.date_completed is NULL)
        )
     JOIN person p ON pp.patient_id = p.person_id
     JOIN person_name pn ON p.person_id = pn.person_id
     JOIN patient pa ON pp.patient_id = pa.patient_id
     JOIN patient_identifier pi ON pa.patient_id = pi.patient_id
     JOIN metadata_code_dictionary mcd ON p.gender = mcd.name

        LEFT OUTER JOIN patient_program_attribute attr ON pp.patient_program_id = attr.patient_program_id
     LEFT OUTER JOIN program_attribute_type attr_type ON attr.attribute_type_id = attr_type.program_attribute_type_id
     LEFT OUTER JOIN concept_name cn ON cn.concept_id = attr.value_reference
     LEFT OUTER JOIN concept_name outcome_concept ON outcome_concept.concept_id = pp.outcome_concept_id and outcome_concept.concept_name_type='FULLY_SPECIFIED'
     ) o
   LEFT OUTER JOIN program_attribute_type pat ON o.attribute_type_id = pat.program_attribute_type_id
   GROUP BY patient_id, patient_program_id
   ORDER BY patient_id, date_enrolled;
