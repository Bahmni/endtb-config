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
import java.util.ArrayList;
import java.util.Date;

public class EcgReadingsExtension extends BaseTableExtension<PivotTable> {

    public BahmniBridge bahmniBridge;

    @Override
    public void update(PivotTable pivotTable, String patientUuid, String patientProgramUuid) {
        this.bahmniBridge = BahmniBridge
                .create()
                .forPatient(patientUuid)
                .forPatientProgram(patientProgramUuid);

        Date startDate = null;
        Obs latestObs;
        try {
            latestObs = bahmniBridge.latestObs("TUBERCULOSIS DRUG TREATMENT START DATE");
            startDate = latestObs != null ? latestObs.getValueDatetime() : null;
        } catch (Exception e) {
            e.printStackTrace();
            return;
        }
        if (latestObs == null) {
            return;
        }
        EncounterTransaction.Concept concept = constructMonthConcept();
        setMonthHeader(pivotTable, concept);

        for (PivotRow pivotRow : pivotTable.getRows()) {
            calculateMonth(startDate, concept, pivotRow);
        }
    }

    private void calculateMonth(Date startDate, EncounterTransaction.Concept concept, PivotRow pivotRow) {
        Date rowDate = getRowDate(pivotRow);
        Days days = Days.daysBetween(new DateTime(startDate), new DateTime(rowDate));

        String month = String.format("%.1f", days.getDays() / 30.0F);

        BahmniObservation bahmniObservation = new BahmniObservation();
        bahmniObservation.setConcept(concept);
        bahmniObservation.setValue(month);
        pivotRow.addColumn("Month", bahmniObservation);
    }

    private static Date getRowDate(PivotRow pivotRow) {
        ArrayList<BahmniObservation> obs = pivotRow.getColumns().get("EKG, Date of EKG");
        Date rowDate = null;
        DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        try {
            rowDate = dateFormat.parse(obs.get(0).getValueAsString());
        } catch (Exception e) {
            e.printStackTrace();
        }
        return rowDate;
    }

    private static void setMonthHeader(PivotTable pivotTable, EncounterTransaction.Concept concept) {
        pivotTable.getHeaders().add(concept);
    }

    private static EncounterTransaction.Concept constructMonthConcept() {
        EncounterTransaction.Concept concept = new EncounterTransaction.Concept();
        concept.setName("Month");
        return concept;
    }
}
