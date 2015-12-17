import org.apache.commons.lang.StringUtils
import org.hibernate.Query
import org.hibernate.SessionFactory
import org.openmrs.Obs
import org.openmrs.Patient
import org.openmrs.module.bahmniemrapi.encountertransaction.contract.BahmniObservation
import org.openmrs.util.OpenmrsUtil;
import org.openmrs.api.context.Context
import org.openmrs.module.bahmniemrapi.obscalculator.ObsValueCalculator;
import org.openmrs.module.bahmniemrapi.encountertransaction.contract.BahmniEncounterTransaction
import org.openmrs.module.emrapi.encounter.domain.EncounterTransaction;

import org.joda.time.LocalDate;
import org.joda.time.Months;
import java.text.DateFormat;
import java.text.SimpleDateFormat;

public class BahmniObsValueCalculator implements ObsValueCalculator {

    static Double BMI_VERY_SEVERELY_UNDERWEIGHT = 16.0;
    static Double BMI_SEVERELY_UNDERWEIGHT = 17.0;
    static Double BMI_UNDERWEIGHT = 18.5;
    static Double BMI_NORMAL = 25.0;
    static Double BMI_OVERWEIGHT = 30.0;
    static Double BMI_OBESE = 35.0;
    static Double BMI_SEVERELY_OBESE = 40.0;
    static Map<BahmniObservation, BahmniObservation> obsParentMap = new HashMap<BahmniObservation, BahmniObservation>();
    static Map<String,String> formNames = new HashMap<String, String>();

    public static enum BmiStatus {
        VERY_SEVERELY_UNDERWEIGHT("Very Severely Underweight"),
        SEVERELY_UNDERWEIGHT("Severely Underweight"),
        UNDERWEIGHT("Underweight"),
        NORMAL("Normal"),
        OVERWEIGHT("Overweight"),
        OBESE("Obese"),
        SEVERELY_OBESE("Severely Obese"),
        VERY_SEVERELY_OBESE("Very Severely Obese");

        private String status;

        BmiStatus(String status) {
            this.status = status
        }

        @Override
        public String toString() {
            return status;
        }
    }

    public void run(BahmniEncounterTransaction bahmniEncounterTransaction) {
        formNames.put("Serious Adverse Events Template", "SAE Form, Date of SAE report");
        formNames.put("SAE Form, SAE outcome ( from PV unit summary)", "SAE Form, Event end date");
        formNames.put("AE Form, Adverse Event details", "AE Form, Date of AE report");
        calculateAndAdd(bahmniEncounterTransaction);
        changeObsDateTime(bahmniEncounterTransaction);
    }

    static def changeObsDateTime(BahmniEncounterTransaction bahmniEncounterTransaction){
        for (BahmniObservation formName : bahmniEncounterTransaction.getObservations()) {
            changeObservationDateTime(formName);
        }
        return bahmniEncounterTransaction;
    }

    static def changeObservationDateTime(BahmniObservation observation){
        if(observation.getGroupMembers().size() != 0) {
            for(BahmniObservation groupMember : observation.getGroupMembers()) {
                changeObservationDateTime(groupMember);
            }
        }
        if(formNames.get(observation.getConcept().getName())){
            Collection<BahmniObservation> observations = new TreeSet<BahmniObservation>();
            observations.add(observation);
            BahmniObservation dateObs = find(formNames.get(observation.getConcept().getName()), observations, null);

            if(dateObs){
                String target = dateObs.getValueAsString();
                DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
                Date result =  df.parse(target);


                changeDateTime(observation, result);
            }
        }
    }

