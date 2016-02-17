package org.bahmni.module.bahmnicore.web.v1_0.controller.display.controls;

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

public class ChestXRayExtension extends BaseTableExtension<PivotTable> {

    public BahmniBridge bahmniBridge;

    @Override
    public void update(PivotTable pivotTable, String patientUuid, String patientProgramUuid) {
        this.bahmniBridge = BahmniBridge
                .create()
                .forPatient(patientUuid)
                .forPatientProgram(patientProgramUuid);

        Date startDate = null;
        try {
            Obs latestObs = bahmniBridge.latestObs("TUBERCULOSIS DRUG TREATMENT START DATE");
            startDate = latestObs != null ? latestObs.getValueDatetime() : null;
            if (startDate == null) {
                return;
            }
            EncounterTransaction.Concept concept = constructMonthConcept();
            setMonthAsHeader(pivotTable, concept);

            for (PivotRow pivotRow : pivotTable.getRows()) {
                Date rowDate = getRowDate(pivotRow);
                Days days = Days.daysBetween(new DateTime(startDate), new DateTime(rowDate));
                String month = String.format("%.1f", days.getDays() / 30.0F);
                setMonth(concept, pivotRow, month);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static EncounterTransaction.Concept constructMonthConcept() {
        EncounterTransaction.Concept concept = new EncounterTransaction.Concept();
        concept.setName("Month");
        return concept;
    }

    private static void setMonth(EncounterTransaction.Concept concept, PivotRow pivotRow, String month) {
        BahmniObservation bahmniObservation = new BahmniObservation();
        bahmniObservation.setConcept(concept);
        bahmniObservation.setValue(month);
        pivotRow.addColumn("Month", bahmniObservation);
    }

    private static void setMonthAsHeader(PivotTable pivotTable, EncounterTransaction.Concept concept) {
        pivotTable.getHeaders().add(concept);
    }

    private static Date getRowDate(PivotRow pivotRow) {
        ArrayList<BahmniObservation> obs = pivotRow.getColumns().get("Xray, Chest Xray Date");
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
        try {
            return df.parse(obs.get(0).getValueAsString());
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
