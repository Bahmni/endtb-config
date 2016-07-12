SELECT
  t1.value_reference AS 'Registration Number',
  t1.identifier AS 'EMR ID',
  t1.indicator AS 'Indicator',
  t1.`ttr cohort`,
  DATE_FORMAT(t1.start_ttr,'%d/%b/%Y')  as 'Start ttr date',
  GROUP_CONCAT(DISTINCT(IF(t1.name='Baseline, Drug resistance', coalesce(t1.concept_short_name, t1.concept_full_name), NULL ))) AS 'Drug Resistance',
  GROUP_CONCAT(DISTINCT(IF(t1.name='Baseline, Subclassification for confimed drug resistant cases', coalesce(t1.concept_short_name, t1.concept_full_name), NULL ))) AS 'Drug Resistance Pattern',
  GROUP_CONCAT(DISTINCT(IF (t1.name='EOT, Outcome', coalesce(t1.concept_short_name, t1.concept_full_name), NULL ))) AS 'Ttr Outcome',
  GROUP_CONCAT(DISTINCT(IF (t1.name='Tuberculosis treatment end date', DATE_FORMAT(t1.value_datetime,'%d/%b/%Y'), NULL ))) AS 'End of ttr Date',
  GROUP_CONCAT(DISTINCT(IF (t1.name='EOT, End of Treatment Outcome date', DATE_FORMAT(t1.value_datetime,'%d/%b/%Y'), NULL ))) AS 'Ttr outcome date',
  Min(IF (t1.name='Tuberculosis treatment end date',TRUNCATE(TIMESTAMPDIFF(DAY,t1.start_ttr, t1.value_datetime)/30.5, 1), TRUNCATE(TIMESTAMPDIFF(DAY,t1.start_ttr, NOW())/30.5, 1) )) AS 'Ttr duration',
  MAX(M1) AS 'M1',  MAX(M2) AS 'M2', MAX(M3) AS 'M3', MAX(M4) AS 'M4', MAX(M5) AS 'M5', MAX(M6) AS 'M6',
  MAX(M7) AS 'M7',  MAX(M8) AS 'M8', MAX(M9) AS 'M9', MAX(M10) AS 'M10', MAX(M11) AS 'M11', MAX(M12) AS 'M12',
  MAX(M13) AS 'M13',  MAX(M14) AS 'M14', MAX(M15) AS 'M15', MAX(M16) AS 'M16', MAX(M17) AS 'M17', MAX(M18) AS 'M18',
  MAX(M19) AS 'M19',  MAX(M20) AS 'M20', MAX(M21) AS 'M21', MAX(M22) AS 'M22', MAX(M23) AS 'M23', MAX(M24) AS 'M24',
  MAX(M25) AS 'M25',  MAX(M26) AS 'M26', MAX(M27) AS 'M27', MAX(M28) AS 'M28', MAX(M29) AS 'M29', MAX(M30) AS 'M30',
  MAX(M31) AS 'M31',  MAX(M32) AS 'M32', MAX(M33) AS 'M33', MAX(M34) AS 'M34', MAX(M35) AS 'M35', MAX(M36) AS 'M36'
