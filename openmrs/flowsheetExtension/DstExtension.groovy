import org.bahmni.module.bahmnicore.service.impl.BahmniBridge;
import org.joda.time.DateTime;
import org.joda.time.Days;
import org.openmrs.Obs;
import org.openmrs.module.bahmniemrapi.drugogram.contract.BaseTableExtension;
import org.openmrs.module.bahmniemrapi.encountertransaction.contract.BahmniObservation;
import org.openmrs.module.bahmniemrapi.pivottable.contract.PivotRow;
import org.openmrs.module.bahmniemrapi.pivottable.contract.PivotTable;
import org.openmrs.module.emrapi.encounter.domain.EncounterTransaction;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.*;

public class DstExtension extends BaseTableExtension<PivotTable> {

    public BahmniBridge bahmniBridge;


    @Override
    public void update(PivotTable pivotTable, String patientUuid, String patientProgramUuid) {
        this.bahmniBridge = BahmniBridge
                .create()
                .forPatient(patientUuid)
                .forPatientProgram(patientProgramUuid);

        Date startDate;
        try {
            Obs latestObs = bahmniBridge.latestObs("TUBERCULOSIS DRUG TREATMENT START DATE");
            startDate = latestObs != null ? latestObs.getValueDatetime() : null;
        } catch (Exception e) {
            e.printStackTrace();
            return;
        }
        EncounterTransaction.Concept concept = null;
        if (startDate != null) {
            concept = constructMonthConcept();
            setMonthAsHeader(pivotTable, concept);
        }

        List<String> smearPositivityObsValueInDescendingOrder = Arrays.asList("Three plus", "Two plus", "One plus", "Scanty 4-9", "Scanty 1-3", "Negative", "Not read");
        List<String> cultureResultObsValueInDescendingOrder = Arrays.asList("Positive for M. tuberculosis", "Negative for M. tuberculosis", "Contaminated",
                "Only positive for other mycobacterium", "Other");

        for (PivotRow pivotRow : pivotTable.getRows()) {
            if (startDate != null) {

                Date rowDate = getRowDate(pivotRow);
                calucluateMonth(startDate, pivotRow, rowDate, concept);
            }

            ArrayList<BahmniObservation> smearPositivityObs = pivotRow.getColumns().get("Bacteriology, Smear result");
            if (smearPositivityObs != null && smearPositivityObs.size() > 1) {
                Collections.sort(smearPositivityObs, new obsValueComparator(smearPositivityObsValueInDescendingOrder));
                pivotRow.getColumns().remove("Bacteriology, Smear result");
                pivotRow.addColumn("Bacteriology, Smear result", smearPositivityObs.get(0));
            }

            ArrayList<BahmniObservation> cultureResultObs = pivotRow.getColumns().get("Bacteriology, Culture results");
            if (cultureResultObs != null && cultureResultObs.size() > 1) {
                Collections.sort(cultureResultObs, new obsValueComparator(cultureResultObsValueInDescendingOrder));
                pivotRow.getColumns().remove("Bacteriology, Culture results");
                pivotRow.addColumn("Bacteriology, Culture results", cultureResultObs.get(0));
            }
        }
    }

    private void calucluateMonth(Date startDate, PivotRow pivotRow, Date rowDate, EncounterTransaction.Concept concept) {
        Days days = Days.daysBetween(new DateTime(startDate), new DateTime(rowDate));

        String month = String.format("%.1f", days.getDays() / 30.0F);

        BahmniObservation bahmniObservation = new BahmniObservation();
        bahmniObservation.setConcept(concept);
        bahmniObservation.setValue(month);
        pivotRow.addColumn("Month", bahmniObservation);
    }

    private static void setMonthAsHeader(PivotTable pivotTable, EncounterTransaction.Concept concept) {
        pivotTable.getHeaders().add(concept);
    }

    private static EncounterTransaction.Concept constructMonthConcept() {
        EncounterTransaction.Concept concept = new EncounterTransaction.Concept();
        concept.setName("Month");
        return concept;
    }

    private static Date getRowDate(PivotRow pivotRow) {
        ArrayList<BahmniObservation> obs = pivotRow.getColumns().get("Specimen Collection Date");
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
        try {
            return df.parse(obs.get(0).getValueAsString());
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }


    class obsValueComparator implements Comparator<BahmniObservation> {
        private List<String> valueList;

        obsValueComparator(List<String> valueList) {
            this.valueList = valueList;
        }

        @Override
        public int compare(BahmniObservation o1, BahmniObservation o2) {

            Integer o1ValueIndex = valueList.indexOf(o1.getValueAsString());
            Integer o2ValueIndex = valueList.indexOf(o2.getValueAsString());
            return o1ValueIndex.compareTo(o2ValueIndex);
        }
    }
}
