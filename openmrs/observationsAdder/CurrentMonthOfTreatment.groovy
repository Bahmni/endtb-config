import org.bahmni.module.bahmnicore.obs.ObservationsAdder;
import org.joda.time.DateTime;
import org.joda.time.Days;
import org.openmrs.Concept;
import org.openmrs.Obs;
import org.openmrs.api.context.Context;

import java.util.Date;
import java.util.List;

public class CurrentMonthOfTreatment implements ObservationsAdder {

    public void addObservations(List<Obs> observations,  List<String> conceptNames) {
        if (conceptNames.contains("Current month of treatment")) {
            Obs drugTreatmentStartDateObservation = getTreatmentStartDateObservation(observations);

            if (drugTreatmentStartDateObservation != null) {
                String month = getCurrentMonthOfTreatment(drugTreatmentStartDateObservation.getValueDate());

                Concept currentMonthOfTreatmentConcept = Context.getConceptService().getConcept("Current month of treatment");

                Obs currentMonthOfTreatmentObservation = createObservation(drugTreatmentStartDateObservation, currentMonthOfTreatmentConcept);
                currentMonthOfTreatmentObservation.setValueText(month);

                observations.add(currentMonthOfTreatmentObservation);
            }
        }
    }

    private Obs createObservation(Obs parent, Concept questionConcept) {
        Obs observation = new Obs(parent.getPerson(),
                questionConcept, new Date(), parent.getLocation());
        observation.setEncounter(parent.getEncounter());
        observation.setCreator(parent.getCreator());
        return observation;
    }

    private String getCurrentMonthOfTreatment(Date startDate) {
        DateTime startDateTime = new DateTime(startDate);
        Days days = Days.daysBetween(startDateTime, new DateTime());
        return String.format("%.1f", days.getDays() / 30.0F);
    }

    private Obs getTreatmentStartDateObservation(List<Obs> observations) {
        for (Obs obs : observations) {
            if (obs.getConcept().getName().getName().equals("TUBERCULOSIS DRUG TREATMENT START DATE")) {
                return obs;
            }
        }
        return null;
    }
}