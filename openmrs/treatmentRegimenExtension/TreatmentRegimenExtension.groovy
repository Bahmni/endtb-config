package org.bahmni.module.bahmnicore.web.v1_0.controller.display.controls;

import org.apache.log4j.Logger;
import org.bahmni.module.bahmnicore.service.impl.BahmniBridge;
import org.joda.time.DateTime;
import org.joda.time.Days;
import org.joda.time.Hours;
import org.openmrs.Obs;
import org.openmrs.module.bahmniemrapi.drugogram.contract.BaseTableExtension;
import org.openmrs.module.bahmniemrapi.drugogram.contract.RegimenRow;
import org.openmrs.module.bahmniemrapi.drugogram.contract.TreatmentRegimen;
import org.openmrs.module.emrapi.encounter.domain.EncounterTransaction;

import java.util.Date;

public class TreatmentRegimenExtension extends BaseTableExtension<TreatmentRegimen> {
	private static final Logger log = Logger.getLogger(TreatmentRegimenExtension.class);
	public static final int STOPING_INTERVAL_HOURS = 48;
	public BahmniBridge bahmniBridge;

	@Override
	public void update(TreatmentRegimen treatmentRegimen, String patientUuid, String patientProgramUuid) {
		this.bahmniBridge = BahmniBridge
				.create()
				.forPatient(patientUuid)
				.forPatientProgram(patientProgramUuid);
		skipStopFlaging(STOPING_INTERVAL_HOURS, treatmentRegimen);
		calculateMonth(treatmentRegimen, patientUuid);
	}

	private void calculateMonth(TreatmentRegimen treatmentRegimen, String patientUuid) {
		Date startDate = null;
		try {
			Obs latestObs = bahmniBridge.latestObs("TUBERCULOSIS DRUG TREATMENT START DATE");
			startDate = latestObs != null ? latestObs.getValueDatetime() : null;
			if (startDate == null) {
				return;
			}
			for (RegimenRow regimenRow : treatmentRegimen.getRows()) {
				DateTime currentTreatmentDate = new DateTime(regimenRow.getDate());
				Days days = Days.daysBetween(new DateTime(startDate), currentTreatmentDate);
				String month = String.format("%.1f", days.getDays() / 30.0F);
				regimenRow.setMonth(month);
			}
		} catch (Exception e) {
			e.printStackTrace();;
		}

	}

	void skipStopFlaging(int restartTimeInterval, TreatmentRegimen treatmentRegimen) {
		for (EncounterTransaction.Concept drug : treatmentRegimen.getHeaders()) {
			RegimenRow lastStopRow = null;
			for (RegimenRow row : treatmentRegimen.getRows()) {
				if ("Stop".equals(row.getDrugs().get(drug.getName()))) {
					lastStopRow = row;
				} else if (isStopFlagInInterval(row, drug, lastStopRow, restartTimeInterval)) {
					lastStopRow.getDrugs().put(drug.getName(), "");
				}
			}
		}
	}

	private boolean isStopFlagInInterval(RegimenRow row, EncounterTransaction.Concept drug, RegimenRow lastStopRow,
										 int restartTimeInterval) {
		return (row.getDrugs().get(drug.getName()) != null
				&& lastStopRow != null
				&& Hours.hoursBetween(new DateTime(lastStopRow.getDate()), new DateTime(row.getDate())).getHours() <= restartTimeInterval);
	}

}
