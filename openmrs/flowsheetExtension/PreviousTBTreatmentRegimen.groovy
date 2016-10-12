package org.bahmni.module.bahmnicore.web.v1_0.controller.display.controls

import org.apache.commons.collections.CollectionUtils
import org.openmrs.module.bahmniemrapi.drugogram.contract.BaseTableExtension
import org.openmrs.module.bahmniemrapi.encountertransaction.contract.BahmniObservation
import org.openmrs.module.bahmniemrapi.pivottable.contract.PivotRow
import org.openmrs.module.bahmniemrapi.pivottable.contract.PivotTable

import java.text.DateFormat
import java.text.ParseException
import java.text.SimpleDateFormat

public class PreviousTBTreatmentRegimen extends BaseTableExtension<PivotTable> {

    private static final String SORTED_CONCEPT_NAME = "Baseline, Start date of past TB treatment";

    @Override
    public void update(PivotTable table, String patientUuid, String patientProgramUuid) {
        Map<Object, List<PivotRow>> pivotRowToConceptMap = new TreeMap<Object, List<PivotRow>>();
        if(CollectionUtils.isNotEmpty(table.getRows())) {
            for (PivotRow pivotRow : table.getRows()) {
                Object value = getValue(pivotRow);
                if (pivotRowToConceptMap.containsKey(value)) {
                    pivotRowToConceptMap.get(value).add(pivotRow);
                } else {
                    List<PivotRow> pivotRows = new ArrayList<PivotRow>();
                    pivotRows.add(pivotRow);
                    pivotRowToConceptMap.put(value, pivotRows);
                }
            }
        }
        List<PivotRow> sortedPivotRows = getPivotRowsFromMap(pivotRowToConceptMap);
        table.setRows(sortedPivotRows);
    }

    private Object getValue(PivotRow pivotRow) throws ParseException {
        List<BahmniObservation> columnValue = pivotRow.getValue(SORTED_CONCEPT_NAME);
        if(CollectionUtils.isNotEmpty(columnValue)) {
            BahmniObservation bahmniObservation = columnValue.get(0);
            DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
            return dateFormat.parse((String) bahmniObservation.getValue());
        }
        return new Date();
    }

    private List<PivotRow> getPivotRowsFromMap(Map<Object, List<PivotRow>> pivotRowToConceptMap) {
        List<PivotRow> pivotRows = new ArrayList<PivotRow>();
        for (Map.Entry<Object, List<PivotRow>> entry : pivotRowToConceptMap.entrySet()) {
            pivotRows.addAll(entry.getValue());
        }
        return pivotRows;
    }
}