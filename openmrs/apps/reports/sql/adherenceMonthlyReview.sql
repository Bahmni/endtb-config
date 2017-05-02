SELECT
	registrationNumber AS 'Registration Number',
	emrId AS 'EMR ID',
	indicator AS 'Indicator',
	ttrCohort AS 'Ttr Cohort',
	startTtrDate AS 'Start Ttr Date',
	drugResistance AS 'Drug Resistance',
	drugResistancePattern AS 'Drug Resistance Pattern',
	ttrOutcome AS 'Ttr Outcome',
	endOfTtrDate AS 'End Of Ttr Date',
	ttrOutcomeDate AS 'Ttr Outcome Date',
	ttrDuration AS 'Ttr Duration',
    MAX(IF(monthSinceStart =  0, indicatorValue ,NULL)) AS 'M1',
    MAX(IF(monthSinceStart =  1, indicatorValue ,NULL)) AS 'M2',
    MAX(IF(monthSinceStart =  2, indicatorValue ,NULL)) AS 'M3',
    MAX(IF(monthSinceStart =  3, indicatorValue ,NULL)) AS 'M4',
    MAX(IF(monthSinceStart =  4, indicatorValue ,NULL)) AS 'M5',
    MAX(IF(monthSinceStart =  5, indicatorValue ,NULL)) AS 'M6',
    MAX(IF(monthSinceStart =  6, indicatorValue ,NULL)) AS 'M7',
    MAX(IF(monthSinceStart =  7, indicatorValue ,NULL)) AS 'M8',
    MAX(IF(monthSinceStart =  8, indicatorValue ,NULL)) AS 'M9',
    MAX(IF(monthSinceStart =  9, indicatorValue ,NULL)) AS 'M10',
    MAX(IF(monthSinceStart = 10, indicatorValue ,NULL)) AS 'M11',
    MAX(IF(monthSinceStart = 11, indicatorValue ,NULL)) AS 'M12',
    MAX(IF(monthSinceStart = 12, indicatorValue ,NULL)) AS 'M13',
    MAX(IF(monthSinceStart = 13, indicatorValue ,NULL)) AS 'M14',
    MAX(IF(monthSinceStart = 14, indicatorValue ,NULL)) AS 'M15',
    MAX(IF(monthSinceStart = 15, indicatorValue ,NULL)) AS 'M16',
    MAX(IF(monthSinceStart = 16, indicatorValue ,NULL)) AS 'M17',
    MAX(IF(monthSinceStart = 17, indicatorValue ,NULL)) AS 'M18',
    MAX(IF(monthSinceStart = 18, indicatorValue ,NULL)) AS 'M19',
    MAX(IF(monthSinceStart = 19, indicatorValue ,NULL)) AS 'M20',
    MAX(IF(monthSinceStart = 20, indicatorValue ,NULL)) AS 'M21',
    MAX(IF(monthSinceStart = 21, indicatorValue ,NULL)) AS 'M22',
    MAX(IF(monthSinceStart = 22, indicatorValue ,NULL)) AS 'M23',
    MAX(IF(monthSinceStart = 23, indicatorValue ,NULL)) AS 'M24',
    MAX(IF(monthSinceStart = 24, indicatorValue ,NULL)) AS 'M25',
    MAX(IF(monthSinceStart = 25, indicatorValue ,NULL)) AS 'M26',
    MAX(IF(monthSinceStart = 26, indicatorValue ,NULL)) AS 'M27',
    MAX(IF(monthSinceStart = 27, indicatorValue ,NULL)) AS 'M28',
    MAX(IF(monthSinceStart = 28, indicatorValue ,NULL)) AS 'M29',
    MAX(IF(monthSinceStart = 29, indicatorValue ,NULL)) AS 'M30',
    MAX(IF(monthSinceStart = 30, indicatorValue ,NULL)) AS 'M31',
    MAX(IF(monthSinceStart = 31, indicatorValue ,NULL)) AS 'M32',
    MAX(IF(monthSinceStart = 32, indicatorValue ,NULL)) AS 'M33',
    MAX(IF(monthSinceStart = 33, indicatorValue ,NULL)) AS 'M34',
    MAX(IF(monthSinceStart = 34, indicatorValue ,NULL)) AS 'M35',
    MAX(IF(monthSinceStart = 35, indicatorValue ,NULL)) AS 'M36'
