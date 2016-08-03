DELETE FROM global_property
WHERE property IN (
        'endtb.sqlSearch.dataIntegrity'
);

INSERT INTO global_property (`property`, `property_value`, `description`, `uuid`)
VALUES ('endtb.sqlSearch.dataIntegrity',
        'SELECT
         di_rule.rule_name                                                                          AS DQ_COLUMN_TITLE_RULE_NAME,
         ppa.value_reference                                                                        AS DQ_COLUMN_TITLE_TREATMENT_REG_NO,
        CONCAT(pn.given_name, \' \', pn.family_name)                                                AS name,
        pi.identifier                                                                               AS DQ_COLUMN_TITLE_EMR_ID,
        di_result.notes                                                                             AS DQ_COLUMN_TITLE_NOTES,
        \'Edit\'                                                                                    AS DQ_COLUMN_TITLE_ACTION,
        di_result.action_url                                                                        AS forwardUrl,
        p.uuid                                                                                      AS uuid,
        prog.uuid                                                                                   AS programUuid,
        pp.uuid                                                                                     AS enrollment

        FROM dataintegrity_result di_result
        JOIN dataintegrity_rule di_rule ON di_rule.rule_id = di_result.rule_id
        JOIN patient_program pp ON pp.patient_program_id = di_result.patient_program_id
        JOIN person p ON pp.patient_id = p.person_id
        JOIN program prog ON prog.program_id = pp.program_id
        JOIN person_name pn ON pp.patient_id = pn.person_id
        JOIN patient_program_attribute ppa ON pp.patient_program_id = ppa.patient_program_id
        JOIN patient_identifier pi ON pn.person_id = pi.patient_id
        JOIN program_attribute_type pat ON ppa.attribute_type_id = pat.program_attribute_type_id
        WHERE pat.name = \'Registration Number\' AND p.voided = 0 AND pn.voided = 0
        ORDER BY ppa.value_reference ASC
        ',
        'Sql query to get list of results from dataintegrity_rule table',
        uuid()
);