SELECT  pi.identifier,
drug.name,
prog.name as program_name,
pp.date_enrolled,
ti_date.value_datetime ,
 GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'AE Form, Date of AE onset', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e2.date_created, e2.encounter_datetime), NULL)) SEPARATOR ',') AS 'AE Form, Date of AE onset',
GROUP_CONCAT(DISTINCT(IF(cv.concept_full_name = 'AE Form, AE term comprehensive list', coalesce(o.value_numeric, o.value_boolean, o.value_text, o.value_datetime, answer.concept_short_name, answer.concept_full_name, e2.date_created, e2.encounter_datetime), NULL)) SEPARATOR ',') AS 'AE Form, AE term comprehensive list'
FROM patient_program pp
JOIN program prog ON (pp.program_id = prog.program_id AND prog.name IN ('Basic management unit TB register','Second-line TB treatment register'))
AND cast(pp.date_enrolled AS DATE) <= '#endDate#'  AND (cast(pp.date_completed AS DATE) >= '#startDate#' or  pp.date_completed is NULL)
JOIN episode_patient_program epp ON epp.patient_program_id = pp.patient_program_id
JOIN episode_encounter TI_EN ON TI_EN.episode_id = epp.episode_id
JOIN concept_view ti_date_con on( ti_date_con.concept_full_name='TUBERCULOSIS DRUG TREATMENT START DATE' )
JOIN obs ti_date on (TI_EN.encounter_id=ti_date.encounter_id and ti_date_con.concept_id= ti_date.concept_id)
JOIN episode_encounter ee ON ee.episode_id = epp.episode_id
JOIN encounter e1 ON e1.encounter_id = ee.encounter_id
JOIN orders on e1.encounter_id = orders.encounter_id
JOIN drug_order on (orders.order_id = drug_order.order_id and orders.voided is false)
JOIN drug on (drug_order.drug_inventory_id=drug.drug_id)
JOIN episode_encounter ee2 ON ee2.episode_id = epp.episode_id
Join encounter e2 on (e2.encounter_id=ee2.encounter_id)
JOIN (select encounter_id,obs_id as root_obs_id from obs
WHERE concept_id = (select concept_id from concept_view WHERE concept_full_name = 'Adverse Events Template') and voided is false) obs_en
ON e2.encounter_id = obs_en.encounter_id
JOIN obs o ON o.encounter_id = e2.encounter_id AND o.voided IS FALSE and o.obs_group_id=obs_en.root_obs_id
RIGHT JOIN concept_view cv ON cv.concept_id = o.concept_id
INNER JOIN person_name pat_name ON pat_name.person_id = o.person_id
INNER JOIN person ON person.person_id = o.person_id
INNER JOIN patient_identifier pi ON pi.patient_id = o.person_id
LEFT JOIN encounter_provider ON encounter_provider.encounter_id = o.encounter_id
LEFT JOIN provider ON provider.provider_id = encounter_provider.provider_id
LEFT JOIN person_name pn ON pn.person_id = provider.person_id
LEFT JOIN concept_view answer ON o.value_coded = answer.concept_id
where cv.concept_full_name in ('AE Form, Date of AE onset','AE Form, Date of AE report','AE Form, AE ID number','AE Form, TB drugs suspended due to this AE','AE Form, AE term comprehensive list','AE Form, Other AE term','AE Form, AE Grade','AE Form, AE related test','AE form, other related test','AE Form, AE related test ID','AE Form, AE related test date','AE Form, AE related test value','AE Form, AE review date','AE Form, AE severity at review','AE Form, Is AE an SAE','AE Form, SAE Case Number','AE Form, Date of AE Outcome','AE Form, AE outcome','AE Form, Maximum severity of AE','AE Form, AE related to TB drugs','AE Form, TB drug name','AE Form, Is this TB drug possibly related to AE','AE Form, Final action taken related to TB drug','AE Form, Other causal factors related to AE','AE Form, Non TB drug of other causal factor','AE Form, Comorbidity of other causal factor','AE Form, Other causal factor')
group by obs_en.root_obs_id,drug.drug_id
having
( `AE Form, Date of AE onset` between ti_date.value_datetime and  DATE_ADD(ti_date.value_datetime,INTERVAL 210 DAY)
and
`AE Form, AE term comprehensive list` in('Prolonged QT interval','Hypokalemia','Hearing impairment ','Hypothyroidism','Increased liver enzymes','Optic nerve disorder','Anemia','Platelets decreased','Acute kidney injury','Prolonged (corrected) QT interval', 'Hypokalemia (K ≤ 3.4 mEq/L)', 'Hearing impairment (hearing loss)', 'Hypothyroidism', 'Increased liver enzymes (ALT increased or AST increased (>= 1.1 x ULN))', 'Optic nerve disorder (optic neuritis)', 'Anemia (Hb < 10.5 g/dL)', 'Platelets decreased (< 75,000/mm3)', 'Acute kidney injury (acute renal failure)')
);
