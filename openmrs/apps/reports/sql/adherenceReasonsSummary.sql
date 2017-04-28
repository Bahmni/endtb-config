SELECT
	registration_number.value_reference AS `Registration Number`,
	pi.identifier AS `EMR ID`,
	DATE_FORMAT(
		adherence_data.obs_datetime,
		'%b/%Y'
	) AS 'Adherence Data Month',
	DATE_FORMAT(
		treatment_start_date.value_datetime,
		'%d/%b/%Y'
	) AS 'Treatment Start Date',
	ROUND(
		TIMESTAMPDIFF(
			DAY,
			treatment_start_date.value_datetime,
			LAST_DAY(
				adherence_data.obs_datetime
			)
		) / 30.5,
		1
	) AS 'Treatment Duration',
	DATE_FORMAT(
		treatment_end_date.value_datetime,
		'%d/%b/%Y'
	) AS 'Treatment End Date',
	COALESCE (
		treatment_facility. NAME,
		registration_facility.concept_full_name
	) AS 'Current Treatment Facility',
	mtc_completeness_rate.value_numeric AS 'Completeness Rate',
	mtc_adherence_rate.value_numeric AS 'Adherence Rate',
	mtc_overall_dot_rate.value_numeric AS 'DOT Rate',
	mtc_ideal_ttr_days.value_numeric AS 'Ideal Ttr days',
	mtc_non_prescr_days.value_numeric AS 'Non Prescr. days',
	mtc_missed_prescr_days.value_numeric AS 'Missed days',
	mtc_incomplete_prescr_days.value_numeric AS 'Uncompl. days',
	mtc_principal_reason.concept_full_name AS 'Principal reason for < 100 incomplete',
	COALESCE (
		mtc_principal_program_reason.concept_full_name,
		mtc_principal_medical_reason.concept_full_name,
		mtc_principal_patient_reason.concept_full_name,
		mtc_principal_other_reason.value_text
	) AS 'Detailed reasons for < 100% completeness',
	mtc_additional_reason.reasons AS 'Additional reasons for < 100% completeness',
	CONCAT_WS(
		', ',
		mtc_additional_program_reason.reasons,
		mtc_additional_medical_reason.reasons,
		mtc_additional_patient_reason.reasons,
		mtc_additional_other_reason.value_text
	) AS 'Additional  detailed reasons for < 100% completeness'
FROM
	patient_identifier pi