    static def changeDateTime(BahmniObservation observation, Date result){
        if(observation.getGroupMembers().size() != 0) {
            for(BahmniObservation groupMember : observation.getGroupMembers()) {
                if(!formNames.get(groupMember.getConcept().getName()))
                    changeDateTime(groupMember, result);
            }
        }
        observation.setObservationDateTime(result);
    }

static def calculateAndAdd(BahmniEncounterTransaction bahmniEncounterTransaction) {
    Collection<BahmniObservation> observations = bahmniEncounterTransaction.getObservations()
    def nowAsOfEncounter = bahmniEncounterTransaction.getEncounterDateTime() != null ? bahmniEncounterTransaction.getEncounterDateTime() : new Date();

    BahmniObservation heightObservation = find("Height (cm)", observations, null)
    BahmniObservation weightObservation = find("Weight (kg)", observations, null)
    BahmniObservation parent = null;

    if (hasValue(heightObservation) || hasValue(weightObservation)) {
        BahmniObservation bmiDataObservation = find("BMI Data", observations, null)
        BahmniObservation bmiObservation = find("Body mass index", bmiDataObservation ? [bmiDataObservation] : [], null)
        BahmniObservation bmiAbnormalObservation = find("BMI Abnormal", bmiDataObservation ? [bmiDataObservation]: [], null)

        BahmniObservation bmiStatusDataObservation = find("BMI Status Data", observations, null)
        BahmniObservation bmiStatusObservation = find("BMI Status", bmiStatusDataObservation ? [bmiStatusDataObservation] : [], null)
        BahmniObservation bmiStatusAbnormalObservation = find("BMI Status Abnormal", bmiStatusDataObservation ? [bmiStatusDataObservation]: [], null)

        Patient patient = Context.getPatientService().getPatientByUuid(bahmniEncounterTransaction.getPatientUuid())
        def patientAgeInMonthsAsOfEncounter = Months.monthsBetween(new LocalDate(patient.getBirthdate()), new LocalDate(nowAsOfEncounter)).getMonths()

        parent = obsParent(heightObservation, parent)
        parent = obsParent(weightObservation, parent)

        if ((heightObservation && heightObservation.voided) && (weightObservation && weightObservation.voided)) {
            voidObs(bmiDataObservation);
            voidObs(bmiObservation);
            voidObs(bmiStatusDataObservation);
            voidObs(bmiStatusObservation);
            voidObs(bmiAbnormalObservation);
            return
        }

        def previousHeightValue = fetchLatestValue("Height (cm)", bahmniEncounterTransaction.getPatientUuid(), heightObservation, nowAsOfEncounter)
        def previousWeightValue = fetchLatestValue("Weight (kg)", bahmniEncounterTransaction.getPatientUuid(), weightObservation, nowAsOfEncounter)

        Double height = hasValue(heightObservation) && !heightObservation.voided ? heightObservation.getValue() as Double : previousHeightValue
        Double weight = hasValue(weightObservation) && !weightObservation.voided ? weightObservation.getValue() as Double : previousWeightValue
        Date obsDatetime = getDate(weightObservation) != null ? getDate(weightObservation) : getDate(heightObservation)

        if (height == null || weight == null) {
            voidObs(bmiDataObservation)
            voidObs(bmiObservation)
            voidObs(bmiStatusDataObservation)
            voidObs(bmiStatusObservation)
            voidObs(bmiAbnormalObservation)
            return
        }

        bmiDataObservation = bmiDataObservation ?: createObs("BMI Data", parent, bahmniEncounterTransaction, obsDatetime) as BahmniObservation
        bmiStatusDataObservation = bmiStatusDataObservation ?: createObs("BMI Status Data", parent, bahmniEncounterTransaction, obsDatetime) as BahmniObservation

        def bmi = bmi(height, weight)
        bmiObservation = bmiObservation ?: createObs("Body mass index", bmiDataObservation, bahmniEncounterTransaction, obsDatetime) as BahmniObservation;
        bmiObservation.setValue(bmi);

        def bmiStatus = bmiStatus(bmi, patientAgeInMonthsAsOfEncounter, patient.getGender());
        bmiStatusObservation = bmiStatusObservation ?: createObs("BMI Status", bmiStatusDataObservation, bahmniEncounterTransaction, obsDatetime) as BahmniObservation;
        bmiStatusObservation.setValue(bmiStatus);

        def bmiAbnormal = bmiAbnormal(bmiStatus);
        bmiAbnormalObservation =  bmiAbnormalObservation ?: createObs("BMI Abnormal", bmiDataObservation, bahmniEncounterTransaction, obsDatetime) as BahmniObservation;
        bmiAbnormalObservation.setValue(bmiAbnormal);

        bmiStatusAbnormalObservation =  bmiStatusAbnormalObservation ?: createObs("BMI Status Abnormal", bmiStatusDataObservation, bahmniEncounterTransaction, obsDatetime) as BahmniObservation;
        bmiStatusAbnormalObservation.setValue(bmiAbnormal);

    }

   
    BahmniObservation idealTreatmentDaysObservation = find("MTC, Ideal total treatment days in the month", observations, null)
    BahmniObservation nonPrescribedDaysObservation = find("MTC, Non prescribed days", observations, null)
    BahmniObservation missedPrescribedDaysObservation = find("MTC, Missed prescribed days", observations, null)
    BahmniObservation inCompletePrescribedDaysObservation = find("MTC, Incomplete prescribed days", observations, null)

    def fullyObservedCompleteDaysConceptName = "MTC, Total fully observed complete days"
    def completenessRateConceptName = "MTC, Completeness rate"
    def adherenceRateConceptName = "MTC, Adherence rate"
    BahmniObservation fullyObservedDaysObs = find(fullyObservedCompleteDaysConceptName, observations, null)
    BahmniObservation completenessRateObs = find(completenessRateConceptName, observations, null)
    BahmniObservation adherenceRateObs = find(adherenceRateConceptName, observations, null)

    if (hasValue(idealTreatmentDaysObservation) && hasValue(nonPrescribedDaysObservation) 
        && hasValue(missedPrescribedDaysObservation) 
        && hasValue(inCompletePrescribedDaysObservation)) {
        
        parent = obsParent(idealTreatmentDaysObservation, null)

        Date obsDatetime = getDate(idealTreatmentDaysObservation)
        def idealTreatmentDays = idealTreatmentDaysObservation.getValue() as Double
        def nonPrescribedDays = nonPrescribedDaysObservation.getValue() as Double
        def missedPrescribedDays = missedPrescribedDaysObservation.getValue() as Double
        def inCompletePrescribedDays = inCompletePrescribedDaysObservation.getValue() as Double
        def fullyObservedDays = idealTreatmentDays - (nonPrescribedDays + missedPrescribedDays + inCompletePrescribedDays) as Double
        def completenessRate = (fullyObservedDays / idealTreatmentDays) * 100 as Double
        def adherenceRate = fullyObservedDays / (idealTreatmentDays - nonPrescribedDays) as Double
        if (fullyObservedDaysObs == null)
            fullyObservedDaysObs = createObs(fullyObservedCompleteDaysConceptName, parent, bahmniEncounterTransaction, obsDatetime) as BahmniObservation
        fullyObservedDaysObs.setValue(fullyObservedDays)

        if(completenessRateObs == null)
            completenessRateObs = createObs(completenessRateConceptName, parent, bahmniEncounterTransaction, obsDatetime) as BahmniObservation
        completenessRateObs.setValue(completenessRate)

        if(adherenceRateObs == null)
            adherenceRateObs = createObs(adherenceRateConceptName, parent, bahmniEncounterTransaction, obsDatetime) as BahmniObservation
        adherenceRateObs.setValue(adherenceRate)    
    }
    if(hasValue(idealTreatmentDaysObservation) && hasValue(fullyObservedDaysObs)){
        parent = obsParent(idealTreatmentDaysObservation, null)
        Date obsDatetime = getDate(idealTreatmentDaysObservation)
        def idealTreatmentDays = idealTreatmentDaysObservation.getValue() as Double
        def fullyObservedDays = fullyObservedDaysObs.getValue() as Double
        def completenessRate = (fullyObservedDays / idealTreatmentDays) * 100 as Double
        if(completenessRateObs == null)
            completenessRateObs = createObs(completenessRateConceptName, parent, bahmniEncounterTransaction, obsDatetime) as BahmniObservation
        completenessRateObs.setValue(completenessRate)
        if(hasValue(nonPrescribedDaysObservation)){
            def nonPrescribedDays = nonPrescribedDaysObservation.getValue() as Double
            def adherenceRate = fullyObservedDays / (idealTreatmentDays - nonPrescribedDays) as Double
            if(adherenceRateObs == null)
                adherenceRateObs = createObs(adherenceRateConceptName, parent, bahmniEncounterTransaction, obsDatetime) as BahmniObservation
            adherenceRateObs.setValue(adherenceRate)    
        }
    }

    BahmniObservation observedDaysObs = find("MTC, Drug observed days", observations, null)
    BahmniObservation prescribedDaysObs = find("MTC, Drug prescribed days", observations, null)

    def dotsRateConceptName = "MTC, DOTs rate"
    BahmniObservation dotsRateObs = find(dotsRateConceptName, observations, null)

    if(hasValue(observedDaysObs) && hasValue(prescribedDaysObs)){
        parent = obsParent(observedDaysObs, null)
        Date obsDatetime = getDate(observedDaysObs)
        def observedDays = observedDaysObs.getValue() as Double
        def prescribedDays = prescribedDaysObs.getValue() as Double
        def dotsRate = (observedDays / prescribedDays) * 100 as Double
        if(dotsRateObs == null)
            dotsRateObs = createObs(dotsRateConceptName, parent, bahmniEncounterTransaction, obsDatetime) as BahmniObservation   
        dotsRateObs.setValue(dotsRate) 
        return
    }
}

private static BahmniObservation obsParent(BahmniObservation child, BahmniObservation parent) {
    if (parent != null) return parent;

    if(child != null) {
        return obsParentMap.get(child)
    }
}

private static Date getDate(BahmniObservation observation) {
    return hasValue(observation) && !observation.voided ? observation.getObservationDateTime() : null;
}

private static boolean hasValue(BahmniObservation observation) {
    return observation != null && observation.getValue() != null && !StringUtils.isEmpty(observation.getValue().toString());
}

private static void voidObs(BahmniObservation bmiObservation) {
    if (hasValue(bmiObservation)) {
        bmiObservation.voided = true
    }
}

static BahmniObservation createObs(String conceptName, BahmniObservation parent, BahmniEncounterTransaction encounterTransaction, Date obsDatetime) {
    def concept = Context.getConceptService().getConceptByName(conceptName)
    BahmniObservation newObservation = new BahmniObservation()
    newObservation.setConcept(new EncounterTransaction.Concept(concept.getUuid(), conceptName))
    newObservation.setObservationDateTime(obsDatetime);
    parent == null ? encounterTransaction.addObservation(newObservation) : parent.addGroupMember(newObservation)
    return newObservation
}

static def bmi(Double height, Double weight) {
    Double heightInMeters = height / 100;
    Double value = weight / (heightInMeters * heightInMeters);
    return new BigDecimal(value).setScale(2, BigDecimal.ROUND_HALF_UP).doubleValue();
};

static def bmiStatus(Double bmi, Integer ageInMonth, String gender) {
    BMIChart bmiChart = readCSV(OpenmrsUtil.getApplicationDataDirectory() + "obscalculator/BMI_chart.csv");
    def bmiChartLine = bmiChart.get(gender, ageInMonth);
    if(bmiChartLine != null ) {
        return bmiChartLine.getStatus(bmi);
    }

    if (bmi < BMI_VERY_SEVERELY_UNDERWEIGHT) {
        return BmiStatus.VERY_SEVERELY_UNDERWEIGHT;
    }
    if (bmi < BMI_SEVERELY_UNDERWEIGHT) {
        return BmiStatus.SEVERELY_UNDERWEIGHT;
    }
    if (bmi < BMI_UNDERWEIGHT) {
        return BmiStatus.UNDERWEIGHT;
    }
    if (bmi < BMI_NORMAL) {
        return BmiStatus.NORMAL;
    }
    if (bmi < BMI_OVERWEIGHT) {
        return BmiStatus.OVERWEIGHT;
    }
    if (bmi < BMI_OBESE) {
        return BmiStatus.OBESE;
    }
    if (bmi < BMI_SEVERELY_OBESE) {
        return BmiStatus.SEVERELY_OBESE;
    }
    if (bmi >= BMI_SEVERELY_OBESE) {
        return BmiStatus.VERY_SEVERELY_OBESE;
    }
    return null
}

static def bmiAbnormal(BmiStatus status) {
    return status != BmiStatus.NORMAL;
};

static Double fetchLatestValue(String conceptName, String patientUuid, BahmniObservation excludeObs, Date tillDate) {
    SessionFactory sessionFactory = Context.getRegisteredComponents(SessionFactory.class).get(0)
    def excludedObsIsSaved = excludeObs != null && excludeObs.uuid != null
    String excludeObsClause = excludedObsIsSaved ? " and obs.uuid != :excludeObsUuid" : ""
    Query queryToGetObservations = sessionFactory.getCurrentSession()
            .createQuery("select obs " +
            " from Obs as obs, ConceptName as cn " +
            " where obs.person.uuid = :patientUuid " +
            " and cn.concept = obs.concept.conceptId " +
            " and cn.name = :conceptName " +
            " and obs.voided = false" +
            " and obs.obsDatetime <= :till" +
            excludeObsClause +
            " order by obs.obsDatetime desc limit 1");
    queryToGetObservations.setString("patientUuid", patientUuid);
    queryToGetObservations.setParameterList("conceptName", conceptName);
    queryToGetObservations.setParameter("till", tillDate);
    if (excludedObsIsSaved) {
        queryToGetObservations.setString("excludeObsUuid", excludeObs.uuid)
    }
    List<Obs> observations = queryToGetObservations.list();
    if (observations.size() > 0) {
        return observations.get(0).getValueNumeric();
    }
    return null
}

static BahmniObservation find(String conceptName, Collection<BahmniObservation> observations, BahmniObservation parent) {
    for (BahmniObservation observation : observations) {
        if (conceptName.equalsIgnoreCase(observation.getConcept().getName())) {
            obsParentMap.put(observation, parent);
            return observation;
        }
        BahmniObservation matchingObservation = find(conceptName, observation.getGroupMembers(), observation)
        if (matchingObservation) return matchingObservation;
    }
    return null
}

static BMIChart readCSV(String fileName) {
    def chart = new BMIChart();
    try {
        new File(fileName).withReader { reader ->
            def header = reader.readLine();
            reader.splitEachLine(",") { tokens ->
                chart.add(new BMIChartLine(tokens[0], tokens[1], tokens[2], tokens[3], tokens[4], tokens[5]));
            }
        }
    } catch (FileNotFoundException e) {
    }
    return chart;
}

static class BMIChartLine {
    public String gender;
    public Integer ageInMonth;
    public Double third;
    public Double fifteenth;
    public Double eightyFifth;
    public Double ninetySeventh;

