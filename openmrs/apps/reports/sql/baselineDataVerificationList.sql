SELECT MAX(IF(pat.name='Registration Number', ppa.value_reference, NULL )) AS `Registration Number`,
       pi.identifier AS `EMR ID`,
       person_name.family_name AS `Patient Last name`,
       person_name.given_name AS `Patient First name`,
       DATE_FORMAT(tStartDate.value_datetime, '%d/%b/%Y') AS `Start ttr date`,
       DATE_FORMAT(dlm.start_date, '%d/%b/%Y') as 'Dlm Start Date',
       TRUNCATE(dlm.duration, 1) as 'Dlm Duration',
       DATE_FORMAT(bdq.start_date, '%d/%b/%Y') as 'Bdq Start Date',
       TRUNCATE(bdq.duration, 1) as 'Bdq Duration',

       MAX(IF(conceptObs.name = 'TI, Has the Treatment with New Drugs Consent Form been explained and signed', conceptObs.value, NULL)) AS `Consent for new drugs`,
       MAX(IF(conceptObs.name = 'TI, Has the endTB Observational Study Consent Form been explained and signed', conceptObs.value, NULL)) AS `Consent EndTB Study`,

       GROUP_CONCAT(IF(conceptObs.name = 'Baseline, Date of baseline', DATE_FORMAT(conceptObs.value, '%d/%b/%Y'), NULL) SEPARATOR ',') AS 'Date of baseline assessment',
       GROUP_CONCAT(IF(conceptObs.name = 'Baseline, HIV serostatus result', conceptObs.value,NULL) SEPARATOR ',') AS 'HIV Baseline',
       GROUP_CONCAT(IF(conceptObs.name = 'Lab, HIV test result',conceptObs.value,NULL)  SEPARATOR ',') AS 'Lab HIV',
       GROUP_CONCAT(IF(conceptObs.name = 'CD4 COUNT' AND conceptObs.obs_group_id =  groupObs.obs_id AND groupObs.name = 'Baseline, CD4 count details',conceptObs.value,NULL)  SEPARATOR ',') AS 'CD4 Baseline',
       GROUP_CONCAT(IF(conceptObs.name = 'CD4 COUNT' AND conceptObs.obs_group_id =  groupObs.obs_id AND groupObs.name = 'Lab, CD4 COUNT Data',conceptObs.value,NULL) SEPARATOR ',')  AS 'Lab CD4',
       GROUP_CONCAT(IF(conceptObs.name = 'HIV VIRAL LOAD' AND conceptObs.obs_group_id = groupObs.obs_id AND groupObs.name = 'Baseline, HIV Viral Load Details',conceptObs.value,NULL) SEPARATOR ',')  AS 'HIV VL Baseline',
       GROUP_CONCAT(IF(conceptObs.name = 'HIV VIRAL LOAD' AND conceptObs.obs_group_id = groupObs.obs_id AND groupObs.name = 'Lab, Serological and other tests',conceptObs.value,NULL) SEPARATOR ',')  AS 'HIV VL LAB',
       GROUP_CONCAT(IF(conceptObs.name = 'Baseline, Hepatitis B',conceptObs.value,NULL) SEPARATOR ',') AS 'Baseline Hepatitis B',
       GROUP_CONCAT(IF(conceptObs.name = 'Lab, Hepatitis B antigen test result',conceptObs.value,NULL) SEPARATOR ',')  AS 'Lab Hepatitis B',
       GROUP_CONCAT(IF(conceptObs.name = 'Baseline, Hepatitis C',conceptObs.value,NULL)  SEPARATOR ',') AS 'Baseline Hepatitis C',
       GROUP_CONCAT(IF(conceptObs.name = 'Lab, Hepatitis C antibody test result',conceptObs.value,NULL) SEPARATOR ',')  AS 'Lab Hepatitis C',
       GROUP_CONCAT(IF(conceptObs.name = 'Diabetes Mellitus',conceptObs.value,NULL) SEPARATOR ',')  AS 'Baseline Diabetes',
       GROUP_CONCAT(IF(conceptObs.name = 'glycosylated hemoglobin A measurement' AND conceptObs.obs_group_id = groupObs.obs_id AND groupObs.name = 'Baseline, Chronic Diseases',conceptObs.value,NULL) SEPARATOR ',')  AS 'Baseline HbA1c',
       GROUP_CONCAT(IF(conceptObs.name = 'glycosylated hemoglobin A measurement'AND conceptObs.obs_group_id = groupObs.obs_id AND groupObs.name = 'Lab, glycosylated hemoglobin A measurement Data',conceptObs.value,NULL) SEPARATOR ',')  AS 'Lab HbA1c',
       GROUP_CONCAT(IF(conceptObs.name = 'Baseline, Date of baseline physical examination',DATE_FORMAT(conceptObs.value, '%d/%b/%Y'),NULL) SEPARATOR ',')  AS 'Date of Baseline Physical Assessment',
       GROUP_CONCAT(IF(conceptObs.name = 'Weight (kg)' AND conceptObs.obs_group_id = groupObs.obs_id AND groupObs.name = 'Baseline, Clinical Examination',conceptObs.value,NULL) SEPARATOR ',')  AS 'Weight',
       GROUP_CONCAT(IF(conceptObs.name = 'Respiratory Rate' AND conceptObs.obs_group_id = groupObs.obs_id AND groupObs.name = 'Baseline, Clinical Examination',conceptObs.value,NULL)  SEPARATOR ',') AS 'Respiration Rate',
       GROUP_CONCAT(IF(conceptObs.name = 'Baseline, Colorblindness Screen Result',conceptObs.value,NULL) SEPARATOR ',')  AS 'Colour Blindness',
       GROUP_CONCAT(IF(conceptObs.name = 'Visual acuity, left eye' AND conceptObs.obs_group_id = groupObs.obs_id AND groupObs.name = 'Baseline, Visual Acuity', conceptObs.value,NULL) SEPARATOR ',')  AS 'Visual acuity, left eye',
       GROUP_CONCAT(IF(conceptObs.name = 'Visual acuity, right eye' AND conceptObs.obs_group_id = groupObs.obs_id AND groupObs.name = 'Baseline, Visual Acuity', conceptObs.value,NULL) SEPARATOR ',')  AS 'Visual acuity, right eye',
       GROUP_CONCAT(IF(conceptObs.name = 'Baseline, Pain Aching or Buring in Left Feet and Leg',conceptObs.value,NULL) SEPARATOR ',')  AS 'BPNS LEFT pain, ache, burning',
       GROUP_CONCAT(IF(conceptObs.name = 'Baseline, Pain Aching or Buring in Right Feet and Leg',conceptObs.value,NULL) SEPARATOR ',')  AS 'BPNS RIGHT pain, ache, burning'
