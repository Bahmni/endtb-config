select patients_with_drugs.patient_id,drug_name,drug_start_date,treatment_start_date,treatment_end_date,
  eot_outcome,eot_outcome_date, datediff(treatment_end_date,drug_start_date) as numberOfDaysPostTreatmentStarted
from
  (select o.patient_id as patient_id, cn.name as drug_name,
          IF(Date(o.scheduled_date) IS NULL, Date(o.date_activated), Date(o.scheduled_date)) AS drug_start_date
   from drug d
     inner join concept_name cn on d.concept_id = cn.concept_id and cn.name in ('Bedaquiline','Delamanid') and cn.concept_name_type='FULLY_SPECIFIED' and d.retired=0
     inner join drug_order dro on d.drug_id = dro.drug_inventory_id
     inner join orders o on dro.order_id = o.order_id and o.voided=0
   group by o.patient_id) as patients_with_drugs
  LEFT OUTER JOIN
  (select o.person_id as patient_id,MAX(case when cn.name = 'TUBERCULOSIS DRUG TREATMENT START DATE' THEN o.value_datetime END)  as treatment_start_date,
          MAX(case when cn.name = 'EOT, Outcome' THEN outcome.name END)  as eot_outcome,
          MAX(case when cn.name = 'EOT, End of Treatment Outcome date' THEN o.value_datetime END)  as eot_outcome_date,
          MAX(case when cn.name = 'Tuberculosis treatment end date' THEN o.value_datetime END)  as treatment_end_date
   from obs o
     inner join concept_name cn on o.concept_id=cn.concept_id  and o.voided=0 and cn.voided=0 and cn.concept_name_type = 'FULLY_SPECIFIED'
     left outer join concept_name outcome on o.value_coded=outcome.concept_id and outcome.voided=0 and outcome.concept_name_type = 'FULLY_SPECIFIED'
   where cn.name in ('TUBERCULOSIS DRUG TREATMENT START DATE','DATE OF DEATH','EOT, Outcome','EOT, End of Treatment Outcome date','Tuberculosis treatment end date')
   GROUP BY o.person_id) as patients_with_treatment_details on patients_with_drugs.patient_id = patients_with_treatment_details.patient_id
WHERE (cast(drug_start_date AS DATE) >= '2015-04-01');