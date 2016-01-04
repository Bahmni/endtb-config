import org.apache.log4j.Logger
import org.joda.time.DateTime;
import org.joda.time.Days
import org.joda.time.Hours;
import org.openmrs.module.bahmniemrapi.drugogram.contract.RegimenRow;
import org.openmrs.module.bahmniemrapi.drugogram.contract.TreatmentRegimen;
import org.openmrs.module.bahmniemrapi.drugogram.contract.BaseTableExtension
import org.openmrs.module.emrapi.encounter.domain.EncounterTransaction

public class TreatmentRegimenExtension extends BaseTableExtension<TreatmentRegimen> {
	private static final org.apache.log4j.Logger log = Logger.getLogger(TreatmentRegimenExtension.class);
	public static final int STOPING_INTERVAL_HOURS = 48;

	@Override
	public void update(TreatmentRegimen treatmentRegimen) {
		Date treatmentStartDate = null;
		try {
			treatmentStartDate = treatmentRegimen.getRows().first().getDate()
		} catch (Exception e) {
			e.printStackTrace();
			return;
		}

		skipStopFlaging(STOPING_INTERVAL_HOURS, treatmentRegimen);

		for (RegimenRow regimenRow : treatmentRegimen.getRows()) {
			DateTime currentTreatmentDate = new DateTime(regimenRow.getDate());
			Days days = Days.daysBetween(new DateTime(treatmentStartDate), currentTreatmentDate);
			String month = String.format("%.1f", days.getDays()/30.0F);
			regimenRow.setMonth(month);
		}
	}

	void skipStopFlaging(int restartTimeInterval, TreatmentRegimen treatmentRegimen) {
		for (EncounterTransaction.Concept drug : treatmentRegimen.getHeaders()) {
			RegimenRow lastStopRow = null;
			for (RegimenRow row : treatmentRegimen.getRows()) {
				Date rowDate = row.getDate();
				if("Stop".equals(row.getDrugs().get(drug.getName()))) {
					lastStopRow = row;
				} else if(isStopFlagInInterval(row, drug, lastStopRow, restartTimeInterval)) {
					lastStopRow.getDrugs().put(drug.getName(), null);
				}
			}
		}
	}

	private boolean isStopFlagInInterval(RegimenRow row, EncounterTransaction.Concept drug, RegimenRow lastStopRow,
										 int restartTimeInterval) {
		return (row.getDrugs().get(drug.getName()) != null
		&& lastStopRow != null
		&& Hours.hoursBetween(new DateTime(lastStopRow.getDate()), new DateTime(row.getDate())).hours <= restartTimeInterval);
	}

}
