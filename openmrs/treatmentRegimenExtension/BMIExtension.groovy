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

public class BMIExtension extends BaseTableExtension<PivotTable> {

    public BahmniBridge bahmniBridge;


    @Override
    public void update(PivotTable pivotTable, String patientUuid) {
        this.bahmniBridge = BahmniBridge
                .create()
                .forPatient(patientUuid);


        EncounterTransaction.Concept concept = new EncounterTransaction.Concept();
        concept.setName("BMI");
        pivotTable.getHeaders().add(concept);

        PivotRow newPivotRow = new PivotRow();
        BahmniObservation latestObsForParentOfHeight = bahmniBridge.getLatestBahmniObservationFor("Baseline, Clinical Examination")
        if(latestObsForParentOfHeight != null) {
            BahmniObservation latestObsForDate = bahmniBridge.getChildObsFromParentObs(latestObsForParentOfHeight.getObsGroupUuid(), "Baseline, Date of baseline");
            BahmniObservation latestObsForHeight = bahmniBridge.getChildObsFromParentObs(latestObsForParentOfHeight.getUuid(), "Height (cm)");
            BahmniObservation latestObsForWeight = bahmniBridge.getChildObsFromParentObs(latestObsForParentOfHeight.getUuid(), "Weight (kg)");

            newPivotRow.addColumn("Followup, Visit Date", latestObsForDate);
            newPivotRow.addColumn("Height (cm)", latestObsForHeight);
            newPivotRow.addColumn("Weight (kg)", latestObsForWeight);
            pivotTable.addRow(newPivotRow);
        }

        for (PivotRow pivotRow : pivotTable.getRows()) {
            ArrayList<BahmniObservation> weightBahmniObservation = pivotRow.getValue("Weight (kg)");
            BahmniObservation latestObsForBMIData = bahmniBridge.getChildObsFromParentObs(weightBahmniObservation.get(0).getObsGroupUuid(), "BMI Data");
            BahmniObservation latestObsForBMI = bahmniBridge.getChildObsFromParentObs(latestObsForBMIData.getUuid(), "Body mass index");
            pivotRow.addColumn("BMI", latestObsForBMI);
        }
    }
}
