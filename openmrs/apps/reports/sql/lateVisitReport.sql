SELECT
  data.`Registration Number`,
  data.`EMR ID`,
  data.`Patient first name`,
  data.`Patient last name`,
  data.`Phone No`,
  CONCAT_WS(', ', data.patientAddress, data.patientAddressLine2, data.patientDistrict,
            data.patientCountry)                             AS 'Address',
  data.Age,
  data.SEX,
  data.`Current treatment facility` AS 'Current treatment facility',
  data.`Date of last visit`,
  data.`Days since last visit`,
  data.`Next scheduled visit`,
  ' '                                                        AS 'Comment'
FROM
  (SELECT
     o1.person_id,
     GROUP_CONCAT(DISTINCT IF(pat.name = 'Registration Number', ppa.value_reference, NULL)) AS 'Registration Number',
     pi.identifier                                                                          AS 'EMR ID',
     pn.given_name                                                                          AS 'Patient first name',
     pn.family_name                                                                         AS 'Patient last name',
     GROUP_CONCAT(DISTINCT IF(patt.name = 'telephoneNumber', pa.value, NULL))               AS 'Phone No',
     GROUP_CONCAT(DISTINCT IF(patt.name = 'patientAddress', pa.value, NULL))                AS 'patientAddress',
     GROUP_CONCAT(DISTINCT IF(patt.name = 'patientAddressLine2', pa.value, NULL))           AS 'patientAddressLine2',
     GROUP_CONCAT(DISTINCT IF(patt.name = 'patientDistrict', pa.value, NULL))               AS 'patientDistrict',
     GROUP_CONCAT(DISTINCT IF(patt.name = 'patientCountry', pa.value, NULL))                AS 'patientCountry',
     floor(DATEDIFF(now(), p.birthdate) / 365)                                              AS 'Age',
     p.gender                                                                               AS 'SEX',
     GROUP_CONCAT(DISTINCT
                  IF(pat.name = 'Registration Facility', (SELECT COALESCE(concept_short_name, concept_full_name)
                                                          FROM concept_view
                                                          WHERE concept_id = COALESCE(treatment_name.value_coded, ppa.value_reference)), NULL) SEPARATOR
                  ',')                                                                      AS 'Current treatment facility',
     DATE_FORMAT(MAX(DISTINCT (o1.obs_datetime)), '%d-%b-%Y')                                               AS 'Date of last visit',
     DATEDIFF(STR_TO_DATE('#startDate#', '%Y-%m-%d'), MAX(DISTINCT(o1.obs_datetime)))                       AS 'Days since last visit',
      DATE_FORMAT(COALESCE(follow_up_next_visit_obs.value_datetime, baseline_next_visit_obs.value_datetime),
                  '%d-%b-%Y')                                                                AS 'Next scheduled visit',
     epp.patient_program_id
   FROM obs o1
     INNER JOIN episode_encounter ee1 ON ee1.encounter_id = o1.encounter_id AND o1.voided = 0
     INNER JOIN concept_name cn ON cn.concept_id = o1.concept_id AND cn.concept_name_type = 'FULLY_SPECIFIED' AND
                                   cn.name IN ('Followup, Visit Date', 'Baseline, Date of baseline')
     LEFT JOIN
     (SELECT
        o.obs_id,
        o.encounter_id,
        o.person_id,
        o.concept_id,
        o.obs_datetime,
        ee.episode_id
      FROM obs o
        INNER JOIN concept_name cn ON cn.concept_id = o.concept_id AND cn.concept_name_type = 'FULLY_SPECIFIED' AND
                                      cn.name IN ('Followup, Visit Date', 'Baseline, Date of baseline')
        INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id AND o.voided = 0) obsEpisode
       ON o1.person_id = obsEpisode.person_id
          AND obsEpisode.episode_id = ee1.episode_id
          AND o1.obs_datetime < obsEpisode.obs_datetime
     INNER JOIN episode_patient_program epp ON epp.episode_id = ee1.episode_id
     INNER JOIN patient_program_attribute ppa ON ppa.patient_program_id = epp.patient_program_id
     INNER JOIN program_attribute_type pat ON pat.program_attribute_type_id = ppa.attribute_type_id
     INNER JOIN person p ON p.person_id = o1.person_id
     INNER JOIN person_name pn ON p.person_id = pn.person_id
     INNER JOIN patient_identifier pi ON pi.patient_id = p.person_id
     LEFT JOIN person_attribute pa ON pa.person_id = p.person_id AND pa.voided=0
     LEFT JOIN person_attribute_type patt ON patt.person_attribute_type_id = pa.person_attribute_type_id
     LEFT JOIN obs follow_up_next_visit_obs ON follow_up_next_visit_obs.obs_group_id IN (SELECT obs_id FROM obs o WHERE o.obs_group_id = o1.obs_group_id AND o.voided = 0) AND
                                               follow_up_next_visit_obs.voided = 0 AND
                                               follow_up_next_visit_obs.concept_id = (SELECT concept_id FROM concept_name WHERE name = 'RETURN VISIT DATE' AND concept_name_type = 'FULLY_SPECIFIED')
     LEFT JOIN obs baseline_next_visit_obs
       ON baseline_next_visit_obs.obs_group_id = o1.obs_group_id AND baseline_next_visit_obs.voided = 0 AND
          baseline_next_visit_obs.concept_id = (SELECT concept_id FROM concept_name WHERE name = 'RETURN VISIT DATE' AND concept_name_type = 'FULLY_SPECIFIED')
     LEFT JOIN (SELECT
                  treatment_name_obs1.*,
                  ee1.episode_id
                FROM obs treatment_name_obs1
                  INNER JOIN episode_encounter ee1
                    ON ee1.encounter_id = treatment_name_obs1.encounter_id AND treatment_name_obs1.voided = 0
                  INNER JOIN concept_name cn ON cn.concept_id = treatment_name_obs1.concept_id AND
                                                cn.name IN ('TI, Treatment facility at start', 'Treatment Facility Name')
                                                AND cn.concept_name_type = 'FULLY_SPECIFIED'
                  LEFT JOIN (SELECT
                               o.obs_id,
                               o.encounter_id,
                               o.person_id,
                               o.concept_id,
                               o.obs_datetime,
                               ee.episode_id
                             FROM obs o
                               INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id AND o.voided = 0
                               INNER JOIN concept_name cn ON cn.concept_id = o.concept_id AND cn.name IN ('TI, Treatment facility at start', 'Treatment Facility Name')
                                              AND cn.concept_name_type = 'FULLY_SPECIFIED') treatment_name_obs2
                    ON treatment_name_obs2.person_id = treatment_name_obs1.person_id AND
                       treatment_name_obs2.episode_id = ee1.episode_id AND
                       treatment_name_obs1.obs_datetime < treatment_name_obs2.obs_datetime
                WHERE treatment_name_obs2.obs_id IS NULL) treatment_name
       ON treatment_name.person_id = o1.person_id AND treatment_name.episode_id = ee1.episode_id
   WHERE obsEpisode.obs_id IS NULL
   GROUP BY epp.patient_program_id) data
  INNER JOIN patient_program pp on pp.patient_program_id = data.patient_program_id and pp.outcome_concept_id is null
  and pp.voided = 0
WHERE data.`Days since last visit` >= 37;