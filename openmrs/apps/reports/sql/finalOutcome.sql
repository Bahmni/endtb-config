SELECT pp.patient_id,
  drug.name,
  outcome.Outcome,
  pp.patient_program_id,
  orders.start_date
FROM patient_program pp
  JOIN episode_patient_program epp ON epp.patient_program_id = pp.patient_program_id and pp.voided = 0
  JOIN episode_encounter ee ON ee.episode_id = epp.episode_id
  JOIN episode_encounter ee2 ON epp.episode_id = ee2.episode_id
  JOIN concept_name cn ON cn.name = 'TI, Has the endTB Observational Study Consent Form been explained and signed' and cn.concept_name_type = 'FULLY_SPECIFIED' and cn.voided =0
  JOIN concept_name answers ON answers.name IN ('Yes, patient has been asked and accepted', 'not possible- patient cannot be asked as dead or lost')  and answers.concept_name_type = 'FULLY_SPECIFIED' and answers.voided =0
  JOIN obs o1 ON o1.concept_id =cn.concept_id
                         and o1.value_coded IN (answers.concept_id)
                         and o1.voided = 0
                         and o1.encounter_id = ee2.encounter_id
  JOIN (SELECT cast(MIN(COALESCE(orders.scheduled_date, orders.date_activated)) AS DATE) AS start_date, ee.episode_id, orders.order_id
        FROM orders
        JOIN concept_name cn ON orders.concept_id = cn.concept_id AND cn.name IN ('Bedaquiline', 'Delamanid') AND cn.concept_name_type = 'FULLY_SPECIFIED'
        JOIN episode_encounter ee ON ee.encounter_id = orders.encounter_id AND orders.order_action != 'DISCONTINUE' AND orders.voided = 0
        GROUP BY ee.episode_id, orders.concept_id
        ORDER BY start_date
      ) orders
      ON (ee.episode_id = orders.episode_id
                  AND orders.start_date>= '#startDate#'
                  AND orders.start_date<= '#endDate#'
                  AND (cast(orders.start_date AS DATE) >= '2015-04-01'))
  JOIN drug_order ON (orders.order_id = drug_order.order_id)
JOIN drug ON (drug_order.drug_inventory_id=drug.drug_id)
LEFT JOIN (SELECT cv2.concept_full_name AS Outcome, o.encounter_id, ee.episode_id FROM obs o
           JOIN concept_view cv ON o.concept_id = cv.concept_id
           JOIN concept_view cv2 ON o.value_coded = cv2.concept_id
           JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
           WHERE cv.concept_full_name = 'EOT, Outcome' AND o.voided = 0) outcome
ON outcome.episode_id = ee.episode_id
GROUP BY pp.patient_program_id;