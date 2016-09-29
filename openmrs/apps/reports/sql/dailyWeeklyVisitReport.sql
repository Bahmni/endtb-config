SELECT * FROM  (SELECT
  MAX(IF(visit_info.concept_full_name = 'RETURN VISIT DATE', DATE_FORMAT(visit_info.visitDate, '%d/%b/%Y'), NULL))   AS `Next visit date`,
  MAX(IF(visit_info.concept_full_name !='RETURN VISIT DATE' ,visit_info.reason, NULL ))   AS `Reason for next visit`,
  IFNULL(cf.facility, MAX(IF(pat.name='Registration Facility', reg_facility.concept_full_name, NULL )))   AS `Current Treatment Facility`,
  " "                                                                                       AS `Patient attendence`,
  MAX(IF(pat.name='Registration Number', ppa.value_reference, NULL ))                                                                       AS `Registration Number`,
  pi.identifier                                                                             AS `EMR ID`,
  pn.given_name                                                                             AS `Patient first name`,
  pn.family_name                                                                            AS `Patient last name`,
  MAX(IF(peat.name='telephoneNumber', pa.value, NULL))                                      AS `Phone`,
  floor(datediff(CURDATE(), p.birthdate) / 365)                                             AS  Age,
  p.gender                                                                                  AS `Sex`,
  MAX(IF(misc_info.concept_full_name = 'SERUM POTASSIUM', DATE_FORMAT(misc_info.obs_datetime, '%d/%b/%Y'), NULL))    AS `Date of Last K`,
  MAX(IF(misc_info.concept_full_name = 'SERUM POTASSIUM', misc_info.value, NULL))           AS `Last K`,
  MAX(IF(misc_info.concept_full_name = 'EKG, QTcF Interval', DATE_FORMAT(misc_info.obs_datetime, '%d/%b/%Y'), NULL)) AS `Date of Last QTcF`,
  MAX(IF(misc_info.concept_full_name = 'EKG, QTcF Interval', misc_info.value, NULL))        AS `Last QTcF`,
  MAX(IF(misc_info.concept_full_name = 'Bacteriology, Culture results', DATE_FORMAT(misc_info.obs_datetime, '%d/%b/%Y'), NULL))                             AS `Date of last culture`,
  GROUP_CONCAT(DISTINCT (IF(misc_info.concept_full_name = 'Bacteriology, Culture results', misc_info.value, NULL)))                                    AS `last culture`,
  MAX(IF(misc_info.concept_full_name = 'Weight (kg)', DATE_FORMAT(misc_info.obs_datetime, '%d/%b/%Y'), NULL))        AS `Date of Last Weight`,
  MAX(IF(misc_info.concept_full_name = 'Weight (kg)', misc_info.value, NULL))               AS `Last Weight`,
  MAX(IF(misc_info.concept_full_name = 'Body mass index', DATE_FORMAT(misc_info.obs_datetime, '%d/%b/%Y'), NULL))    AS `Date of Last BMI`,
  MAX(IF(misc_info.concept_full_name = 'Body mass index', misc_info.value, NULL))           AS `Last BMI`,
  " "                                                                                       AS `Comments and Alerts`

FROM
  person_name pn
  JOIN person p ON pn.person_id = p.person_id
  JOIN patient_identifier pi ON  pn.person_id = pi.patient_id
  JOIN patient_program pp ON  pp.patient_id = pi.patient_id and pp.voided = 0
  JOIN episode_patient_program epp ON epp.patient_program_id = pp.patient_program_id
  JOIN episode_encounter ee ON  ee.episode_id = epp.episode_id
  JOIN (
         SELECT
           ee.episode_id,
           o.value_datetime                 AS visitDate,
           cv.concept_full_name,
           COALESCE (answer_concept.concept_short_name, answer_concept.concept_full_name) AS reason
         FROM obs o
           JOIN
           concept_view cv
             ON cv.concept_id = o.concept_id AND o.voided = 0
                AND cv.concept_full_name IN
                    ('RETURN VISIT DATE', 'Followup, Reason for next visit', 'Baseline, Reason for next assessment', 'TI, Reason for next assessment')
           LEFT JOIN
           concept_view answer_concept ON answer_concept.concept_id = o.value_coded
           JOIN
           episode_encounter ee
             ON o.encounter_id = ee.encounter_id
            JOIN (
           SELECT
             ee.episode_id,
             MAX(o.obs_datetime) AS max_date
           FROM obs o
             JOIN
             concept_view cv ON cv.concept_id = o.concept_id AND o.voided = 0 AND
                                cv.concept_full_name IN ('RETURN VISIT DATE')
             JOIN
             episode_encounter ee ON o.encounter_id = ee.encounter_id
           GROUP BY ee.episode_id) innerQuery ON innerQuery.episode_id= ee.episode_id AND innerQuery.max_date= o.obs_datetime
       ) AS visit_info ON visit_info.episode_id = ee.episode_id
      JOIN patient_program_attribute ppa ON  ppa.patient_program_id = pp.patient_program_id AND ppa.voided=0
      JOIN program_attribute_type pat ON ppa.attribute_type_id = pat.program_attribute_type_id
      LEFT JOIN concept_view reg_facility ON reg_facility.concept_id = ppa.value_reference
      LEFT JOIN (
                      SELECT ee.episode_id,
                      COALESCE(answer_concept.concept_full_name, o.value_datetime, o.value_numeric, o.value_text) AS facility
                      FROM   obs o
                      JOIN
                      concept_view cv
                      ON cv.concept_id = o.concept_id AND o.voided=0
                      AND cv.concept_full_name IN ( 'TI, Treatment facility at start', 'Treatment Facility Name' )
                      JOIN
                      concept_view answer_concept ON answer_concept.concept_id = o.value_coded
                      JOIN
                      episode_encounter ee
                      ON o.encounter_id = ee.encounter_id
                     JOIN (
                      SELECT  ee.episode_id,
                      MAX(o.obs_datetime) AS max_date
                      FROM   obs o
                      JOIN
                      concept_view cv ON   cv.concept_id = o.concept_id AND o.voided=0 AND
                      cv.concept_full_name IN ('TI, Treatment facility at start', 'Treatment Facility Name' )
                      JOIN
                      episode_encounter ee  ON  o.encounter_id = ee.encounter_id
                      GROUP  BY ee.episode_id) innerQuery ON ee.episode_id = innerQuery.episode_id AND innerQuery.max_date = o.obs_datetime) AS cf ON cf.episode_id = ee.episode_id
    LEFT JOIN (SELECT
               ee.episode_id,
               o.obs_datetime,
               COALESCE(answer_concept.concept_full_name, o.value_datetime, o.value_numeric, o.value_text) AS value,
               cv.concept_full_name
             FROM obs o
               JOIN
               concept_view cv
                 ON cv.concept_id = o.concept_id AND o.voided = 0
                    AND cv.concept_full_name IN
                        ('SERUM POTASSIUM', 'EKG, QTcF Interval', 'Weight (kg)', 'Body mass index','Bacteriology, Culture results')
               LEFT JOIN
               concept_view answer_concept ON answer_concept.concept_id = o.value_coded
               JOIN
               episode_encounter ee
                 ON o.encounter_id = ee.encounter_id
             JOIN (
               SELECT
                 ee.episode_id,
                 MAX(o.obs_datetime) AS max_date,
                 o.concept_id
               FROM obs o
                 JOIN
                 concept_view cv ON cv.concept_id = o.concept_id AND o.voided = 0 AND
                                    cv.concept_full_name IN
                                    ('SERUM POTASSIUM', 'EKG, QTcF Interval', 'Weight (kg)', 'Body mass index','Bacteriology, Culture results')
                 JOIN
                 episode_encounter ee ON o.encounter_id = ee.encounter_id
               GROUP BY ee.episode_id, cv.concept_id) innerQuery ON innerQuery.episode_id = ee.episode_id AND  innerQuery.max_date = o.obs_datetime AND innerQuery.concept_id = o.concept_id) AS misc_info ON misc_info.episode_id = ee.episode_id

    LEFT JOIN person_attribute pa ON pa.person_id = p.person_id and pa.voided=0
    LEFT JOIN person_attribute_type peat ON peat.person_attribute_type_id = pa.person_attribute_type_id AND peat.name='telephoneNumber'
GROUP BY ee.episode_id) visitReport
WHERE STR_TO_DATE(visitReport.`Next visit date`, '%d/%b/%Y') BETWEEN '#startDate#' AND '#endDate#' order by STR_TO_DATE(visitReport.`Next visit date`, '%d/%b/%Y') ASC;