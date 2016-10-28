SELECT
  pp.patient_program_id,
  drug.name AS drug_name,
  pp.patient_id,
  pp.date_enrolled,
  orders.start_date,
  obs_en.`AE Form, Date of AE onset`,
  obs_en.`AE Form, AE term comprehensive list`
  FROM patient_program pp
  JOIN episode_patient_program epp ON epp.patient_program_id = pp.patient_program_id and pp.voided = 0
  JOIN episode_encounter ee ON ee.episode_id = epp.episode_id
  JOIN (SELECT cast(MIN(COALESCE(orders.scheduled_date, orders.date_activated)) AS DATE ) AS start_date,ee.episode_id,orders.order_id FROM orders
        JOIN episode_encounter ee
        ON ee.encounter_id = orders.encounter_id AND orders.order_action != 'DISCONTINUE' AND orders.voided = 0
        GROUP BY ee.episode_id, orders.concept_id
      ) orders
      ON (ee.episode_id = orders.episode_id
                  AND orders.start_date>= '#startDate#'
                  AND orders.start_date<= '#endDate#'
                  AND (CAST(orders.start_date AS DATE) >= '2015-04-01'))
  JOIN drug_order ON (orders.order_id = drug_order.order_id)
  JOIN drug ON (drug_order.drug_inventory_id=drug.drug_id)
  JOIN episode_encounter ee2 ON ee2.episode_id = epp.episode_id
  LEFT JOIN
  (SELECT root.encounter_id,root.obs_id AS root_obs_id,o.obs_id,root.person_id,
      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'AE Form, Date of AE onset',  o.value_datetime, NULL)) SEPARATOR ',') AS 'AE Form, Date of AE onset',
      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'AE Form, AE term comprehensive list',  COALESCE(answer.concept_short_name, answer.concept_full_name), NULL)) SEPARATOR ',') AS 'AE Form, AE term comprehensive list'
    FROM  obs root,
           concept_view,
           concept_view cv,
           obs o LEFT JOIN
           concept_view answer ON (o.value_coded = answer.concept_id)
    WHERE root.concept_id = concept_view.concept_id
      AND root.voided IS FALSE
      AND concept_view.concept_full_name = 'Adverse Events Template'
      AND root.obs_id =  o.obs_group_id
      AND cv.concept_id=o.concept_id
      AND o.voided IS FALSE
      AND cv.concept_full_name IN  ('AE Form, Date of AE onset', 'AE Form, AE term comprehensive list')
    GROUP BY o.obs_group_id ) obs_en ON (ee2.encounter_id = obs_en.encounter_id AND
                                        (`AE Form, Date of AE onset` BETWEEN orders.start_date AND DATE_ADD(orders.start_date,INTERVAL 210 DAY)
                                         AND `AE Form, AE term comprehensive list` IN('Prolonged QT interval','Hypokalemia','Hearing impairment ','Hypothyroidism','Increased liver enzymes','Optic nerve disorder','Anemia','Platelets decreased','Acute kidney injury','Prolonged (corrected) QT interval', 'Hypokalemia (K ≤ 3.4 mEq/L)', 'Hearing impairment (hearing loss)', 'Hypothyroidism', 'Increased liver enzymes (ALT increased or AST increased (>= 1.1 x ULN))', 'Optic nerve disorder (optic neuritis)', 'Anemia (Hb < 10.5 g/dL)','Platelets Decreased ( < 75000/mm^3 )', 'Acute kidney injury (acute renal failure)', 'Peripheral neuropathy', 'Peripheral neuropathy (neurosensory disorder or paresthesia)')) )
GROUP BY obs_en.root_obs_id, pp.patient_program_id, drug.name;
