SELECT
  o.identifier as 'id_emr',
  o.family_name as 'surname',
  o.given_name as 'given_name',
  DATE_FORMAT(o.birthdate, '%d/%b/%Y') as 'dob',
  o.age as 'age',
  GROUP_CONCAT(DISTINCT (IF(o.gender = 'M',1, IF(o.gender = 'F',2, 3))) SEPARATOR ',') AS 'sex',
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'nationalIdentificationNumber', o.attr_value, NULL)) SEPARATOR ',') AS `id_nat`,
  DATE_FORMAT(o.date_created, '%d/%b/%Y') as `creation_date`,
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'patientAddress',o.attr_value, NULL)) SEPARATOR ',') AS `address_line1`,
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'patientAddressLine2',o.attr_value, NULL)) SEPARATOR ',') AS `address_line2`,
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'patientDistrict',o.attr_value, NULL)) SEPARATOR ',') AS `res_district`,
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'patientCountry',o.attr_value, NULL)) SEPARATOR ',') AS `res_country`,
  GROUP_CONCAT(DISTINCT(IF(pat.name = 'telephoneNumber', o.attr_value, NULL)) SEPARATOR ',') AS `telephone_number`
FROM
  (SELECT
     pi.identifier,
     pn.given_name,
     pn.family_name,
     floor(datediff(CURDATE(), p.birthdate) / 365) AS age,
     p.gender,
     p.birthdate,
     pa.date_created,
     attr.person_attribute_type_id,
     coalesce(person_attribute_cn.concept_short_name, person_attribute_cn.concept_full_name,
              IF(attr_type.format LIKE "%Boolean%", IF(attr.value="true", "Yes", null) ,attr.value)) as attr_value,
     p.person_id
   FROM  person p
     JOIN patient pa ON p.person_id = pa.patient_id and cast(pa.date_created AS DATE) BETWEEN '#startDate#' AND '#endDate#'
     JOIN person_name pn ON p.person_id = pn.person_id
     JOIN patient_identifier pi ON pa.patient_id = pi.patient_id
     LEFT OUTER JOIN person_address addr ON p.person_id = addr.person_id
     LEFT OUTER JOIN person_attribute attr ON p.person_id = attr.person_id and attr.voided = false
     LEFT OUTER JOIN person_attribute_type attr_type ON attr.person_attribute_type_id = attr_type.person_attribute_type_id
     LEFT JOIN concept_view person_attribute_cn ON attr.value = person_attribute_cn.concept_id AND attr_type.format LIKE "%Concept") o
  LEFT OUTER JOIN person_attribute_type pat ON o.person_attribute_type_id = pat.person_attribute_type_id
group by person_id;
