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
        if (conceptNames.contains("Current month of treatment")) {
            BahmniObservation drugTreatmentStartDateObservation = getTreatmentStartDateObservation(observations);

            if (drugTreatmentStartDateObservation != null) {
                String string = drugTreatmentStartDateObservation.getValueAsString();
                DateFormat format = new SimpleDateFormat("yyyy-MM-dd", Locale.ENGLISH);
                Date date = format.parse(string);
                String month = getCurrentMonthOfTreatment(date);

                Concept currentMonthOfTreatmentConcept = Context.getConceptService().getConcept("Current month of treatment");
                EncounterTransaction.Concept concept = new ConceptMapper().map(currentMonthOfTreatmentConcept);

                BahmniObservation currentMonthOfTreatmentObservation = createObservation(drugTreatmentStartDateObservation, concept);
                currentMonthOfTreatmentObservation.setValue(month);

                observations.add(currentMonthOfTreatmentObservation);
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

    private String getCurrentMonthOfTreatment(Date startDate) {
        DateTime startDateTime = new DateTime(startDate);
        Days days = Days.daysBetween(startDateTime, new DateTime());
        return String.format("%.1f", days.getDays() / 30.0F);
    }

    private BahmniObservation getTreatmentStartDateObservation(Collection<BahmniObservation> observations) {
        for (BahmniObservation obs : observations) {
            if (obs.getConcept().getName().equals("TUBERCULOSIS DRUG TREATMENT START DATE")) {
                return obs;
            }
        }
        return null;
    }
}