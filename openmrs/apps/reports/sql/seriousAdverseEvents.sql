SELECT
  ppa.value_reference AS 'Registration Number',
  GROUP_CONCAT(DISTINCT (IF(first_child_cn.name = 'SAE Form, SAE ID number', first_child_obs.value_text, NULL)) SEPARATOR ',') AS 'SAE case Number',
  GROUP_CONCAT(DISTINCT (IF(first_child_cn.name = 'SAE Form, SAE term comprehensive AE list', (SELECT coalesce(concept_short_name, concept_full_name) from concept_view where concept_id = first_child_obs.value_coded), NULL)) SEPARATOR ',') AS 'Serious Adverse Event term',
  GROUP_CONCAT(DISTINCT (IF(first_child_cn.name = 'SAE Form, Other SAE term', first_child_obs.value_text, NULL)) SEPARATOR ',') AS 'Other Serious Adverse event term not in comprehensive list',
  GROUP_CONCAT(DISTINCT (IF(first_child_cn.name = 'SAE Form, Event onset date', DATE_FORMAT(first_child_obs.value_datetime, '%d-%b-%Y'), NULL)) SEPARATOR ',') AS 'Date of SAE  onset',
  GROUP_CONCAT(DISTINCT (IF(first_child_cn.name = 'SAE Form, Date of SAE report', DATE_FORMAT(first_child_obs.value_datetime, '%d-%b-%Y'), NULL)) SEPARATOR ',') AS 'Date of SAE reporting',
  GROUP_CONCAT(DISTINCT (IF(first_child_cn.name = 'SAE Form, Previously reported as AE', (SELECT coalesce(concept_short_name, concept_full_name) from concept_view where concept_id = first_child_obs.value_coded), NULL)) SEPARATOR ',') AS 'Was this event previously reported as an AE',
  GROUP_CONCAT(DISTINCT (IF(first_child_cn.name = 'SAE Form, AE ID if previously reported as AE', first_child_obs.value_text, NULL)) SEPARATOR ',') AS 'If Yes, what is the AE ID number',
  GROUP_CONCAT(DISTINCT (IF(first_child_cn.name = 'SAE Form, Seriousness criteria', (SELECT coalesce(concept_short_name, concept_full_name) from concept_view where concept_id = first_child_obs.value_coded), NULL)) SEPARATOR ',') AS 'Seriousness criteria',
  GROUP_CONCAT(DISTINCT (IF(first_child_cn.name = 'SAE Form, Date event became serious', DATE_FORMAT(first_child_obs.value_datetime, '%d-%b-%Y'), NULL)) SEPARATOR ',') AS 'Date event became serious',
  GROUP_CONCAT(DISTINCT (IF(first_child_cn.name = 'SAE Form, TB drugs suspended due to this SAE', (SELECT coalesce(concept_short_name, concept_full_name) from concept_view where concept_id = first_child_obs.value_coded), NULL)) SEPARATOR ',') AS 'Were all anti-TB drug suspended due to this SAE?',
  GROUP_CONCAT(DISTINCT (IF(first_child_cn.name = 'SAE Form, SAE severity grade', (SELECT coalesce(concept_short_name, concept_full_name) from concept_view where concept_id = first_child_obs.value_coded), NULL)) SEPARATOR ',') AS 'SAE Grade (severity)'
FROM obs top_level_obs
  LEFT JOIN obs first_child_obs ON top_level_obs.obs_id = first_child_obs.obs_group_id AND first_child_obs.voided = 0
  LEFT JOIN concept_name top_level_cn ON top_level_cn.concept_id = top_level_obs.concept_id AND top_level_cn.concept_name_type = 'FULLY_SPECIFIED'
  LEFT JOIN concept_name first_child_cn ON first_child_cn.concept_id = first_child_obs.concept_id AND first_child_cn.concept_name_type = 'FULLY_SPECIFIED'
  INNER JOIN episode_encounter ee ON ee.encounter_id = top_level_obs.encounter_id
  INNER JOIN episode_patient_program epp ON ee.episode_id=epp.episode_id
  INNER JOIN patient_program pp ON pp.patient_program_id = epp.patient_program_id and pp.voided = 0
  INNER JOIN patient_program_attribute ppa ON ppa.patient_program_id=epp.patient_program_id
  INNER JOIN program_attribute_type pat ON pat.program_attribute_type_id=ppa.attribute_type_id AND pat.name='Registration Number'
  INNER JOIN patient_identifier pi ON pi.patient_id = top_level_obs.person_id AND top_level_obs.voided = 0
WHERE top_level_cn.name='Serious Adverse Events Template' AND cast(top_level_obs.obs_datetime AS DATE) BETWEEN '#startDate#' AND '#endDate#'
GROUP BY top_level_obs.obs_id;