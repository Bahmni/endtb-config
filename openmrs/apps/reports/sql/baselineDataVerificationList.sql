select * from (select
                 MAX(IF(pat.name='Registration Number', ppa.value_reference, NULL )) AS `Registration Number`,
                 pi.identifier AS `EMR ID`,
                 pn.family_name AS `Patient Last name`,
                 pn.given_name AS `Patient First name`,
                 MIN((IF (conceptObs.name='TUBERCULOSIS DRUG TREATMENT START DATE', DATE_FORMAT(conceptObs.value_datetime,'%d/%b/%Y'), NULL ))) AS 'Start ttr Date',
                 DATE_FORMAT(ddDlm.dlm_start_date, '%d/%b/%Y') as 'Dlm Start Date',
                 ddDlm.dlm_duration as 'Dlm Duration',
                 DATE_FORMAT(ddBdq.bdq_start_date, '%d/%b/%Y') as 'Bdq Start Date',
                 ddBdq.bdq_duration as 'Bdq Duration',
                 GROUP_CONCAT(IF(conceptObs.name = 'TI, Has the Treatment with New Drugs Consent Form been explained and signed',conceptObs.concept_short_name,NULL) SEPARATOR ',') as 'Consent for new drugs',
                 GROUP_CONCAT(IF(conceptObs.name = 'TI, Has the endTB Observational Study Consent Form been explained and signed',conceptObs.concept_short_name,NULL) SEPARATOR ',') as 'Consent for endtb study',
                 GROUP_CONCAT(IF(conceptObs.name = 'Baseline, Date of baseline',DATE_FORMAT(conceptObs.value_datetime, '%d/%b/%Y'),NULL) SEPARATOR ',') as 'Date of baseline assessment',
                 GROUP_CONCAT(IF(conceptObs.name = 'Baseline, HIV serostatus result',conceptObs.concept_full_name,NULL) SEPARATOR ',') as 'HIV Baseline',
                 GROUP_CONCAT(IF(conceptObs.name = 'Lab, HIV test result',conceptObs.concept_full_name,NULL)  SEPARATOR ',') as 'Lab HIV',
                 GROUP_CONCAT(IF(conceptObs.name = 'CD4 COUNT' and conceptObs.obs_group_id =  bCD4Obs.obs_id,conceptObs.value_numeric,NULL)  SEPARATOR ',') as 'CD4 Baseline',
                 GROUP_CONCAT(IF(conceptObs.name = 'CD4 COUNT' and conceptObs.obs_group_id =  lCD4Obs.obs_id,conceptObs.value_numeric,NULL) SEPARATOR ',')  as 'Lab CD4',
                 GROUP_CONCAT(IF(conceptObs.name = 'HIV VIRAL LOAD'and conceptObs.obs_group_id = bvObs.obs_id,conceptObs.value_numeric,NULL) SEPARATOR ',')  as 'HIV VL Baseline',
                 GROUP_CONCAT(IF(conceptObs.name = 'HIV VIRAL LOAD'and conceptObs.obs_group_id = lvObs.obs_id,conceptObs.value_numeric,NULL) SEPARATOR ',')  as 'HIV VL LAB',
                 GROUP_CONCAT(IF(conceptObs.name = 'Baseline, Hepatitis B',conceptObs.concept_short_name,NULL) SEPARATOR ',') as 'Baseline Hepatitis B',
                 GROUP_CONCAT(IF(conceptObs.name = 'Lab, Hepatitis B antigen test result',conceptObs.concept_full_name,NULL) SEPARATOR ',')  as 'Lab Hepatitis B',
                 GROUP_CONCAT(IF(conceptObs.name = 'Baseline, Hepatitis C',conceptObs.concept_short_name,NULL)  SEPARATOR ',') as 'Baseline Hepatitis C',
                 GROUP_CONCAT(IF(conceptObs.name = 'Lab, Hepatitis C antibody test result',conceptObs.concept_full_name,NULL) SEPARATOR ',')  as 'Lab Hepatitis C',
                 GROUP_CONCAT(IF(conceptObs.name = 'Diabetes Mellitus',conceptObs.concept_short_name,NULL) SEPARATOR ',')  as 'Baseline Diabetes',
                 GROUP_CONCAT(IF(conceptObs.name = 'glycosylated hemoglobin A measurement' and conceptObs.obs_group_id = bgObs.obs_id,conceptObs.value_numeric,NULL) SEPARATOR ',')  as 'Baseline HbA1c',
                 GROUP_CONCAT(IF(conceptObs.name = 'glycosylated hemoglobin A measurement'and conceptObs.obs_group_id = lgObs.obs_id,conceptObs.value_numeric,NULL) SEPARATOR ',')  as 'Lab HbA1c',
                 GROUP_CONCAT(IF(conceptObs.name = 'Baseline, Date of baseline physical examination',DATE_FORMAT(conceptObs.value_datetime, '%d/%b/%Y'),NULL) SEPARATOR ',')  as 'Date of Baseline Physical Assessment',
                 GROUP_CONCAT(IF(conceptObs.name = 'Weight (kg)' and conceptObs.obs_group_id = bcObs.obs_id,conceptObs.value_numeric,NULL) SEPARATOR ',')  as 'Weight',
                 GROUP_CONCAT(IF(conceptObs.name = 'Respiratory Rate' and conceptObs.obs_group_id = bcObs.obs_id,conceptObs.value_numeric,NULL)  SEPARATOR ',') as 'Respiration Rate',
                 GROUP_CONCAT(IF(conceptObs.name = 'Baseline, Colorblindness Screen Result',conceptObs.concept_full_name,NULL) SEPARATOR ',')  as 'Colour Blindness',
                 GROUP_CONCAT(IF(conceptObs.name = 'Visual acuity, left eye' and conceptObs.obs_group_id = baObs.obs_id,conceptObs.value_numeric,NULL) SEPARATOR ',')  as 'Visual acuity, left eye',
                 GROUP_CONCAT(IF(conceptObs.name = 'Visual acuity, right eye' and conceptObs.obs_group_id = baObs.obs_id,conceptObs.value_numeric,NULL) SEPARATOR ',')  as 'Visual acuity, right eye',
                 GROUP_CONCAT(IF(conceptObs.name = 'Baseline, Pain Aching or Buring in Left Feet and Leg' and conceptObs.obs_group_id = bnlObs.obs_id,conceptObs.concept_full_name,NULL) SEPARATOR ',')  as 'BPNS LEFT pain, ache, burning',
                 GROUP_CONCAT(IF(conceptObs.name = 'Baseline, Pain Aching or Buring in Right Feet and Leg' and conceptObs.obs_group_id = bnrObs.obs_id,conceptObs.concept_full_name,NULL) SEPARATOR ',')  as 'BPNS RIGHT pain, ache, burning'
               from
                 program
                 INNER join patient_program pp on pp.program_id = program.program_id and  program.name = 'Second-line TB treatment register'
                 INNER JOIN episode_patient_program epp on epp.patient_program_id=pp.patient_program_id
                 INNER JOIN patient_program_attribute ppa ON ppa.patient_program_id=epp.patient_program_id
                 INNER JOIN program_attribute_type pat ON pat.program_attribute_type_id=ppa.attribute_type_id AND pat.name='Registration Number'
                 INNER JOIN patient_identifier pi ON pi.patient_id = pp.patient_id
                 INNER JOIN person_name pn ON pn.person_id = pp.patient_id
                 INNER JOIN person p ON p.person_id = pp.patient_id and p.voided = 0
                 INNER JOIN episode_encounter ee on ee.episode_id = epp.episode_id
                 LEFT JOIN ( select name as name,obs_group_id,value_coded,value_datetime,value_numeric,concept_full_name,concept_short_name,encounter_id from obs
                 JOIN concept_name cn on obs.concept_id = cn.concept_id and cn.voided= 0
                                         and cn.concept_name_type = 'FULLY_SPECIFIED' and obs.voided=0
                 LEFT JOIN concept_view answer on obs.value_coded = answer.concept_id
                           ) conceptObs
                   on conceptObs.encounter_id = ee.encounter_id
                 LEFT JOIN
                 ( select
                     obs.obs_id,encounter_id
                   from obs
                     JOIN concept_name cn on obs.concept_id = cn.concept_id and cn.voided= 0
                                             and cn.concept_name_type = 'FULLY_SPECIFIED' and obs.voided=0
                                             and cn.name in ('Baseline, HIV Viral Load Details')
                 ) bvObs on  ee.encounter_id = bvObs.encounter_id and conceptObs.obs_group_id = bvObs.obs_id
                 LEFT JOIN
                 ( select
                     obs.obs_id,encounter_id
                   from obs
                     JOIN concept_name cn on obs.concept_id = cn.concept_id and cn.voided= 0
                                             and cn.concept_name_type = 'FULLY_SPECIFIED' and obs.voided=0
                                             and cn.name in ('Lab, Serological and other tests')
                 ) lvObs on  ee.encounter_id = lvObs.encounter_id and conceptObs.obs_group_id = lvObs.obs_id
                 LEFT JOIN
                 ( select
                     obs.obs_id,encounter_id
                   from obs
                     JOIN concept_name cn on obs.concept_id = cn.concept_id and cn.voided= 0
                                             and cn.concept_name_type = 'FULLY_SPECIFIED' and obs.voided=0
                                             and cn.name in ('Baseline, CD4 count details')
                 ) bCD4Obs on  ee.encounter_id = bCD4Obs.encounter_id and conceptObs.obs_group_id = bCD4Obs.obs_id
                 LEFT JOIN
                 ( select
                     obs.obs_id,encounter_id
                   from obs
                     JOIN concept_name cn on obs.concept_id = cn.concept_id and cn.voided= 0
                                             and cn.concept_name_type = 'FULLY_SPECIFIED' and obs.voided=0
                                             and cn.name in ('Lab, CD4 COUNT Data')
                 ) lCD4Obs on  ee.encounter_id = lCD4Obs.encounter_id and conceptObs.obs_group_id = lCD4Obs.obs_id
                 LEFT JOIN
                 ( select
                     obs.obs_id,encounter_id
                   from obs
                     JOIN concept_name cn on obs.concept_id = cn.concept_id and cn.voided= 0
                                             and cn.concept_name_type = 'FULLY_SPECIFIED' and obs.voided=0
                                             and cn.name in ('Baseline, Chronic Diseases')
                 ) bgObs on  ee.encounter_id = bgObs.encounter_id and conceptObs.obs_group_id = bgObs.obs_id
                 LEFT JOIN
                 ( select
                     obs.obs_id,encounter_id
                   from obs
                     JOIN concept_name cn on obs.concept_id = cn.concept_id and cn.voided= 0
                                             and cn.concept_name_type = 'FULLY_SPECIFIED' and obs.voided=0
                                             and cn.name in ('Lab, glycosylated hemoglobin A measurement Data')
                 ) lgObs on  ee.encounter_id = lgObs.encounter_id and conceptObs.obs_group_id = lgObs.obs_id

                 LEFT JOIN
                 ( select
                     obs.obs_id,encounter_id
                   from obs
                     JOIN concept_name cn on obs.concept_id = cn.concept_id and cn.voided= 0
                                             and cn.concept_name_type = 'FULLY_SPECIFIED' and obs.voided=0
                                             and cn.name in ('Baseline, Clinical Examination')
                 ) bcObs on  ee.encounter_id = bcObs.encounter_id and conceptObs.obs_group_id = bcObs.obs_id

                 LEFT JOIN
                 ( select
                     obs.obs_id,encounter_id
                   from obs
                     JOIN concept_name cn on obs.concept_id = cn.concept_id and cn.voided= 0
                                             and cn.concept_name_type = 'FULLY_SPECIFIED' and obs.voided=0
                                             and cn.name in ('Baseline, Visual Acuity')
                 ) baObs on  ee.encounter_id = baObs.encounter_id and conceptObs.obs_group_id = baObs.obs_id

                 LEFT JOIN
                 ( select
                     obs.obs_id,encounter_id
                   from obs
                     JOIN concept_name cn on obs.concept_id = cn.concept_id and cn.voided= 0
                                             and cn.concept_name_type = 'FULLY_SPECIFIED' and obs.voided=0
                                             and cn.name in ('Baseline, Brief peripheral neuropathy screen in left')
                 ) bnlObs on  ee.encounter_id = bnlObs.encounter_id and conceptObs.obs_group_id = bnlObs.obs_id
                 LEFT JOIN
                 ( select
                     obs.obs_id,encounter_id
                   from obs
                     JOIN concept_name cn on obs.concept_id = cn.concept_id and cn.voided= 0
                                             and cn.concept_name_type = 'FULLY_SPECIFIED' and obs.voided=0
                                             and cn.name in ('Baseline, Brief peripheral neuropathy screen in right')
                 ) bnrObs on  ee.encounter_id = bnrObs.encounter_id and conceptObs.obs_group_id = bnrObs.obs_id

                 LEFT JOIN (
                             SELECT MIN(o.scheduled_date) AS bdq_start_date, ee.episode_id,
                                    SUM(TIMESTAMPDIFF(DAY,COALESCE(o.scheduled_date,o.date_activated),COALESCE(o.date_stopped,NOW())))/30 AS bdq_duration
                             FROM episode_encounter ee,
                               orders o,
                               drug d,
                               drug_order do
                             WHERE o.order_id = do.order_id
                                   AND ee.encounter_id = o.encounter_id
                                   AND d.drug_id = do.drug_inventory_id
                                   AND o.voided = 0 AND o.order_action='NEW'
                                   AND o.scheduled_date <= NOW()
                                   AND d.name IN ( 'Bedaquiline (Bdq)')
                             GROUP BY ee.episode_id
                           ) ddBdq ON (ddBdq.episode_id = ee.episode_id)

                 LEFT JOIN (
                             SELECT MIN(o.scheduled_date) AS dlm_start_date, ee.episode_id,
                                    SUM(TIMESTAMPDIFF(DAY,COALESCE(o.scheduled_date,o.date_activated),COALESCE(o.date_stopped,NOW())))/30 AS dlm_duration
                             FROM episode_encounter ee,
                               orders o,
                               drug d,
                               drug_order do
                             WHERE o.order_id = do.order_id
                                   AND ee.encounter_id = o.encounter_id
                                   AND d.drug_id = do.drug_inventory_id
                                   AND o.voided = 0 AND o.order_action='NEW'
                                   AND o.scheduled_date <= NOW()
                                   AND d.name IN ('Delamanid (Dlm)')
                             GROUP BY ee.episode_id
                           ) ddDlm ON (ddDlm.episode_id = ee.episode_id)
               GROUP BY pp.patient_program_id) t1 where STR_TO_DATE(t1.`Start ttr Date`, '%d/%b/%Y') BETWEEN '#startDate#' and '#endDate#';
