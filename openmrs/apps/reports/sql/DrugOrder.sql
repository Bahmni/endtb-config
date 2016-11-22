SELECT
  p.patientProgramId        AS patientProgramId,
  p.patient_id as patientID,
  p.startDate AS startDate,
  p.drugName      AS drugName
FROM
  (SELECT
     pp.patient_program_id                                                                             AS patientProgramId,
      pp.patient_id AS patient_id,
     IF(drug_order.drug_non_coded IS NULL, drug.name, drug_order.drug_non_coded)                       AS drugName,
     MIN(IF(Date(orders.scheduled_date) IS NULL, Date(orders.date_activated), Date(orders.scheduled_date))) AS startDate
   FROM
     patient_program pp
     INNER JOIN episode_patient_program epp ON epp.patient_program_id = pp.patient_program_id and pp.voided=0
     INNER JOIN episode_encounter ee ON epp.episode_id = ee.episode_id
     INNER JOIN episode_encounter ee2 ON epp.episode_id = ee2.episode_id
     INNER JOIN orders orders ON ee.encounter_id = orders.encounter_id AND orders.order_action != 'DISCONTINUE' AND orders.voided = 0
     INNER JOIN drug_order drug_order ON orders.order_id = drug_order.order_id
     INNER JOIN drug drug ON drug_order.drug_inventory_id = drug.drug_id AND drug.retired = 0
     INNER JOIN concept_name cn ON cn.name = 'TI, Has the endTB Observational Study Consent Form been explained and signed' and cn.concept_name_type = 'FULLY_SPECIFIED' and cn.voided =0
     INNER JOIN concept_name answers ON answers.name IN ('Yes, patient has been asked and accepted', 'not possible- patient cannot be asked as dead or lost')  and answers.concept_name_type = 'FULLY_SPECIFIED' and answers.voided =0
     INNER JOIN obs o ON o.concept_id =cn.concept_id
                         and o.value_coded IN (answers.concept_id)
                         and o.voided = 0
                         and o.encounter_id = ee2.encounter_id
    GROUP BY pp.patient_program_id, drug.name
  ) p
WHERE
  p.startDate <= "#endDate#"
  AND
  p.startDate >= "#startDate#"
  AND
  (cast(p.startDate AS DATE) >= "2015-04-01");
