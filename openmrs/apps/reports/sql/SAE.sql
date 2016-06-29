SELECT  pp.patient_program_id,
drug.name AS drug_name,
 pp.patient_id,
  pp.date_enrolled,
  orders.start_date,
  obs_en.`SAE Form, Date event became serious`,
  obs_en.`SAE Form, SAE term comprehensive AE list`

  FROM patient_program pp
  JOIN episode_patient_program epp ON epp.patient_program_id = pp.patient_program_id
  JOIN episode_encounter ee ON ee.episode_id = epp.episode_id
  JOIN encounter e1 ON e1.encounter_id = ee.encounter_id
  JOIN (select cast(COALESCE(orders.scheduled_date, orders.date_activated) AS date) AS start_date,orders.encounter_id,orders.order_id,orders.voided from orders) orders
      ON (e1.encounter_id = orders.encounter_id
                  AND orders.start_date>= '#startDate#'
                  AND orders.start_date<= '#endDate#'
                  AND (cast(orders.start_date AS DATE) >= "2015-04-01"))
  JOIN drug_order ON (orders.order_id = drug_order.order_id
                      AND orders.voided IS FALSE)
  JOIN drug ON (drug_order.drug_inventory_id=drug.drug_id)
  JOIN episode_encounter ee2 ON ee2.episode_id = epp.episode_id
  JOIN encounter e2 ON (e2.encounter_id=ee2.encounter_id)
  LEFT JOIN
  (select root.encounter_id,root.obs_id as root_obs_id,o.obs_id,root.person_id,
      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'SAE Form, Date event became serious',  o.value_datetime, NULL)) SEPARATOR ',') AS 'SAE Form, Date event became serious',
      GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'SAE Form, SAE term comprehensive AE list',  coalesce(answer.concept_short_name, answer.concept_full_name), NULL)) SEPARATOR ',') AS 'SAE Form, SAE term comprehensive AE list'
    from  obs root,
           concept_view,
           concept_view cv,
           obs o LEFT JOIN
           concept_view answer on (o.value_coded = answer.concept_id)
    WHERE root.concept_id = concept_view.concept_id
      and root.voided is false
      and concept_view.concept_full_name = 'Serious Adverse Events Template'
      and root.obs_id =  o.obs_group_id
      and cv.concept_id=o.concept_id
      and o.voided is false
      and cv.concept_full_name in  ('SAE Form, Date event became serious', 'SAE Form, SAE term comprehensive AE list')
    group by o.obs_group_id ) obs_en ON (e2.encounter_id = obs_en.encounter_id and
                                        (`SAE Form, Date event became serious` BETWEEN orders.start_date AND DATE_ADD(orders.start_date,INTERVAL 210 DAY)
                                         ) ) GROUP BY obs_en.root_obs_id,pp.patient_program_id,drug.name;

