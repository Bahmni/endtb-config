select pp.patient_program_id,drug_name,
  episodes_with_drugs.episode_id,drug_start_date,treatment_start_date,treatment_end_date,
  eot_outcome,eot_outcome_date, cast(datediff(treatment_end_date,drug_start_date) as unsigned) as numberOfDaysPostTreatmentStarted
from
  (select ee.episode_id , cn.name as drug_name, o.encounter_id,
                          MIN(IF(Date(o.scheduled_date) IS NULL, Date(o.date_activated), Date(o.scheduled_date))) AS drug_start_date
   from drug d
     inner join concept_name cn on d.concept_id = cn.concept_id and cn.name in ('Bedaquiline','Delamanid') and cn.concept_name_type='FULLY_SPECIFIED' and d.retired=0
     inner join drug_order dro on d.drug_id = dro.drug_inventory_id
     inner join orders o on dro.order_id = o.order_id and o.voided=0 AND o.date_stopped IS NULL AND COALESCE(o.scheduled_date, o.date_activated) >='#startDate#' AND COALESCE(o.scheduled_date, o.date_activated) <= '#endDate#' AND COALESCE(o.scheduled_date, o.date_activated) >='2015-04-01'
     inner join episode_encounter ee  ON ee.encounter_id = o.encounter_id
   group by ee.episode_id) as episodes_with_drugs
  JOIN encounter e1 ON e1.encounter_id = episodes_with_drugs.encounter_id
  JOIN episode_encounter ee ON e1.encounter_id = ee.encounter_id
  JOIN episode_patient_program epp ON ee.episode_id = epp.episode_id
  INNER JOIN patient_program pp on epp.patient_program_id = pp.patient_program_id
  LEFT OUTER JOIN
  (SELECT  ee.episode_id AS episode_id,
           MAX(CASE WHEN cn.name = 'TUBERCULOSIS DRUG TREATMENT START DATE' THEN o.value_datetime END) AS treatment_start_date,
           MAX(CASE WHEN cn.name = 'EOT, Outcome'    THEN outcome.name END)     AS eot_outcome,
           MAX(CASE WHEN cn.name = 'EOT, End of Treatment Outcome date'    THEN o.value_datetime END) AS eot_outcome_date,
           MAX(CASE WHEN cn.name = 'Tuberculosis treatment end date'    THEN o.value_datetime END) AS treatment_end_date
   FROM obs o
     INNER JOIN concept_name cn ON o.concept_id = cn.concept_id AND o.voided = 0 AND cn.voided = 0 AND cn.concept_name_type = 'FULLY_SPECIFIED'
     INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
     LEFT OUTER JOIN concept_name outcome ON o.value_coded = outcome.concept_id AND outcome.voided = 0 AND outcome.concept_name_type = 'FULLY_SPECIFIED'
   WHERE cn.name IN
         ('TUBERCULOSIS DRUG TREATMENT START DATE', 'DATE OF DEATH', 'EOT, Outcome', 'EOT, End of Treatment Outcome date', 'Tuberculosis treatment end date')
   GROUP BY ee.episode_id) as patients_with_treatment_details on ee.episode_id = patients_with_treatment_details.episode_id
 GROUP BY pp.patient_program_id;








