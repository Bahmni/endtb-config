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
        EncounterTransaction.Concept monthConcept = null;
        if (startDate != null) {
            monthConcept = constructMonthConcept();
            setMonthAsHeader(pivotTable, monthConcept);

        }

        EncounterTransaction.Concept concept = new EncounterTransaction.Concept();
        concept.setName("BMI");
        pivotTable.getHeaders().add(concept);

        addBaselinePivotRow(pivotTable);

        for (PivotRow pivotRow : pivotTable.getRows()) {
            if (startDate != null) {
                Date rowDate = getRowDate(pivotRow);
                calucluateMonth(startDate, pivotRow, rowDate, monthConcept);
            }
            ArrayList<BahmniObservation> weightBahmniObservation = pivotRow.getValue("Weight (kg)");
            if(weightBahmniObservation!=null && weightBahmniObservation.size()>0){
                BahmniObservation latestObsForBMIData = bahmniBridge.getChildObsFromParentObs(weightBahmniObservation.get(0).getObsGroupUuid(), "BMI Data");
                if (latestObsForBMIData != null) {
                    BahmniObservation latestObsForBMI = bahmniBridge.getChildObsFromParentObs(latestObsForBMIData.getUuid(), "Body mass index");
                    BahmniObservation abnormalObsForBMI = bahmniBridge.getChildObsFromParentObs(latestObsForBMIData.getUuid(), "BMI Abnormal");
                    latestObsForBMI.setAbnormal(abnormalObsForBMI.getValue());
                    pivotRow.addColumn("BMI", latestObsForBMI);
                }
            }
        }
    }

    private void addBaselinePivotRow(PivotTable pivotTable) {
        PivotRow newPivotRow = new PivotRow();
        BahmniObservation latestObsForParentOfHeight = bahmniBridge.getLatestBahmniObservationFor("Baseline, Clinical Examination")
        if (latestObsForParentOfHeight == null) {
            return;
        }

        BahmniObservation latestObsForDate = bahmniBridge.getChildObsFromParentObs(latestObsForParentOfHeight.getUuid(), "Baseline, Date of baseline physical examination");
        BahmniObservation latestObsForHeight = bahmniBridge.getChildObsFromParentObs(latestObsForParentOfHeight.getUuid(), "Height (cm)");
        BahmniObservation latestObsForWeight = bahmniBridge.getChildObsFromParentObs(latestObsForParentOfHeight.getUuid(), "Weight (kg)");

        if(latestObsForDate == null || (latestObsForHeight == null && latestObsForWeight == null)) {
            return;
        }

        addRow(newPivotRow,"Followup, Visit Date", latestObsForDate)
        addRow(newPivotRow,"Height (cm)", latestObsForHeight)
        addRow(newPivotRow,"Weight (kg)", latestObsForWeight)

        if (newPivotRow.getColumns().size() > 0) {
            pivotTable.addRow(0, newPivotRow);
        }
    }

    private void addRow(PivotRow pivotRow,String key, Object value){
        if(value!=null){
            pivotRow.addColumn(key,value);
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
        ArrayList<BahmniObservation> obs = pivotRow.getColumns().get("Followup, Visit Date");
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
        try {
            return df.parse(obs.get(0).getValueAsString());
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

}