FROM (
	SELECT
		registration_number.value_reference AS registrationNumber,
		pi.identifier AS emrId,
		monthlyTreatmentData.conceptName AS indicator,
		CONCAT(DATE_FORMAT(treatment_start_date.value_datetime, '%Y'), QUARTER(treatment_start_date.value_datetime)) as ttrCohort,
		DATE_FORMAT(treatment_start_date.value_datetime,'%d/%b/%Y') AS startTtrDate,
		baseline_drug_resistance.name AS drugResistance,
		baseline_subclassification.name AS drugResistancePattern,
		treatment_outcome.name AS ttrOutcome,
		DATE_FORMAT(treatment_end_date.value_datetime,'%d/%b/%Y') AS endOfTtrDate,
		DATE_FORMAT(treatment_outcome_date.value_datetime,'%d/%b/%Y') AS ttrOutcomeDate,
		IF(
			treatment_end_date.value_datetime,
			TRUNCATE(TIMESTAMPDIFF(DAY, treatment_start_date.value_datetime, treatment_end_date.value_datetime)/30.5, 1),
			TRUNCATE(TIMESTAMPDIFF(DAY,treatment_start_date.value_datetime, NOW())/30.5, 1)
		) AS ttrDuration,
		(
			12 * (EXTRACT(YEAR FROM monthlyTreatmentData.obs_datetime) - EXTRACT(YEAR FROM treatment_start_date.value_datetime)) +
			EXTRACT(MONTH FROM monthlyTreatmentData.obs_datetime) - EXTRACT(MONTH FROM treatment_start_date.value_datetime)
		) AS monthSinceStart,
		monthlyTreatmentData.value_numeric AS indicatorValue
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
			COALESCE(cv.concept_short_name, cv.concept_full_name) AS name
		FROM
			obs o
		INNER JOIN concept_name cn ON cn.concept_id = o.concept_id
		AND o.voided IS FALSE
		AND cn.concept_name_type='FULLY_SPECIFIED' AND cn.name = 'Baseline, Drug resistance'
		INNER JOIN concept_view cv ON cv.concept_id = o.value_coded
		INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
	) baseline_drug_resistance ON baseline_drug_resistance.episode_id = epp.episode_id
	LEFT OUTER JOIN (
		SELECT
			ee.episode_id,
			COALESCE(cv.concept_short_name, cv.concept_full_name) AS name
		FROM
			obs o
		INNER JOIN concept_name cn ON cn.concept_id = o.concept_id
		AND o.voided IS FALSE
		AND cn.concept_name_type='FULLY_SPECIFIED' AND cn.name = 'Baseline, Subclassification for confimed drug resistant cases'
		INNER JOIN concept_view cv ON cv.concept_id = o.value_coded
		INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
	) baseline_subclassification ON baseline_subclassification.episode_id = epp.episode_id
	LEFT OUTER JOIN (
		SELECT
			ee.episode_id,
			COALESCE(cv.concept_short_name, cv.concept_full_name) AS name
		FROM
			obs o
		INNER JOIN concept_name cn ON cn.concept_id = o.concept_id
		AND o.voided IS FALSE
		AND cn.concept_name_type='FULLY_SPECIFIED' AND cn.name = 'EOT, Outcome'
		INNER JOIN concept_view cv ON cv.concept_id = o.value_coded
		INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
	) treatment_outcome ON treatment_outcome.episode_id = epp.episode_id
	LEFT OUTER JOIN (
		SELECT
			ee.episode_id,
			o.value_datetime
		FROM
			obs o
		INNER JOIN concept_name cn ON cn.concept_id = o.concept_id
		AND o.voided IS FALSE
		AND cn.concept_name_type='FULLY_SPECIFIED' AND cn.name = 'Tuberculosis treatment end date'
		INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
	) treatment_end_date ON treatment_end_date.episode_id = epp.episode_id
	LEFT OUTER JOIN (
		SELECT
			ee.episode_id,
			o.value_datetime
		FROM
			obs o
		INNER JOIN concept_name cn ON cn.concept_id = o.concept_id
		AND o.voided IS FALSE
		AND cn.concept_name_type='FULLY_SPECIFIED' AND cn.name = 'EOT, End of Treatment Outcome date'
		INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
	) treatment_outcome_date ON treatment_outcome_date.episode_id = epp.episode_id
	LEFT OUTER JOIN (
		SELECT
			ee.episode_id,
			COALESCE(cv.concept_short_name, cv.concept_full_name) AS conceptName,
			o.obs_datetime,
			o.value_numeric
		FROM
			obs o
		INNER JOIN concept_view cv ON cv.concept_id = o.concept_id
		AND o.voided IS FALSE
		AND cv.concept_full_name IN (
			'MTC, Overall DOT Rate',
			'MTC, Adherence rate',
			'MTC, Completeness rate'
		)
		INNER JOIN episode_encounter ee ON ee.encounter_id = o.encounter_id
	) monthlyTreatmentData ON monthlyTreatmentData.episode_id = epp.episode_id
	WHERE
		treatment_start_date.value_datetime BETWEEN '#startDate#' AND '#endDate#'
) subquery
GROUP BY
	registrationNumber,
	emrId,
	indicator,
	ttrCohort,
	startTtrDate,
	drugResistance,
	drugResistancePattern,
	ttrOutcome,
	endOfTtrDate,
	ttrOutcomeDate,
	ttrDuration
ORDER BY
	registrationNumber,
	indicator
