import org.apache.commons.lang.ObjectUtils
import org.apache.commons.lang.StringUtils
import org.bahmni.module.bahmnicore.service.impl.BahmniBridge
import org.joda.time.LocalDate
import org.joda.time.Months
import org.openmrs.Patient
import org.openmrs.api.context.Context
import org.openmrs.module.bahmniemrapi.BahmniEmrAPIException
import org.openmrs.module.bahmniemrapi.encountertransaction.contract.BahmniEncounterTransaction
import org.openmrs.module.bahmniemrapi.encountertransaction.contract.BahmniObservation
import org.openmrs.module.bahmniemrapi.obscalculator.ObsValueCalculator
import org.openmrs.module.emrapi.encounter.domain.EncounterTransaction
import org.openmrs.util.OpenmrsUtil

import java.text.DateFormat
import java.text.SimpleDateFormat

public class BahmniObsValueCalculator implements ObsValueCalculator {
    static Double BMI_VERY_SEVERELY_UNDERWEIGHT = 16.0;
    static Double BMI_SEVERELY_UNDERWEIGHT = 17.0;
    static Double BMI_UNDERWEIGHT = 18.5;
    static Double BMI_NORMAL = 25.0;
    static Double BMI_OVERWEIGHT = 30.0;
    static Double BMI_OBESE = 35.0;
    static Double BMI_SEVERELY_OBESE = 40.0;
    static Map<BahmniObservation, BahmniObservation> obsParentMap = new HashMap<BahmniObservation, BahmniObservation>();
    static Map<String, String> formNames;
    static BahmniBridge bahmniBridge = BahmniBridge.create();

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

    static {
        formNames = new HashMap<String, String>();
        formNames.put("Baseline Template", "Baseline, Date of baseline");
        formNames.put("Treatment Initiation Template", "TUBERCULOSIS DRUG TREATMENT START DATE");
        formNames.put("Followup Template", "Followup, Visit Date");
        formNames.put("Outcome End of Treatment Template", "Tuberculosis treatment end date");
        formNames.put("6 month Post Treatment Outcome Template", "6m PTO, 6 month post treatment outcome date");
        formNames.put("Adverse Events Template", "AE Form, Date of AE report");
        formNames.put("Serious Adverse Events Template", "SAE Form, Date of SAE report");
        formNames.put("Pregnancy Report Form Template", "PRF, Date reporter made aware of pregnancy");
        formNames.put("Hospital Admission Notification Template", "HAN, Hospital admission date");
        formNames.put("Hospital Discharge Summary Template", "HDS, Hospital discharge date");
        formNames.put("Lab Results Hemotology Template", "Specimen Collection Date");
        formNames.put("Lab Results Biochemistry Template", "Specimen Collection Date");
        formNames.put("Lab Results Serology Template", "Specimen Collection Date");
        formNames.put("Lab Results Pregnancy Template", "Specimen Collection Date");
        formNames.put("Lab Results Other Tests Template", "Specimen Collection Date");
        formNames.put("Xray Template", "Xray, Chest Xray Date");
        formNames.put("Audiometry Template", "Audiometry, Audiometry date");
        formNames.put("Electrocardiogram Template", "EKG, Date of EKG");
        formNames.put("Monthly Treatment Completeness Template", "MTC, Month and year of treatment period");
        formNames.put("Performance Status Template", "Performance Status, Assessment date");
    }

    public void run(BahmniEncounterTransaction bahmniEncounterTransaction) {
        List<String> conceptNames = Arrays.asList("Baseline, Clinical Examination", "Followup, Clinical Examination", "Monthly Treatment Completeness Template");
        Map<String,List<BahmniObservation>> bahmniObsConceptMap = new HashMap<String,List<BahmniObservation>>();
        findObsListForConcepts(conceptNames,bahmniEncounterTransaction.getObservations(),null,bahmniObsConceptMap);
        calculateAndAdd(bahmniEncounterTransaction, bahmniObsConceptMap);
        changeObsDateTime(bahmniEncounterTransaction);
    }

