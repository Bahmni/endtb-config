SELECT *
FROM
  (SELECT
     MAX(IF(pat.name='Registration Number', ppa.value_reference, NULL ))  AS `Registration Number`,
     pi.identifier  AS `EMR ID`,
     DATE_FORMAT(adm.obs_datetime, '%b/%Y') AS 'Adherence Data Month',
     MAX(IF(tsd_cv.concept_full_name='TUBERCULOSIS DRUG TREATMENT START DATE' ,DATE_FORMAT(tsd.value_datetime, '%d/%b/%Y'), NULL )) As 'Treatment Start Date',
     ROUND(MAX(IF(tsd_cv.concept_full_name='TUBERCULOSIS DRUG TREATMENT START DATE',(TIMESTAMPDIFF(DAY,tsd.value_datetime,LAST_DAY(adm.obs_datetime)))/30.5,NULL)),1)          AS 'Treatment Duration',
     MAX(IF(tsd_cv.concept_full_name='Tuberculosis treatment end date' ,DATE_FORMAT(tsd.value_datetime, '%d/%b/%Y'), NULL )) As 'Treatment End Date',
     COALESCE(MAX(treat_det_coded.concept_full_name), MAX(IF(pat.name='Registration Facility',reg_facility.concept_full_name, NULL ))) As 'Current Treatment Facility',
     MAX(IF(rate_cv.concept_full_name='MTC, Completeness rate', rate.value_numeric, NULL)) As 'Completeness Rate',
     MAX(IF(rate_cv.concept_full_name='MTC, Adherence rate', rate.value_numeric, NULL)) As 'Adherence Rate',
     MAX(IF(rate_cv.concept_full_name='MTC, Overall DOT Rate', rate.value_numeric, NULL)) As 'DOT Rate',
     MAX(IF(rate_cv.concept_full_name='MTC, Ideal total treatment days in the month', rate.value_numeric, NULL)) As 'Ideal Ttr days',
     MAX(IF(rate_cv.concept_full_name='MTC, Non prescribed days', rate.value_numeric, NULL)) As 'Non Presr. days',
     MAX(IF(rate_cv.concept_full_name='MTC, Missed prescribed days', rate.value_numeric, NULL)) As 'Missed days',
     MAX(IF(rate_cv.concept_full_name='MTC, Incomplete prescribed days', rate.value_numeric, NULL)) As 'Uncompl. days',
     GROUP_CONCAT(DISTINCT(IF(rate_cv.concept_full_name='MTC, Principal reason for treatment incomplete', rate_coded.concept_full_name, NULL))) As 'Principal reason for < 100 incomplete',
     GROUP_CONCAT(DISTINCT(IF(rate_cv.concept_full_name IN ('MTC, Detailed program related reason',
                                                            'MTC, Detailed medical related reason',
                                                            'MTC, Detailed patient related reason',
                                                            'MTC, Other reason for treatment incomplete'), COALESCE(rate_coded.concept_full_name,rate.value_text), NULL))) As 'Detailed reasons for < 100% completeness',
     GROUP_CONCAT(DISTINCT(IF(rate_cv.concept_full_name='MTC, Additional contributing reasons for less than 100% completeness', rate_coded.concept_full_name, NULL))) As 'Additional reasons for < 100% completeness',
     GROUP_CONCAT(DISTINCT(IF(rate_cv.concept_full_name IN ('MTC, Additional contributing program related reasons',
                                                            'MTC, Additional contributing medical or treatment related reasons',
                                                            'MTC, Additional contributing patient related reasons',
                                                            'MTC, Other contributing reason for treatment incomplete'),  COALESCE(rate_coded.concept_full_name,rate.value_text), NULL))) As 'Additional  detailed reasons for < 100% completeness'
   FROM
     patient_identifier pi
     JOIN patient_program pp ON  pp.patient_id = pi.patient_id
     JOIN episode_patient_program epp ON epp.patient_program_id = pp.patient_program_id and pp.voided=0
     JOIN patient_program_attribute ppa ON  ppa.patient_program_id = pp.patient_program_id AND ppa.voided=0
     JOIN program_attribute_type pat ON ppa.attribute_type_id = pat.program_attribute_type_id
     JOIN episode_encounter adm_ee ON adm_ee.episode_id = epp.episode_id
     JOIN obs adm ON adm_ee.encounter_id=adm.encounter_id AND adm.voided=0
     JOIN concept_view adm_cv ON adm_cv.concept_id = adm.concept_id AND adm_cv.concept_full_name = 'MTC, Month and year of treatment period'

     JOIN episode_encounter episode_ee ON episode_ee.episode_id = adm_ee.episode_id
     LEFT JOIN concept_view reg_facility ON reg_facility.concept_id = ppa.value_reference
     LEFT JOIN obs rate ON rate.obs_datetime = adm.obs_datetime AND rate.voided =0 AND rate.encounter_id = episode_ee.encounter_id

     LEFT JOIN concept_view rate_cv ON rate_cv.concept_id= rate.concept_id AND rate_cv.concept_full_name
                                                                               IN (
                                                                                 'MTC, Completeness rate',
                                                                                 'MTC, Adherence rate',
                                                                                 'MTC, Overall DOT Rate',
                                                                                 'MTC, Ideal total treatment days in the month',
                                                                                 'MTC, Non prescribed days',
                                                                                 'MTC, Missed prescribed days',
                                                                                 'MTC, Incomplete prescribed days',
                                                                                 'MTC, Principal reason for treatment incomplete',
                                                                                 'MTC, Detailed program related reason',
                                                                                 'MTC, Detailed medical related reason',
                                                                                 'MTC, Detailed patient related reason',
                                                                                 'MTC, Other reason for treatment incomplete',
                                                                                 'MTC, Additional contributing reasons for less than 100% completeness',
                                                                                 'MTC, Additional contributing program related reasons',
                                                                                 'MTC, Additional contributing medical or treatment related reasons',
                                                                                 'MTC, Additional contributing patient related reasons',
                                                                                 'MTC, Other contributing reason for treatment incomplete'
                                                                               )
     LEFT JOIN concept_view rate_coded ON rate_coded.concept_id = rate.value_coded

     JOIN concept_view tsd_cv ON tsd_cv.concept_full_name IN ('TUBERCULOSIS DRUG TREATMENT START DATE', 'Tuberculosis treatment end date')
     LEFT JOIN obs tsd ON tsd.voided =0 AND tsd.concept_id = tsd_cv.concept_id AND episode_ee.encounter_id = tsd.encounter_id

     JOIN concept_view max_date ON max_date.concept_full_name IN ('TI, Treatment facility at start',
                                                                  'Treatment Facility Name')
     LEFT JOIN obs treat_det ON treat_det.concept_id= max_date.concept_id AND treat_det.encounter_id = episode_ee.encounter_id AND treat_det.voided=0
                                AND ( episode_ee.episode_id, treat_det.obs_datetime) IN (SELECT max_date_ee.episode_id,
                                                                                           MAX(max_date.obs_datetime) AS max_obs_datetime
                                                                                         FROM obs max_date
                                                                                           JOIN episode_encounter max_date_ee ON max_date_ee.encounter_id = max_date.encounter_id and max_date.voided = 0
                                                                                           JOIN concept_view max_date_cv ON max_date_cv.concept_id = max_date.concept_id AND max_date_cv.concept_full_name
                                                                                                                                                                             IN ('TI, Treatment facility at start',
                                                                                                                                                                                 'Treatment Facility Name')
                                                                                         GROUP BY max_date_ee.episode_id)
     LEFT JOIN concept_view treat_det_coded ON treat_det.value_coded = treat_det_coded.concept_id

   GROUP BY adm_ee.episode_id, adm.obs_datetime) innerQuery


WHERE STR_TO_DATE(CONCAT('01/',innerQuery.`Adherence Data Month`), '%d/%b/%Y') BETWEEN DATE_FORMAT('#startDate#', '%Y-%m-01') AND DATE_FORMAT('#endDate#', '%Y-%m-01')
      AND (STR_TO_DATE(innerQuery.`Treatment End Date`, '%d/%b/%Y') IS NULL OR STR_TO_DATE(CONCAT('01/',innerQuery.`Adherence Data Month`), '%d/%b/%Y') <= STR_TO_DATE(innerQuery.`Treatment End Date`, '%d/%b/%Y'));