    BMIChartLine(String gender, String ageInMonth, String third, String fifteenth, String eightyFifth, String ninetySeventh) {
        this.gender = gender
        this.ageInMonth = ageInMonth.toInteger();
        this.third = third.toDouble();
        this.fifteenth = fifteenth.toDouble();
        this.eightyFifth = eightyFifth.toDouble();
        this.ninetySeventh = ninetySeventh.toDouble();
    }

    public BmiStatus getStatus(Double bmi) {
        if(bmi < third) {
            return BmiStatus.SEVERELY_UNDERWEIGHT
        } else if(bmi < fifteenth) {
            return BmiStatus.UNDERWEIGHT
        } else if(bmi < eightyFifth) {
            return BmiStatus.NORMAL
        } else if(bmi < ninetySeventh) {
            return BmiStatus.OVERWEIGHT
        } else {
            return BmiStatus.OBESE
        }
    }
}

static class BMIChart {
    List<BMIChartLine> lines;
    Map<BMIChartLineKey, BMIChartLine> map = new HashMap<BMIChartLineKey, BMIChartLine>();

    public add(BMIChartLine line) {
        def key = new BMIChartLineKey(line.gender, line.ageInMonth);
        map.put(key, line);
    }

    public BMIChartLine get(String gender, Integer ageInMonth) {
        def key = new BMIChartLineKey(gender, ageInMonth);
        return map.get(key);
    }
}

static class BMIChartLineKey {
    public String gender;
    public Integer ageInMonth;

    BMIChartLineKey(String gender, Integer ageInMonth) {
        this.gender = gender
        this.ageInMonth = ageInMonth
    }

    boolean equals(o) {
        if (this.is(o)) return true
        if (getClass() != o.class) return false

        BMIChartLineKey bmiKey = (BMIChartLineKey) o

        if (ageInMonth != bmiKey.ageInMonth) return false
        if (gender != bmiKey.gender) return false

        return true
    }

    int hashCode() {
        int result
        result = (gender != null ? gender.hashCode() : 0)
        result = 31 * result + (ageInMonth != null ? ageInMonth.hashCode() : 0)
        return result
    }
 }

}
