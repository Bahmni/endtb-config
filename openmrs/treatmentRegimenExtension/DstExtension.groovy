import org.joda.time.DateTime;
import org.joda.time.Days;
import org.openmrs.module.bahmniemrapi.encountertransaction.contract.BahmniObservation;
import org.openmrs.module.bahmniemrapi.pivottable.contract.PivotRow;
import org.openmrs.module.bahmniemrapi.drugogram.contract.BaseTableExtension;
import org.openmrs.module.bahmniemrapi.pivottable.contract.PivotTable;
import org.openmrs.module.emrapi.encounter.domain.EncounterTransaction;
import org.bahmni.module.bahmnicore.service.impl.BahmniBridge;

import java.util.ArrayList;
import java.util.Date;
import java.text.DateFormat;
import java.text.SimpleDateFormat;

public class MonthCalculationExtension extends BaseTableExtension<PivotTable> {

	public BahmniBridge bahmniBridge;

	@Override
	public void update(PivotTable pivotTable, String patientUuid) {
		this.bahmniBridge = BahmniBridge
				.create()
				.forPatient(patientUuid);

		Date startDate = null;
		DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
		try {
			startDate = bahmniBridge.getStartDateOfTreatment();
		} catch (Exception e) {
			System.out.println("Exception: "+ e.getMessage())
			return;
		}
		EncounterTransaction.Concept concept = new EncounterTransaction.Concept();
		concept.setName("Month");
		pivotTable.getHeaders().add(concept);

		for (PivotRow pivotRow : pivotTable.getRows()) {
			ArrayList<BahmniObservation> obs = pivotRow.getColumns().get("Specimen Collection Date");
			Date rowDate = null;
			try {
				rowDate = df.parse(obs.get(0).getValueAsString());
			} catch (Exception e) {
				System.out.println("Exception: "+ e.getMessage())
				return;
			}
			Days days = Days.daysBetween(new DateTime(startDate), new DateTime(rowDate));

			String month = String.format("%.1f", days.getDays() / 30.0F);

			BahmniObservation bahmniObservation = new BahmniObservation();
			bahmniObservation.setConcept(concept);
			bahmniObservation.setValue(month);
			pivotRow.addColumn("Month", bahmniObservation);
		}
	}
}