    static BahmniObservation findConceptInChildObs(String conceptName, parent) {
        if(parent == null)
            return null;

        for (BahmniObservation observation : parent.getGroupMembers()) {
            if (conceptName.equalsIgnoreCase(observation.getConcept().getName()) && !observation.getVoided()) {
                return observation;
            }
        }
        return null
    }

    static List<BahmniObservation> findListOfObservationsInChildObs(String conceptName, parent) {
        List<BahmniObservation> obsList = new ArrayList<BahmniObservation>();
        if(parent == null)
            return obsList;

        for (BahmniObservation observation : parent.getGroupMembers()) {
            if (conceptName.equalsIgnoreCase(observation.getConcept().getName()) && !observation.getVoided()) {
                obsList.add(observation);
            }
        }
        return obsList;
    }

    static def getNumericValue(BahmniObservation bahmniObservation) {
        return hasValue(bahmniObservation) && !bahmniObservation.voided ? bahmniObservation.getValue() as Double : 0;
    }

    static def getBooleanValue(BahmniObservation bahmniObservation) {
        return hasValue(bahmniObservation) && !bahmniObservation.voided ? bahmniObservation.getValue() as Boolean : false;
    }

    static def changeObsDateTime(BahmniEncounterTransaction bahmniEncounterTransaction) {
        for (BahmniObservation formName : bahmniEncounterTransaction.getObservations()) {
            changeObservationDateTime(formName);
        }
    }

    static def changeObservationDateTime(BahmniObservation observation) {
        if (observation.getGroupMembers().size() != 0) {
            for (BahmniObservation groupMember : observation.getGroupMembers()) {
                changeObservationDateTime(groupMember);
            }
        }
        if (formNames.get(observation.getConcept().getName())) {
            Collection<BahmniObservation> observations = new TreeSet<BahmniObservation>();
            observations.add(observation);
            BahmniObservation dateObs = find(formNames.get(observation.getConcept().getName()), observations, null);

            if (dateObs && dateObs.getValueAsString()!= "") {
                String target = dateObs.getValueAsString();
                String timezoneInfo = new Date().format("'T'HH:mm:ss.SSSZ");
                String dateWithTimeZoneInfo = target + timezoneInfo;
                DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ");
                Date result = df.parse(dateWithTimeZoneInfo);

                changeDateTime(observation, result);
            }
        }
    }

    static def changeDateTime(BahmniObservation observation, Date result) {
        if (observation.getGroupMembers().size() != 0) {
            for (BahmniObservation groupMember : observation.getGroupMembers()) {
                if (!formNames.get(groupMember.getConcept().getName()))
                    changeDateTime(groupMember, result);
            }
        }
        observation.setObservationDateTime(result);
    }

    static def calculateAndAdd(BahmniEncounterTransaction bahmniEncounterTransaction, Map<String,List<BahmniObservation>> bahmniObsConceptMap) {
        Collection<BahmniObservation> observations = bahmniEncounterTransaction.getObservations()

        calculateBMI("Baseline, Clinical Examination", observations, bahmniEncounterTransaction, bahmniObsConceptMap)
        calculateBMI("Followup, Clinical Examination", observations, bahmniEncounterTransaction, bahmniObsConceptMap)

        calculateMTC(bahmniObsConceptMap.get("Monthly Treatment Completeness Template"), bahmniEncounterTransaction)
    }