FROM
  person_name,
  patient_program,
  patient_identifier pi,
  episode_patient_program epp,
  patient_program_attribute ppa,
  program_attribute_type pat,
  encounter e,
  obs tStartDate,
  concept_view tStartDateConcept,
  program,
  concept_name cn,
  episode_encounter ee
  LEFT JOIN
  (
    SELECT cv.concept_full_name AS name, ee.episode_id, o.obs_group_id,
           COALESCE(answer_concept.concept_short_name,
                    answer_concept.concept_full_name,
                    o.value_datetime,
                    o.value_numeric,
                    o.value_text) AS value
    FROM obs o
      JOIN concept_view cv ON cv.concept_id = o.concept_id AND o.voided = 0
      LEFT JOIN concept_view answer_concept ON answer_concept.concept_id = o.value_coded
      JOIN episode_encounter ee ON o.encounter_id = ee.encounter_id
    WHERE cv.concept_full_name IN ('Baseline, Date of baseline',
                                   'Baseline, HIV serostatus result',
                                   'Baseline, Hepatitis B',
                                   'Baseline, Hepatitis C',
                                   'Baseline, Date of baseline physical examination',
                                   'Baseline, Colorblindness Screen Result',
                                   'Baseline, Pain Aching or Buring in Left Feet and Leg',
                                   'Baseline, Pain Aching or Buring in Right Feet and Leg',
                                   'Lab, HIV test result',
                                   'Lab, Hepatitis B antigen test result',
                                   'Lab, Hepatitis C antibody test result',
                                   'Diabetes Mellitus',
                                   'CD4 COUNT',
                                   'HIV VIRAL LOAD',
                                   'glycosylated hemoglobin A measurement',
                                   'Weight (kg)',
                                   'Respiratory Rate',
                                   'Visual acuity, left eye',
                                   'Visual acuity, right eye',
                                   'TI, Has the endTB Observational Study Consent Form been explained and signed',
                                   'TI, Has the Treatment with New Drugs Consent Form been explained and signed')
  ) conceptObs ON conceptObs.episode_id = ee.episode_id
  LEFT JOIN
  (
    SELECT o.obs_id,
      o.encounter_id,
      cv.concept_full_name AS name
    FROM obs o
      JOIN concept_view cv ON cv.concept_id = o.concept_id AND o.voided = 0
      JOIN episode_encounter ee ON (o.encounter_id = ee.encounter_id)
    WHERE cv.concept_full_name IN ('Baseline, Date of baseline',
                                   'Baseline, CD4 count details',
                                   'Lab, CD4 COUNT Data',
                                   'Baseline, HIV Viral Load Details',
                                   'Lab, Serological and other tests',
                                   'Baseline, Chronic Diseases',
                                   'Lab, glycosylated hemoglobin A measurement Data',
                                   'Baseline, Clinical Examination',
                                   'Baseline, Visual Acuity')
  ) groupObs ON ee.encounter_id = groupObs.encounter_id AND conceptObs.obs_group_id = groupObs.obs_id
  LEFT JOIN
  (
    SELECT MIN(o.scheduled_date) AS start_date, ee.episode_id, d.name,
           SUM(TIMESTAMPDIFF(DAY, COALESCE(o.scheduled_date, o.date_activated), COALESCE(o.date_stopped, NOW())))/30 AS duration
    FROM episode_encounter ee,
      orders o,
      drug d,
      drug_order do
    WHERE o.order_id = do.order_id
          AND ee.encounter_id = o.encounter_id
          AND d.drug_id = do.drug_inventory_id
          AND o.voided = 0 AND o.order_action = 'NEW'
          AND o.scheduled_date <= NOW()
          AND d.name IN ('Delamanid (Dlm)')
    GROUP BY ee.episode_id
  ) dlm ON (dlm.episode_id = ee.episode_id)
  LEFT JOIN
  (
    SELECT MIN(o.scheduled_date) AS start_date, ee.episode_id ,d.name  ,
           SUM(TIMESTAMPDIFF(DAY, COALESCE(o.scheduled_date,o.date_activated), COALESCE(o.date_stopped, NOW())))/30 AS duration
    FROM episode_encounter ee,
      orders o,
      drug d,
      drug_order do
    WHERE o.order_id = do.order_id
          AND ee.encounter_id = o.encounter_id
          AND d.drug_id = do.drug_inventory_id
          AND o.voided = 0 AND o.order_action = 'NEW'
          AND o.scheduled_date <= NOW()
          AND d.name IN ('Bedaquiline (Bdq)')
    GROUP BY ee.episode_id
  ) bdq ON (bdq.episode_id = ee.episode_id)
WHERE person_name.person_id = patient_program.patient_id
      AND pi.patient_id = person_name.person_id
      AND epp.patient_program_id = patient_program.patient_program_id
      AND patient_program.voided = 0
      AND ppa.patient_program_id = patient_program.patient_program_id
      AND ppa.attribute_type_id = pat.program_attribute_type_id
      AND pat.name = 'Registration Number'
      AND ee.episode_id = epp.episode_id
      AND ee.encounter_id = e.encounter_id
      AND tStartDate.encounter_id = e.encounter_id
      AND tStartDate.concept_id = tStartDateConcept.concept_id
      AND tStartDate.voided = 0
      AND tStartDate.value_datetime BETWEEN '#startDate#' AND '#endDate#'
      AND tStartDateConcept.concept_full_name = 'TUBERCULOSIS DRUG TREATMENT START DATE'
      AND patient_program.program_id = program.program_id
      AND program.retired = 0
      AND program.concept_id = cn.concept_id
      AND cn.concept_name_type = 'FULLY_SPECIFIED'
      AND cn.voided = 0
      AND cn.name = 'Second-line TB treatment register'
GROUP BY epp.episode_id;
