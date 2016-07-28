SELECT pp.patient_id,
  drug.name,
  outcome.Outcome,
  pp.patient_program_id,
  orders.start_date
FROM patient_program pp
  JOIN program prog ON (pp.program_id = prog.program_id
                        AND prog.name IN ('Basic management unit TB register','Second-line TB treatment register'))
  JOIN episode_patient_program epp ON epp.patient_program_id = pp.patient_program_id
  JOIN episode_encounter ee ON ee.episode_id = epp.episode_id
  JOIN encounter e1 ON e1.encounter_id = ee.encounter_id
  JOIN (select cast(MIN(COALESCE(orders.scheduled_date, orders.date_activated)) AS date) AS start_date,ee.episode_id,orders.order_id from orders
        JOIN episode_encounter ee
        ON ee.encounter_id = orders.encounter_id AND orders.order_action != 'DISCONTINUE' AND orders.voided = 0
        GROUP BY ee.episode_id
      ) orders
      ON (ee.episode_id = orders.episode_id
                  AND orders.start_date>= '#startDate#'
                  AND orders.start_date<= '#endDate#'
                  AND (cast(orders.start_date AS DATE) >= '2015-04-01'))
  JOIN drug_order ON (orders.order_id = drug_order.order_id)
JOIN drug ON (drug_order.drug_inventory_id=drug.drug_id)
INNER JOIN concept_name cn ON drug.concept_id = cn.concept_id AND cn.name IN ('Bedaquiline','Delamanid') AND cn.concept_name_type='FULLY_SPECIFIED' AND drug.retired=0
LEFT JOIN (
SELECT cv2.concept_full_name AS Outcome, o.encounter_id, ee.episode_id FROM obs o
JOIN concept_view cv ON o.concept_id = cv.concept_id
JOIN concept_view cv2 ON o.value_coded = cv2.concept_id
JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
WHERE cv.concept_full_name = 'EOT, Outcome' AND o.voided = 0) outcome
ON outcome.episode_id = ee.episode_id
GROUP BY pp.patient_program_id;