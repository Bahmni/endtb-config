import org.bahmni.module.bahmnicore.obs.ObservationsAdder;
import org.joda.time.DateTime;
import org.joda.time.Days;
import org.openmrs.Concept;
import org.openmrs.api.context.Context;
import org.openmrs.module.bahmniemrapi.encountertransaction.contract.BahmniObservation;
import org.openmrs.module.emrapi.encounter.ConceptMapper;
import org.openmrs.module.emrapi.encounter.domain.EncounterTransaction;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class CurrentMonthOfTreatment implements ObservationsAdder {

    @Override
    public void addObservations(Collection<BahmniObservation> observations, List<String> conceptNames) throws ParseException {
        BahmniObservation drugTreatmentEndDateObservation = getObservationForConceptName(observations, "Tuberculosis treatment end date");
        BahmniObservation drugTreatmentStartDateObservation = getObservationForConceptName(observations, "TUBERCULOSIS DRUG TREATMENT START DATE");

        if (conceptNames.contains("Current month of treatment")) {

            if (drugTreatmentStartDateObservation != null) {
                String string = drugTreatmentStartDateObservation.getValueAsString();
                DateFormat format = new SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH);
                Date drugTreatmentStartDate = format.parse(string);
                Date endDate = new Date();
                String conceptName = "Current month of treatment";

                if(drugTreatmentEndDateObservation != null) {
                    String endDateString = drugTreatmentEndDateObservation.getValueAsString();
                    endDate = format.parse(endDateString);
                    conceptName = "Treatment Duration";
                }

                String valueToBeAdded = getDurationInMonthsBetweenDates(drugTreatmentStartDate, endDate);
                Concept conceptToBeAdded = Context.getConceptService().getConcept(conceptName);

                EncounterTransaction.Concept concept = new ConceptMapper().map(conceptToBeAdded);
                BahmniObservation observationToBeAdded = createObservation(drugTreatmentStartDateObservation, concept);
                observationToBeAdded.setValue(valueToBeAdded);

                observations.add(observationToBeAdded);
            }
        }
    }

    private BahmniObservation createObservation(BahmniObservation obs, EncounterTransaction.Concept questionConcept) {
        BahmniObservation bahmniObservation = new BahmniObservation();

        bahmniObservation.setConcept(questionConcept);
        bahmniObservation.setEncounterUuid(obs.getEncounterUuid());
        bahmniObservation.setCreatorName(obs.getCreatorName());
        bahmniObservation.setObservationDateTime(new Date());

        return bahmniObservation;
    }

    private String getDurationInMonthsBetweenDates(Date startDate, Date endDate) {
        DateTime startDateTime = new DateTime(startDate);
        DateTime endDateTime = new DateTime(endDate)
        Days days = Days.daysBetween(startDateTime, endDateTime);
        return String.format("%.1f", days.getDays() / 30.0F);
    }

    private BahmniObservation getObservationForConceptName(Collection<BahmniObservation> observations, String conceptName) {
        for (BahmniObservation obs : observations) {
            if (obs.getConcept().getName().equals(conceptName)) {
                return obs;
            }
        }
        return null;
    }
}