INNER JOIN patient_program pp ON pp.patient_id = pi.patient_id
INNER JOIN episode_patient_program epp ON epp.patient_program_id = pp.patient_program_id
INNER JOIN (
	SELECT
		ppa.patient_program_id,
		ppa.value_reference
	FROM
		patient_program_attribute ppa
	INNER JOIN program_attribute_type pat ON pat.program_attribute_type_id = ppa.attribute_type_id
	AND ppa.voided IS FALSE
	AND pat. NAME = 'Registration Number'
) registration_number ON registration_number.patient_program_id = pp.patient_program_id
INNER JOIN (
	SELECT
		ee.episode_id,
		o.obs_group_id,
		o.obs_datetime
	FROM
		obs o
	INNER JOIN concept_view cv ON cv.concept_id = o.concept_id
	AND o.voided IS FALSE
	AND cv.concept_full_name = 'MTC, Month and year of treatment period'
	INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
) adherence_data ON adherence_data.episode_id = epp.episode_id
LEFT OUTER JOIN (
	SELECT
		ee.episode_id,
		o.value_datetime
	FROM
		obs o
	INNER JOIN concept_view cv ON cv.concept_id = o.concept_id
	AND o.voided IS FALSE
	AND cv.concept_full_name = 'TUBERCULOSIS DRUG TREATMENT START DATE'
	INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
) treatment_start_date ON treatment_start_date.episode_id = epp.episode_id
LEFT OUTER JOIN (
	SELECT
		ee.episode_id,
		o.value_datetime
	FROM
		obs o
	INNER JOIN concept_view cv ON cv.concept_id = o.concept_id
	AND o.voided IS FALSE
	AND cv.concept_full_name = 'Tuberculosis treatment end date'
	INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
) treatment_end_date ON treatment_end_date.episode_id = epp.episode_id
LEFT OUTER JOIN (
	SELECT
		ppa.patient_program_id,
		cv.concept_full_name
	FROM
		patient_program_attribute ppa
	INNER JOIN program_attribute_type pat ON pat.program_attribute_type_id = ppa.attribute_type_id
	AND ppa.voided IS FALSE
	AND pat. NAME = 'Registration Facility'
	INNER JOIN concept_view cv ON cv.concept_id = ppa.value_reference
) registration_facility ON registration_facility.patient_program_id = pp.patient_program_id
LEFT OUTER JOIN (
	SELECT
		episode_id,
		SUBSTRING(
			latest_obs,
			INSTR(latest_obs, '||') + 2
		) AS 'name'
	FROM
		(
			SELECT
				ee.episode_id,
				MAX(
					CONCAT(
						o.obs_datetime,
						o.obs_id,
						'||',
						cv_value.concept_full_name
					)
				) AS latest_obs
			FROM
				obs o
			INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
			AND o.voided IS FALSE
			INNER JOIN concept_view cv ON cv.concept_id = o.concept_id
			AND cv.concept_full_name IN (
				'TI, Treatment facility at start',
				'Treatment Facility Name'
			)
			INNER JOIN concept_view cv_value ON o.value_coded = cv_value.concept_id
			GROUP BY
				ee.episode_id
			ORDER BY
				ee.episode_id
		) latest_treatment_facility
) treatment_facility ON treatment_facility.episode_id = epp.episode_id
LEFT OUTER JOIN (
	SELECT
		ee.episode_id,
		parentobs.obs_group_id,
		o.obs_datetime,
		o.value_numeric
	FROM
		obs o
	INNER JOIN obs parentobs ON parentobs.obs_id = o.obs_group_id
	INNER JOIN concept_view cv ON cv.concept_id = o.concept_id
	AND o.voided IS FALSE
	AND cv.concept_full_name = 'MTC, Completeness rate'
	INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
) mtc_completeness_rate ON mtc_completeness_rate.episode_id = epp.episode_id
AND mtc_completeness_rate.obs_datetime = adherence_data.obs_datetime
AND mtc_completeness_rate.obs_group_id = adherence_data.obs_group_id
LEFT OUTER JOIN (
	SELECT
		ee.episode_id,
		parentobs.obs_group_id,
		o.obs_datetime,
		o.value_numeric
	FROM
		obs o
	INNER JOIN obs parentobs ON parentobs.obs_id = o.obs_group_id
	INNER JOIN concept_view cv ON cv.concept_id = o.concept_id
	AND o.voided IS FALSE
	AND cv.concept_full_name = 'MTC, Adherence rate'
	INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
) mtc_adherence_rate ON mtc_adherence_rate.episode_id = epp.episode_id
AND mtc_adherence_rate.obs_datetime = adherence_data.obs_datetime
AND mtc_adherence_rate.obs_group_id = adherence_data.obs_group_id
LEFT OUTER JOIN (
	SELECT
		ee.episode_id,
		o.obs_group_id,
		o.obs_datetime,
		o.value_numeric
	FROM
		obs o
	INNER JOIN concept_view cv ON cv.concept_id = o.concept_id
	AND o.voided IS FALSE
	AND cv.concept_full_name = 'MTC, Overall DOT Rate'
	INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
) mtc_overall_dot_rate ON mtc_overall_dot_rate.episode_id = epp.episode_id
AND mtc_overall_dot_rate.obs_datetime = adherence_data.obs_datetime
AND mtc_overall_dot_rate.obs_group_id = adherence_data.obs_group_id
LEFT OUTER JOIN (
	SELECT
		ee.episode_id,
		o.obs_group_id,
		o.obs_datetime,
		o.value_numeric
	FROM
		obs o
	INNER JOIN concept_view cv ON cv.concept_id = o.concept_id
	AND o.voided IS FALSE
	AND cv.concept_full_name = 'MTC, Ideal total treatment days in the month'
	INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
) mtc_ideal_ttr_days ON mtc_ideal_ttr_days.episode_id = epp.episode_id
AND mtc_ideal_ttr_days.obs_datetime = adherence_data.obs_datetime
AND mtc_ideal_ttr_days.obs_group_id = adherence_data.obs_group_id
LEFT OUTER JOIN (
	SELECT
		ee.episode_id,
		o.obs_group_id,
		o.obs_datetime,
		o.value_numeric
	FROM
		obs o
	INNER JOIN concept_view cv ON cv.concept_id = o.concept_id
	AND o.voided IS FALSE
	AND cv.concept_full_name = 'MTC, Non prescribed days'
	INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
) mtc_non_prescr_days ON mtc_non_prescr_days.episode_id = epp.episode_id
AND mtc_non_prescr_days.obs_datetime = adherence_data.obs_datetime
AND mtc_non_prescr_days.obs_group_id = adherence_data.obs_group_id
LEFT OUTER JOIN (
	SELECT
		ee.episode_id,
		o.obs_group_id,
		o.obs_datetime,
		o.value_numeric
	FROM
		obs o
	INNER JOIN concept_view cv ON cv.concept_id = o.concept_id
	AND o.voided IS FALSE
	AND cv.concept_full_name = 'MTC, Missed prescribed days'
	INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
) mtc_missed_prescr_days ON mtc_missed_prescr_days.episode_id = epp.episode_id
AND mtc_missed_prescr_days.obs_datetime = adherence_data.obs_datetime
AND mtc_missed_prescr_days.obs_group_id = adherence_data.obs_group_id
LEFT OUTER JOIN (
	SELECT
		ee.episode_id,
		o.obs_group_id,
		o.obs_datetime,
		o.value_numeric
	FROM
		obs o
	INNER JOIN concept_view cv ON cv.concept_id = o.concept_id
	AND o.voided IS FALSE
	AND cv.concept_full_name = 'MTC, Incomplete prescribed days'
	INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
) mtc_incomplete_prescr_days ON mtc_incomplete_prescr_days.episode_id = epp.episode_id
AND mtc_incomplete_prescr_days.obs_datetime = adherence_data.obs_datetime
AND mtc_incomplete_prescr_days.obs_group_id = adherence_data.obs_group_id
LEFT OUTER JOIN (
	SELECT
		ee.episode_id,
		parentobs.obs_group_id,
		o.obs_datetime,
		cv_value.concept_full_name
	FROM
		obs o
	INNER JOIN obs parentobs ON parentobs.obs_id = o.obs_group_id
	INNER JOIN concept_view cv ON cv.concept_id = o.concept_id
	AND o.voided IS FALSE
	AND cv.concept_full_name = 'MTC, Principal reason for treatment incomplete'
	INNER JOIN concept_view cv_value ON cv_value.concept_id = o.value_coded
	INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
) mtc_principal_reason ON mtc_principal_reason.episode_id = epp.episode_id
AND mtc_principal_reason.obs_datetime = adherence_data.obs_datetime
AND mtc_principal_reason.obs_group_id = adherence_data.obs_group_id
LEFT OUTER JOIN (
	SELECT
		ee.episode_id,
		parentobs.obs_group_id,
		o.obs_datetime,
		cv_value.concept_full_name
	FROM
		obs o
	INNER JOIN obs parentobs ON parentobs.obs_id = o.obs_group_id
	INNER JOIN concept_view cv ON cv.concept_id = o.concept_id
	AND o.voided IS FALSE
	AND cv.concept_full_name = 'MTC, Detailed program related reason'
	INNER JOIN concept_view cv_value ON cv_value.concept_id = o.value_coded
	INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
) mtc_principal_program_reason ON mtc_principal_program_reason.episode_id = epp.episode_id
AND mtc_principal_program_reason.obs_datetime = adherence_data.obs_datetime
AND mtc_principal_program_reason.obs_group_id = adherence_data.obs_group_id
LEFT OUTER JOIN (
	SELECT
		ee.episode_id,
		parentobs.obs_group_id,
		o.obs_datetime,
		cv_value.concept_full_name
	FROM
		obs o
	INNER JOIN obs parentobs ON parentobs.obs_id = o.obs_group_id
	INNER JOIN concept_view cv ON cv.concept_id = o.concept_id
	AND o.voided IS FALSE
	AND cv.concept_full_name = 'MTC, Detailed medical related reason'
	INNER JOIN concept_view cv_value ON cv_value.concept_id = o.value_coded
	INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
) mtc_principal_medical_reason ON mtc_principal_medical_reason.episode_id = epp.episode_id
AND mtc_principal_medical_reason.obs_datetime = adherence_data.obs_datetime
AND mtc_principal_medical_reason.obs_group_id = adherence_data.obs_group_id
LEFT OUTER JOIN (
	SELECT
		ee.episode_id,
		parentobs.obs_group_id,
		o.obs_datetime,
		cv_value.concept_full_name
	FROM
		obs o
	INNER JOIN obs parentobs ON parentobs.obs_id = o.obs_group_id
	INNER JOIN concept_view cv ON cv.concept_id = o.concept_id
	AND o.voided IS FALSE
	AND cv.concept_full_name = 'MTC, Detailed patient related reason'
	INNER JOIN concept_view cv_value ON cv_value.concept_id = o.value_coded
	INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
) mtc_principal_patient_reason ON mtc_principal_patient_reason.episode_id = epp.episode_id
AND mtc_principal_patient_reason.obs_datetime = adherence_data.obs_datetime
AND mtc_principal_patient_reason.obs_group_id = adherence_data.obs_group_id
LEFT OUTER JOIN (
	SELECT
		ee.episode_id,
		parentobs.obs_group_id,
		o.obs_datetime,
		o.value_text
	FROM
		obs o
	INNER JOIN obs parentobs ON parentobs.obs_id = o.obs_group_id
	INNER JOIN concept_view cv ON cv.concept_id = o.concept_id
	AND o.voided IS FALSE
	AND cv.concept_full_name = 'MTC, Other reason for treatment incomplete'
	INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
) mtc_principal_other_reason ON mtc_principal_other_reason.episode_id = epp.episode_id
AND mtc_principal_other_reason.obs_datetime = adherence_data.obs_datetime
AND mtc_principal_other_reason.obs_group_id = adherence_data.obs_group_id
LEFT OUTER JOIN (
	SELECT
		ee.episode_id,
		parentobs.obs_group_id,
		o.obs_datetime,
		GROUP_CONCAT(
			cv_value.concept_full_name SEPARATOR ', '
		) AS 'reasons'
	FROM
		obs o
	INNER JOIN obs parentobs ON parentobs.obs_id = o.obs_group_id
	INNER JOIN concept_view cv ON cv.concept_id = o.concept_id
	AND o.voided IS FALSE
	AND cv.concept_full_name = 'MTC, Additional contributing reasons for less than 100% completeness'
	INNER JOIN concept_view cv_value ON cv_value.concept_id = o.value_coded
	INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
	GROUP BY
		ee.episode_id,
		parentobs.obs_group_id,
		o.obs_datetime
) mtc_additional_reason ON mtc_additional_reason.episode_id = epp.episode_id
AND mtc_additional_reason.obs_datetime = adherence_data.obs_datetime
AND mtc_additional_reason.obs_group_id = adherence_data.obs_group_id
LEFT OUTER JOIN (
	SELECT
		ee.episode_id,
		parentobs.obs_group_id,
		o.obs_datetime,
		GROUP_CONCAT(
			cv_value.concept_full_name SEPARATOR ', '
		) AS 'reasons'
	FROM
		obs o
	INNER JOIN obs parentobs ON parentobs.obs_id = o.obs_group_id
	INNER JOIN concept_view cv ON cv.concept_id = o.concept_id
	AND o.voided IS FALSE
	AND cv.concept_full_name = 'MTC, Additional contributing program related reasons'
	INNER JOIN concept_view cv_value ON cv_value.concept_id = o.value_coded
	INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
	GROUP BY
		ee.episode_id,
		parentobs.obs_group_id,
		o.obs_datetime
) mtc_additional_program_reason ON mtc_additional_program_reason.episode_id = epp.episode_id
AND mtc_additional_program_reason.obs_datetime = adherence_data.obs_datetime
AND mtc_additional_program_reason.obs_group_id = adherence_data.obs_group_id
LEFT OUTER JOIN (
	SELECT
		ee.episode_id,
		parentobs.obs_group_id,
		o.obs_datetime,
		GROUP_CONCAT(
			cv_value.concept_full_name SEPARATOR ', '
		) AS 'reasons'
	FROM
		obs o
	INNER JOIN obs parentobs ON parentobs.obs_id = o.obs_group_id
	INNER JOIN concept_view cv ON cv.concept_id = o.concept_id
	AND o.voided IS FALSE
	AND cv.concept_full_name = 'MTC, Additional contributing medical or treatment related reasons'
	INNER JOIN concept_view cv_value ON cv_value.concept_id = o.value_coded
	INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
	GROUP BY
		ee.episode_id,
		parentobs.obs_group_id,
		o.obs_datetime
) mtc_additional_medical_reason ON mtc_additional_medical_reason.episode_id = epp.episode_id
AND mtc_additional_medical_reason.obs_datetime = adherence_data.obs_datetime
AND mtc_additional_medical_reason.obs_group_id = adherence_data.obs_group_id
LEFT OUTER JOIN (
	SELECT
		ee.episode_id,
		parentobs.obs_group_id,
		o.obs_datetime,
		GROUP_CONCAT(
			cv_value.concept_full_name SEPARATOR ', '
		) AS 'reasons'
	FROM
		obs o
	INNER JOIN obs parentobs ON parentobs.obs_id = o.obs_group_id
	INNER JOIN concept_view cv ON cv.concept_id = o.concept_id
	AND o.voided IS FALSE
	AND cv.concept_full_name = 'MTC, Additional contributing patient related reasons'
	INNER JOIN concept_view cv_value ON cv_value.concept_id = o.value_coded
	INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
	GROUP BY
		ee.episode_id,
		parentobs.obs_group_id,
		o.obs_datetime
) mtc_additional_patient_reason ON mtc_additional_patient_reason.episode_id = epp.episode_id
AND mtc_additional_patient_reason.obs_datetime = adherence_data.obs_datetime
AND mtc_additional_patient_reason.obs_group_id = adherence_data.obs_group_id
LEFT OUTER JOIN (
	SELECT
		ee.episode_id,
		parentobs.obs_group_id,
		o.obs_datetime,
		o.value_text
	FROM
		obs o
	INNER JOIN obs parentobs ON parentobs.obs_id = o.obs_group_id
	INNER JOIN concept_view cv ON cv.concept_id = o.concept_id
	AND o.voided IS FALSE
	AND cv.concept_full_name = 'MTC, Other contributing reason for treatment incomplete'
	INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
) mtc_additional_other_reason ON mtc_additional_other_reason.episode_id = epp.episode_id
AND mtc_additional_other_reason.obs_datetime = adherence_data.obs_datetime
AND mtc_additional_other_reason.obs_group_id = adherence_data.obs_group_id
WHERE
	(
		treatment_end_date.value_datetime IS NULL
		OR adherence_data.obs_datetime <= treatment_end_date.value_datetime
	)
AND (
	adherence_data.obs_datetime >= "#startDate#"
	AND adherence_data.obs_datetime <= "#endDate#"
)
ORDER BY
	registration_number.value_reference ASC,
	adherence_data.obs_datetime ASC;