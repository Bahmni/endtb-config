SELECT
  patient_id,
  patient_program_id,
  COALESCE(MAX(CASE WHEN result = 'Positive for M. tuberculosis'
    THEN 'Positive for M. tuberculosis' END),
           MAX(CASE WHEN result = 'Negative for M. tuberculosis'
             THEN 'Negative for M. tuberculosis' END),
           MAX(CASE WHEN result = 'Contaminated'
             THEN 'Contaminated' END),
           MAX(CASE WHEN result = 'Only positive for other mycobacterium'
             THEN 'Only positive for other mycobacterium' END),
           MAX(CASE WHEN result = 'Other'
             THEN 'Other' END), NULL)                        AS bacteriology_result,
  CAST(COALESCE(MAX(CASE WHEN result = 'Positive for M. tuberculosis'
    THEN numberOfDays END),
                MAX(CASE WHEN result = 'Negative for M. tuberculosis'
                  THEN numberOfDays END),
                MAX(CASE WHEN result = 'Contaminated'
                  THEN numberOfDays END),
                MAX(CASE WHEN result = 'Only positive for other mycobacterium'
                  THEN numberOfDays END),
                MAX(CASE WHEN result = 'Other'
                  THEN numberOfDays END), NULL) AS UNSIGNED) AS numberOfDays
FROM (SELECT
        interim_outcome_results.patient_id,
        interim_outcome_results.patient_program_id,
        CASE WHEN (DATEDIFF(obs_datetime, drug_start_date) >= 167 AND DATEDIFF(obs_datetime, drug_start_date) <= 198)
          THEN result
        ELSE NULL END AS result,
        interim_outcome_results.drug_start_date,
        CASE WHEN (DATEDIFF(obs_datetime, drug_start_date) >= 167 AND DATEDIFF(obs_datetime, drug_start_date) <= 198)
          THEN DATEDIFF(obs_datetime, drug_start_date)
        ELSE NULL END AS numberOfDays
      FROM (SELECT
              pp.patient_program_id,
              pp.patient_id,
              episodes_with_drugs.episode_id,
              drug_start_date,
              treatment_start_date,
              treatment_end_date,
              eot_outcome,
              eot_outcome_date,
              cast(datediff(treatment_end_date, drug_start_date) AS UNSIGNED) AS numberOfDaysPostTreatmentStarted
            FROM
              (SELECT
                 ee.episode_id,
                 cn.name                                           AS drug_name,
                 o.encounter_id,
                 MIN(COALESCE(o.scheduled_date, o.date_activated)) AS drug_start_date
               FROM drug d
                 INNER JOIN concept_name cn
                   ON d.concept_id = cn.concept_id AND cn.name IN ('Bedaquiline', 'Delamanid') AND
                      cn.concept_name_type = 'FULLY_SPECIFIED' AND d.retired = 0
                 INNER JOIN drug_order dro ON d.drug_id = dro.drug_inventory_id
                 INNER JOIN orders o ON dro.order_id = o.order_id AND o.voided = 0 AND o.order_action != 'DISCONTINUE'
                 INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
               GROUP BY ee.episode_id) AS episodes_with_drugs
              JOIN encounter e1 ON e1.encounter_id = episodes_with_drugs.encounter_id
              JOIN episode_encounter ee ON ee.encounter_id = episodes_with_drugs.encounter_id
              JOIN episode_patient_program epp ON ee.episode_id = epp.episode_id AND
                                                  episodes_with_drugs.drug_start_date BETWEEN '#startDate#' AND '#endDate#'
                                                  AND episodes_with_drugs.drug_start_date >= '2015-04-01'
              INNER JOIN patient_program pp ON epp.patient_program_id = pp.patient_program_id and pp.voided = 0
              INNER JOIN episode_encounter ee2 ON epp.episode_id = ee2.episode_id
              INNER JOIN concept_name cn ON cn.name = 'TI, Has the endTB Observational Study Consent Form been explained and signed' and cn.concept_name_type = 'FULLY_SPECIFIED' and cn.voided =0
              INNER JOIN concept_name answers ON answers.name IN ('Yes, patient has been asked and accepted', 'not possible- patient cannot be asked as dead or lost')  and answers.concept_name_type = 'FULLY_SPECIFIED' and answers.voided =0
              INNER JOIN obs o1 ON o1.concept_id =cn.concept_id
                         and o1.value_coded IN (answers.concept_id)
                         and o1.voided = 0
                         and o1.encounter_id = ee2.encounter_id
              LEFT OUTER JOIN
              (SELECT
                 ee.episode_id                AS episode_id,
                 MAX(CASE WHEN cn.name = 'TUBERCULOSIS DRUG TREATMENT START DATE'
                   THEN o.value_datetime END) AS treatment_start_date,
                 MAX(CASE WHEN cn.name = 'EOT, Outcome'
                   THEN outcome.name END)     AS eot_outcome,
                 MAX(CASE WHEN cn.name = 'EOT, End of Treatment Outcome date'
                   THEN o.value_datetime END) AS eot_outcome_date,
                 MAX(CASE WHEN cn.name = 'Tuberculosis treatment end date'
                   THEN o.value_datetime END) AS treatment_end_date
               FROM obs o
                 INNER JOIN concept_name cn ON o.concept_id = cn.concept_id AND o.voided = 0 AND cn.voided = 0 AND
                                               cn.concept_name_type = 'FULLY_SPECIFIED'
                 INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
                 LEFT OUTER JOIN concept_name outcome ON o.value_coded = outcome.concept_id AND outcome.voided = 0 AND
                                                         outcome.concept_name_type = 'FULLY_SPECIFIED'
               WHERE cn.name IN
                     ('TUBERCULOSIS DRUG TREATMENT START DATE', 'DATE OF DEATH', 'EOT, Outcome', 'EOT, End of Treatment Outcome date', 'Tuberculosis treatment end date')
               GROUP BY ee.episode_id) AS patients_with_treatment_details
                ON ee.episode_id = patients_with_treatment_details.episode_id
            GROUP BY pp.patient_program_id) AS interim_outcome_results
        LEFT OUTER JOIN
        (SELECT
           cn.name AS result,
           epp.patient_program_id,
           patient_id,
           obs.obs_datetime
         FROM obs
           JOIN concept_view cv
             ON obs.concept_id = cv.concept_id AND cv.concept_full_name IN ('Bacteriology, Culture results')
           JOIN concept_name cn ON cn.concept_id = obs.value_coded AND obs.voided = 0 AND cn.voided = 0 AND
                                   cn.concept_name_type = 'FULLY_SPECIFIED'
           JOIN episode_encounter ee ON obs.encounter_id = ee.encounter_id
           JOIN episode_patient_program epp ON ee.episode_id = epp.episode_id
           JOIN patient_program pp ON epp.patient_program_id = pp.patient_program_id and pp.voided = 0
        ) AS bacteriology_results
          ON interim_outcome_results.patient_program_id = bacteriology_results.patient_program_id
      WHERE treatment_end_date is NULL or (treatment_end_date > date_add(drug_start_date,INTERVAL 198 DAY))
     ) AS interim_culture_results
GROUP BY patient_program_id;

