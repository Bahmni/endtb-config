DELETE FROM global_property
WHERE property IN (
        'endtb.sqlSearch.dataIntegrity'
);

INSERT INTO global_property (`property`, `property_value`, `description`, `uuid`)
VALUES ('endtb.sqlSearch.dataIntegrity',
        'SELECT DISTINCT
                di_rule.rule_name AS DQ_COLUMN_TITLE_RULE_NAME,
                ppa.value_reference AS DQ_COLUMN_TITLE_TREATMENT_REG_NO,
                CONCAT(pn.given_name, '' '', pn.family_name) AS DQ_COLUMN_TITLE_NAME,
                patient_program_facility.facility AS DQ_COLUMN_TITLE_REG_FACILITY,
                pi.identifier AS DQ_COLUMN_TITLE_EMR_ID,
                di_result.notes AS DQ_COLUMN_TITLE_NOTES,
                ''Edit'' AS DQ_COLUMN_TITLE_ACTION,
                di_result.action_url AS forwardUrl,
                p.uuid AS uuid,
                prog.uuid AS programUuid,
                pp.uuid AS enrollment
            FROM
                dataintegrity_result di_result
                    JOIN
                dataintegrity_rule di_rule ON di_rule.rule_id = di_result.rule_id
                    JOIN
                patient_program pp ON pp.patient_program_id = di_result.patient_program_id
                    JOIN
                episode_patient_program epp ON epp.patient_program_id = pp.patient_program_id
                    JOIN
                person p ON pp.patient_id = p.person_id
                    JOIN
                program prog ON prog.program_id = pp.program_id
                    JOIN
                person_name pn ON pp.patient_id = pn.person_id
                    JOIN
                patient_program_attribute ppa ON pp.patient_program_id = ppa.patient_program_id
                    AND ppa.voided = 0
                    JOIN
                patient_identifier pi ON pn.person_id = pi.patient_id
                    JOIN
                program_attribute_type pat ON ppa.attribute_type_id = pat.program_attribute_type_id
                    LEFT JOIN
                episode_encounter ee ON ee.episode_id = epp.episode_id
                    LEFT JOIN
                    (SELECT DISTINCT COALESCE(MAX(treat_det_coded.concept_full_name), MAX(cv_reg.concept_full_name)) AS facility,
                        epp.patient_program_id
                FROM
                    episode_patient_program epp
                JOIN episode_encounter ee ON ee.episode_id = epp.episode_id
                JOIN concept_view max_date ON max_date.concept_full_name IN (''TI, Treatment facility at start'' , ''Treatment Facility Name'')
                JOIN patient_program_attribute ppa ON epp.patient_program_id = ppa.patient_program_id
                    AND ppa.voided = 0
                JOIN patient_program_attribute ppa2 ON epp.patient_program_id = ppa2.patient_program_id
                    AND ppa2.voided = 0
                JOIN program_attribute_type pat2 ON pat2.name = ''Registration Facility''
                LEFT JOIN concept_view cv_reg ON cv_reg.concept_id = ppa2.value_reference
                    AND ppa2.attribute_type_id = pat2.program_attribute_type_id
                LEFT JOIN obs treat_det ON treat_det.concept_id = max_date.concept_id
                    AND treat_det.voided = 0
                    AND treat_det.encounter_id = ee.encounter_id
                    AND (epp.episode_id , treat_det.obs_datetime) IN (SELECT
                        max_date_ee.episode_id,
                            MAX(max_date.obs_datetime) AS max_obs_datetime
                    FROM
                        obs max_date
                    JOIN episode_encounter max_date_ee ON max_date_ee.encounter_id = max_date.encounter_id
                        AND max_date.voided = 0
                    JOIN concept_view max_date_cv ON max_date_cv.concept_id = max_date.concept_id
                        AND max_date_cv.concept_full_name IN (''TI, Treatment facility at start'' , ''Treatment Facility Name'')
                    GROUP BY max_date_ee.episode_id)
                LEFT JOIN concept_view treat_det_coded ON treat_det.value_coded = treat_det_coded.concept_id
                GROUP BY ppa.value_reference , epp.episode_id) patient_program_facility ON patient_program_facility.patient_program_id = epp.patient_program_id
            WHERE
                pat.name = ''Registration Number''
                    AND p.voided = 0
                    AND pn.voided = 0
            ORDER BY ppa.value_reference , DQ_COLUMN_TITLE_RULE_NAME ASC',
        'Sql query to get list of results from dataintegrity_rule table',
        uuid()
) ;