    private
    static void calculateMTC(List<BahmniObservation> bahmniObsList, BahmniEncounterTransaction bahmniEncounterTransaction) {
        for (BahmniObservation bahmniObs : bahmniObsList) {
            BahmniObservation idealTreatmentDaysObservation = findConceptInChildObs("MTC, Ideal total treatment days in the month", bahmniObs)
            BahmniObservation nonPrescribedDaysObservation = findConceptInChildObs("MTC, Non prescribed days", bahmniObs)
            BahmniObservation missedPrescribedDaysObservation = findConceptInChildObs("MTC, Missed prescribed days", bahmniObs)
            BahmniObservation inCompletePrescribedDaysObservation = findConceptInChildObs("MTC, Incomplete prescribed days", bahmniObs)

            if (hasValue(idealTreatmentDaysObservation) && hasValue(nonPrescribedDaysObservation)
                    && hasValue(missedPrescribedDaysObservation)
                    && hasValue(inCompletePrescribedDaysObservation)) {

                def fullyObservedCompleteDaysConceptName = "MTC, Total fully observed complete days"
                def completenessRateConceptName = "MTC, Completeness rate"
                def adherenceRateConceptName = "MTC, Adherence rate"

                BahmniObservation monthlyCalculations = findConceptInChildObs("MTC, Monthly calculations", bahmniObs);

                BahmniObservation fullyObservedDaysObs = findConceptInChildObs(fullyObservedCompleteDaysConceptName, monthlyCalculations)
                BahmniObservation completenessRateObs = findConceptInChildObs(completenessRateConceptName, monthlyCalculations)
                BahmniObservation adherenceRateObs = findConceptInChildObs(adherenceRateConceptName, monthlyCalculations)

                Date obsDatetime = getDate(idealTreatmentDaysObservation)

                if (monthlyCalculations == null) {
                    monthlyCalculations = createObs('MTC, Monthly calculations', bahmniObs, bahmniEncounterTransaction, obsDatetime)
                } else {
                    voidObs(fullyObservedDaysObs);
                    voidObs(completenessRateObs);
                    voidObs(adherenceRateObs);
                    fullyObservedDaysObs = null;
                    completenessRateObs = null;
                    adherenceRateObs = null;
                }

                def idealTreatmentDays = idealTreatmentDaysObservation.getValue() as Double
                def nonPrescribedDays = nonPrescribedDaysObservation.getValue() as Double
                def missedPrescribedDays = missedPrescribedDaysObservation.getValue() as Double
                def inCompletePrescribedDays = inCompletePrescribedDaysObservation.getValue() as Double
                def completenessRate
                def adherenceRateDenominator
                def adherenceRate

                def fullyObservedDays = idealTreatmentDays - (nonPrescribedDays + missedPrescribedDays + inCompletePrescribedDays) as Double
                try{
                    if(fullyObservedDays < 0) {
                        throw new Exception()
                    }
                } catch(Exception e){
                    throw new BahmniEmrAPIException("Please enter correct data. The sum of non prescribed, missed, incomplete days cannot be more than Ideal days")
                }

                if (idealTreatmentDays == 0 || idealTreatmentDays == nonPrescribedDays) {
                    completenessRate = 0
                    adherenceRate = 100
                } else{
                    completenessRate = (fullyObservedDays / idealTreatmentDays) * 100 as Double
                    adherenceRateDenominator = (idealTreatmentDays - nonPrescribedDays) as Double
                    adherenceRate = (fullyObservedDays / adherenceRateDenominator) * 100 as Double
                }

                if (fullyObservedDaysObs == null)
                    fullyObservedDaysObs = createObs(fullyObservedCompleteDaysConceptName, monthlyCalculations, bahmniEncounterTransaction, obsDatetime) as BahmniObservation
                fullyObservedDaysObs.setValue(fullyObservedDays)

                if (completenessRateObs == null)
                    completenessRateObs = createObs(completenessRateConceptName, monthlyCalculations, bahmniEncounterTransaction, obsDatetime) as BahmniObservation
                completenessRateObs.setValue(Math.round(completenessRate * 100.0) / 100.0)

                if (adherenceRateObs == null)
                    adherenceRateObs = createObs(adherenceRateConceptName, monthlyCalculations, bahmniEncounterTransaction, obsDatetime) as BahmniObservation
                adherenceRateObs.setValue(Math.round(adherenceRate * 100.0) / 100.0)
            }

            def totalDotRate = 0;
            def dotRateCount = 0;
            for (BahmniObservation dotRateDetailsObs : findListOfObservationsInChildObs("MTC, DOT rate details", bahmniObs)) {
                BahmniObservation observedDaysObs = findConceptInChildObs("MTC, Drug observed days", dotRateDetailsObs)
                BahmniObservation prescribedDaysObs = findConceptInChildObs("MTC, Drug prescribed days", dotRateDetailsObs)
                BahmniObservation missedDaysObs = findConceptInChildObs("MTC, Drug missed days", dotRateDetailsObs)

                def dotRateConceptName = "MTC, DOT rate"
                BahmniObservation dotRateObs = findConceptInChildObs(dotRateConceptName, dotRateDetailsObs)

                if (hasValue(prescribedDaysObs)) {
                    def prescribedDays = prescribedDaysObs.getValue() as Double
                    def dotRate
                    try {
                        if (prescribedDays == 0) {
                            throw new Exception()
                        }
                    } catch (Exception E) {
                        throw new BahmniEmrAPIException("Value for MTC, Drug prescribed days is equal to zero")
                    }

                    if (hasValue(observedDaysObs)) {
                        Date obsDatetime = getDate(observedDaysObs)
                        def observedDays = observedDaysObs.getValue() as Double
                        dotRate = (observedDays / prescribedDays) * 100 as Double
                        dotRateObs = setDotRateObs(dotRateObs, dotRateConceptName, dotRateDetailsObs, bahmniEncounterTransaction, obsDatetime, dotRate)
                    } else if (hasValue(missedDaysObs)) {
                        Date obsDatetime = getDate(missedDaysObs)
                        def missedDays = missedDaysObs.getValue() as Double
                        dotRate = ((prescribedDays - missedDays) /prescribedDays) * 100 as Double
                        dotRateObs = setDotRateObs(dotRateObs, dotRateConceptName, dotRateDetailsObs, bahmniEncounterTransaction, obsDatetime, dotRate)
                    }
                }

                if(dotRateObs!=null) {
                    totalDotRate += dotRateObs.getValue() as Double
                    dotRateCount ++;
                }
            }

            def overallDotRate = findConceptInChildObs("MTC, Overall DOT Rate", bahmniObs)
            if (dotRateCount > 0) {
                if (overallDotRate == null) {
                    overallDotRate = createObs("MTC, Overall DOT Rate", bahmniObs, bahmniEncounterTransaction, bahmniObs.getObservationDateTime()) as BahmniObservation
                }
                overallDotRate.setValue(Math.round((totalDotRate * 100.0 / dotRateCount)) / 100.0)
            }
            else {
                voidObs(overallDotRate)
            }
        }
    }

