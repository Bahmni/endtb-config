import org.bahmni.module.bahmnicore.service.impl.BahmniBridge
import org.joda.time.DateTime
import org.joda.time.Days
import org.openmrs.module.bahmniemrapi.drugogram.contract.BaseTableExtension
import org.openmrs.module.bahmniemrapi.encountertransaction.contract.BahmniObservation
import org.openmrs.module.bahmniemrapi.pivottable.contract.PivotRow
import org.openmrs.module.bahmniemrapi.pivottable.contract.PivotTable
import org.openmrs.module.emrapi.encounter.domain.EncounterTransaction

import java.text.DateFormat
import java.text.SimpleDateFormat
import java.util.*

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
			e.printStackTrace();
			return;
		}
		EncounterTransaction.Concept concept = new EncounterTransaction.Concept();
		concept.setName("Month");
		pivotTable.getHeaders().add(concept);

		List<String> smearPositivityObsValueInDescendingOrder = Arrays.asList("3+", "2+", "1+", "Scanty")
		List<String> cultureResultObsValueInDescendingOrder = Arrays.asList("Positive for M. tuberculosis", "Negative for M. tuberculosis", "Contaminated",
				"Only positive for other mycobacterium", "Other")

		for (PivotRow pivotRow : pivotTable.getRows()) {
			ArrayList<BahmniObservation> obs = pivotRow.getColumns().get("Specimen Collection Date");
			Date rowDate = null;
			try {
				rowDate = df.parse(obs.get(0).getValueAsString());
			} catch (Exception e) {
				e.printStackTrace();
				return;
			}
			Days days = Days.daysBetween(new DateTime(startDate), new DateTime(rowDate));

			String month = String.format("%.1f", days.getDays() / 30.0F);

			BahmniObservation bahmniObservation = new BahmniObservation();
			bahmniObservation.setConcept(concept);
			bahmniObservation.setValue(month);
			pivotRow.addColumn("Month", bahmniObservation);

			ArrayList<BahmniObservation> smearPositivityObs = pivotRow.getColumns().get("Bacteriology, Smear result positivity");
			if(smearPositivityObs != null && smearPositivityObs.size() > 1) {
				Collections.sort(smearPositivityObs, new obsValueComparator(smearPositivityObsValueInDescendingOrder));
				pivotRow.getColumns().remove("Bacteriology, Smear result positivity");
				pivotRow.addColumn("Bacteriology, Smear result positivity", smearPositivityObs.get(0));
			}

			ArrayList<BahmniObservation> cultureResultObs = pivotRow.getColumns().get("Bacteriology, Culture results");
			if(cultureResultObs != null && cultureResultObs.size() > 1) {
				Collections.sort(cultureResultObs, new obsValueComparator(cultureResultObsValueInDescendingOrder));
				pivotRow.getColumns().remove("Bacteriology, Culture results");
				pivotRow.addColumn("Bacteriology, Culture results", cultureResultObs.get(0));
			}
		}
	}

	class obsValueComparator implements Comparator<BahmniObservation> {
		private List<String> valueList;

		obsValueComparator(List<String> valueList) {
			this.valueList = valueList
		}

		@Override
		public int compare(BahmniObservation o1, BahmniObservation o2) {

			Integer o1ValueIndex = valueList.indexOf(o1.getValueAsString());
			Integer o2ValueIndex = valueList.indexOf(o2.getValueAsString());
			return o1ValueIndex.compareTo(o2ValueIndex);
		}
	}
}