FROM
   (SELECT
      ppa.value_reference,
      pi.identifier ,
      COALESCE (cn1.concept_short_name,cn1.concept_full_name) as 'indicator',
      indicatorObs.value_numeric,
      CONCAT(DATE_FORMAT(o.value_datetime, '%Y'), QUARTER(o.value_datetime)) as 'ttr cohort',
      o.value_datetime as 'start_ttr',
      ttr_cn.name as name,
      ttr_cv.concept_short_name as concept_short_name,
      ttr_cv.concept_full_name as concept_full_name,
      ttr_obs.value_datetime as value_datetime,
      indicatorObs.obs_datetime as obs_datetime,
      ee.episode_id,
      cn1.concept_id as concept1,
      o.concept_id as concept2,
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + (EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime))) = 0, indicatorObs.value_numeric,NULL)   AS 'M1',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 1, indicatorObs.value_numeric,NULL)   AS 'M2',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 2, indicatorObs.value_numeric,NULL)   AS 'M3',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 3, indicatorObs.value_numeric,NULL)   AS 'M4',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 4, indicatorObs.value_numeric,NULL)   AS 'M5',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 5, indicatorObs.value_numeric,NULL)   AS 'M6',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 6, indicatorObs.value_numeric,NULL)   AS 'M7',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 7, indicatorObs.value_numeric,NULL)   AS 'M8',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 8, indicatorObs.value_numeric,NULL)   AS 'M9',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 9, indicatorObs.value_numeric,NULL)   AS 'M10',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 10, indicatorObs.value_numeric,NULL)   AS 'M11',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 11, indicatorObs.value_numeric,NULL)   AS 'M12',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 12, indicatorObs.value_numeric,NULL)   AS 'M13',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 13, indicatorObs.value_numeric,NULL)   AS 'M14',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 14, indicatorObs.value_numeric,NULL)   AS 'M15',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 15, indicatorObs.value_numeric,NULL)   AS 'M16',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 16, indicatorObs.value_numeric,NULL)   AS 'M17',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 17, indicatorObs.value_numeric,NULL)   AS 'M18',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 18, indicatorObs.value_numeric,NULL)   AS 'M19',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 19, indicatorObs.value_numeric,NULL)   AS 'M20',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 20, indicatorObs.value_numeric,NULL)   AS 'M21',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 21, indicatorObs.value_numeric,NULL)   AS 'M22',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 22, indicatorObs.value_numeric,NULL)   AS 'M23',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 23, indicatorObs.value_numeric,NULL)   AS 'M24',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 24, indicatorObs.value_numeric,NULL)   AS 'M25',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 25, indicatorObs.value_numeric,NULL)   AS 'M26',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 26, indicatorObs.value_numeric,NULL)   AS 'M27',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 27, indicatorObs.value_numeric,NULL)   AS 'M28',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 28, indicatorObs.value_numeric,NULL)   AS 'M29',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 29, indicatorObs.value_numeric,NULL)   AS 'M30',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 30, indicatorObs.value_numeric,NULL)   AS 'M31',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 31, indicatorObs.value_numeric,NULL)   AS 'M32',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 32, indicatorObs.value_numeric,NULL)   AS 'M33',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 33, indicatorObs.value_numeric,NULL)   AS 'M34',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 34, indicatorObs.value_numeric,NULL)   AS 'M35',
      if((EXTRACT(YEAR FROM indicatorObs.obs_datetime) - (EXTRACT(YEAR FROM o.value_datetime)))*12 + EXTRACT(MONTH FROM indicatorObs.obs_datetime) - (EXTRACT(MONTH FROM o.value_datetime)) = 35, indicatorObs.value_numeric,NULL)   AS 'M36'
FROM
  obs o
  INNER JOIN concept_name cn ON o.concept_id = cn.concept_id AND cn.concept_name_type='FULLY_SPECIFIED' AND cn.name='TUBERCULOSIS DRUG TREATMENT START DATE' AND o.voided=0
  INNER JOIN episode_encounter ee ON ee.encounter_id=o.encounter_id
  LEFT JOIN concept_view cn1 ON cn1.concept_full_name IN ('MTC, Overall DOT Rate','MTC, Adherence rate','MTC, Completeness rate')
  LEFT JOIN obs indicatorObs ON indicatorObs.person_id=o.person_id AND indicatorObs.voided=0 AND indicatorObs.concept_id = cn1.concept_id
  INNER JOIN episode_encounter ee1 ON ee1.episode_id = ee.episode_id AND ee1.encounter_id=indicatorObs.encounter_id
  LEFT JOIN obs ttr_obs ON ttr_obs.person_id = o.person_id and ttr_obs.voided=0
  LEFT JOIN concept_name ttr_cn ON ttr_obs.concept_id = ttr_cn.concept_id AND ttr_cn.concept_name_type='FULLY_SPECIFIED' AND ttr_cn.name in ('Baseline, Drug resistance','Baseline, Subclassification for confimed drug resistant cases', 'EOT, Outcome', 'Tuberculosis treatment end date','EOT, End of Treatment Outcome date')  AND ttr_obs.voided=0
  LEFT JOIN concept_view ttr_cv ON ttr_cv.concept_id=ttr_obs.value_coded
  INNER JOIN episode_encounter ee2 ON ee2.episode_id = ee.episode_id AND ee2.encounter_id=ttr_obs.encounter_id
  INNER JOIN episode_patient_program epp ON ee.episode_id=epp.episode_id
  INNER JOIN patient_program_attribute ppa ON ppa.patient_program_id=epp.patient_program_id
  INNER JOIN program_attribute_type pat ON pat.program_attribute_type_id=ppa.attribute_type_id AND pat.name='Registration Number'
  INNER JOIN patient_identifier pi ON pi.patient_id = o.person_id
WHERE o.value_datetime BETWEEN '#startDate#' AND '#endDate#') t1

GROUP BY t1.episode_id, t1.concept1, t1.concept2;