    private
    static BahmniObservation setDotRateObs(BahmniObservation dotRateObs, String dotRateConceptName, BahmniObservation dotRateDetailsObs, BahmniEncounterTransaction bahmniEncounterTransaction, Date obsDatetime, double dotRate) {
        if (dotRateObs == null) {
            dotRateObs = createObs(dotRateConceptName, dotRateDetailsObs, bahmniEncounterTransaction, obsDatetime) as BahmniObservation
        }
        dotRateObs.setValue(Math.round(dotRate * 100.0) / 100.0)
        return dotRateObs
    }

    private
    static void calculateBMI(String templateName, Collection<BahmniObservation> observations, BahmniEncounterTransaction bahmniEncounterTransaction, Map<String, List<BahmniObservation>> bahmniObsConceptMap) {
        Collection<BahmniObservation> templateObservations = bahmniObsConceptMap.get(templateName)
        BahmniObservation heightObservation, weightObservation, parent;
        for (int i=0; templateObservations && i< templateObservations.size(); i++) {
            if (templateObservations != null && templateObservations.size() > 0) {
                parent = templateObservations.get(i);
                heightObservation = findConceptInChildObs("Height (cm)", parent)
                weightObservation = findConceptInChildObs("Weight (kg)", parent)
            }
            if (heightObservation == null && weightObservation == null) {
                BahmniObservation bmiDataObservation = findConceptInChildObs("BMI Data", parent)
                BahmniObservation bmiObservation = findConceptInChildObs("Body mass index", bmiDataObservation)
                BahmniObservation bmiAbnormalObservation = findConceptInChildObs("BMI Abnormal", bmiDataObservation)
                voidObs(bmiDataObservation);
                voidObs(bmiObservation);
                voidObs(bmiAbnormalObservation);
                continue;
            }
            calculateBMIWithHeightAndWeight(bahmniEncounterTransaction, parent, heightObservation, weightObservation);
        }
    }


