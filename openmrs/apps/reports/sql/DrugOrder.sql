SELECT
  p.id   AS patientId,  
  p.startDate   AS startDate,
  p.stopDate    AS stopDate,
  p.name        AS drugName

FROM
  (SELECT
     patient_identifier.identifier as id,
     orders.patient_id                                                                            AS patientID,		
     IF(drug_order.drug_non_coded IS NULL, drug.name, drug_order.drug_non_coded)                       AS name,     
     IF(Date(orders.scheduled_date) IS NULL, Date(orders.date_activated), Date(orders.scheduled_date)) AS startDate,
     IF(Date(orders.date_stopped) IS NULL, Date(orders.auto_expire_date), Date(orders.date_stopped))   AS stopDate

   FROM drug_order
     LEFT JOIN orders ON orders.order_id = drug_order.order_id AND orders.order_action != "DISCONTINUE" AND orders.voided = 0
     LEFT JOIN drug ON drug.drug_id = drug_order.drug_inventory_id AND drug.retired = 0
     LEFT JOIN patient_identifier ON orders.patient_id = patient_identifier.patient_id
  ) p
WHERE
  p.startDate <= "#endDate#"
  AND
  p.startDate >= "#startDate#"
  AND
  (cast(p.startDate AS DATE) >= "2015-04-01");
