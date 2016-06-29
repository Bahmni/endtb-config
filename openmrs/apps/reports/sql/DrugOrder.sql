SELECT
  p.patientProgramId        AS patientProgramId,
  p.patient_id as patientID,
  p.startDate AS startDate,
  p.drugName      AS drugName,
  p.stopDate  AS stopDate
FROM
  (SELECT
     pp.patient_program_id                                                                             AS patientProgramId,
      pp.patient_id AS patient_id,
     IF(drug_order.drug_non_coded IS NULL, drug.name, drug_order.drug_non_coded)                       AS drugName,
     IF(Date(orders.scheduled_date) IS NULL, Date(orders.date_activated), Date(orders.scheduled_date)) AS startDate,
     IF(Date(orders.date_stopped) IS NULL, Date(orders.auto_expire_date), Date(orders.date_stopped))   AS stopDate
   FROM
     patient_program pp
     INNER JOIN episode_patient_program epp ON epp.patient_program_id = pp.patient_program_id and pp.voided=0
     INNER JOIN episode_encounter ee ON epp.episode_id = ee.episode_id
     INNER JOIN orders orders ON ee.encounter_id = orders.encounter_id AND orders.order_action != 'DISCONTINUE' AND orders.voided = 0
     INNER JOIN drug_order drug_order ON orders.order_id = drug_order.order_id
     INNER JOIN drug drug ON drug_order.drug_inventory_id = drug.drug_id AND drug.retired = 0
  ) p
WHERE
  p.startDate <= "#endDate#"
  AND
  p.startDate >= "#startDate#"
  AND
  (cast(p.startDate AS DATE) >= "2015-04-01");