    static
    def calculateBMIWithHeightAndWeight(BahmniEncounterTransaction bahmniEncounterTransaction, BahmniObservation parent, BahmniObservation heightObservation, BahmniObservation weightObservation) {
        def nowAsOfEncounter = bahmniEncounterTransaction.getEncounterDateTime() != null ? bahmniEncounterTransaction.getEncounterDateTime() : new Date();

        if (hasValue(heightObservation) || hasValue(weightObservation)) {
            BahmniObservation bmiDataObservation = findConceptInChildObs("BMI Data", parent)
            BahmniObservation bmiObservation = findConceptInChildObs("Body mass index", bmiDataObservation)
            BahmniObservation bmiAbnormalObservation = findConceptInChildObs("BMI Abnormal", bmiDataObservation)

            Patient patient = Context.getPatientService().getPatientByUuid(bahmniEncounterTransaction.getPatientUuid())
            def patientAgeInMonthsAsOfEncounter = Months.monthsBetween(new LocalDate(patient.getBirthdate()), new LocalDate(nowAsOfEncounter)).getMonths()



            if ((heightObservation && heightObservation.voided) && (weightObservation && weightObservation.voided)) {
                voidObs(bmiDataObservation);
                voidObs(bmiObservation);
                voidObs(bmiAbnormalObservation);
                return
            }


            def patientProgramUuid = bahmniEncounterTransaction.getPatientProgramUuid()
            bahmniBridge.forPatientProgram(patientProgramUuid);

            Double height = hasValue(heightObservation) ? heightObservation.getValue() as Double: null
            Double weight = hasValue(weightObservation) ? weightObservation.getValue() as Double : null
            Date obsDatetime = getDate(weightObservation) != null ? getDate(weightObservation) : getDate(heightObservation)

            if (height == null || weight == null) {
                voidObs(bmiDataObservation)
                voidObs(bmiObservation)
                voidObs(bmiAbnormalObservation)
                return
            }

            if(hasValue(heightObservation) && hasValue(weightObservation)){
                bmiDataObservation = bmiDataObservation ?: createObs("BMI Data", parent, bahmniEncounterTransaction, obsDatetime) as BahmniObservation

                def bmi = bmi(height, weight)
                bmiObservation = bmiObservation ?: createObs("Body mass index", bmiDataObservation, bahmniEncounterTransaction, obsDatetime) as BahmniObservation;
                Double roundOffBMI = Math.round(bmi * 100.0) / 100.0;
                bmiObservation.setValue(roundOffBMI);

                def bmiStatus = bmiStatus(bmi, patientAgeInMonthsAsOfEncounter, patient.getGender());

                def bmiAbnormal = bmiAbnormal(bmiStatus);
                bmiAbnormalObservation = bmiAbnormalObservation ?: createObs("BMI Abnormal", bmiDataObservation, bahmniEncounterTransaction, obsDatetime) as BahmniObservation;
                bmiAbnormalObservation.setValue(bmiAbnormal);
            }

        }
    }

    private static BahmniObservation obsParent(BahmniObservation child, BahmniObservation parent) {
        if (parent != null) return parent;

        if (child != null) {
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
        def concept = bahmniBridge.getConceptByFullySpecifiedName(conceptName)
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
        if (bmiChartLine != null) {
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

    static void findObsListForConcepts(List<String> conceptNames, Collection<BahmniObservation> observations, BahmniObservation parent,Map<String,List<BahmniObservation>> bahmniObsConceptMap) {
        for (BahmniObservation observation : observations) {
            if (conceptNames.contains(observation.getConcept().getName()) && !observation.getVoided()) {
                List<BahmniObservation> obsList =  ObjectUtils.defaultIfNull(bahmniObsConceptMap.get(observation.getConcept().getName()),new ArrayList<BahmniObservation>());
                obsList.add(observation);
                bahmniObsConceptMap.put(observation.getConcept().getName(),obsList);
            }
            findObsListForConcepts(conceptNames, observation.getGroupMembers(), observation,bahmniObsConceptMap)
        }
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
            if (bmi < third) {
                return BmiStatus.SEVERELY_UNDERWEIGHT
            } else if (bmi < fifteenth) {
                return BmiStatus.UNDERWEIGHT
            } else if (bmi < eightyFifth) {
                return BmiStatus.NORMAL
            } else if (bmi < ninetySeventh) {
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
