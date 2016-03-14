import org.apache.commons.lang.ObjectUtils
import org.apache.commons.lang.StringUtils
import org.bahmni.module.bahmnicore.service.impl.BahmniBridge
import org.hibernate.Query
import org.hibernate.SessionFactory
import org.openmrs.Obs
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
import org.joda.time.LocalDate
import org.joda.time.Months

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
        List<String> conceptNames = Arrays.asList("Lab, Hemoglobin","Lab, RBC count","Lab, WBC","Lab, Potassium","Lab, Magnesium","Lab, Ionized Calcium","Lab, Urea","Lab, Creatinine","Lab, Glucose (Fasting)","Lab, Glucose","Lab, Total Bilirubin", "Baseline, Clinical Examination", "Followup, Clinical Examination", "Monthly Treatment Completeness Template");
        Map<String,List<BahmniObservation>> bahmniObsConceptMap = new HashMap<String,List<BahmniObservation>>();
        findObsListForConcepts(conceptNames,bahmniEncounterTransaction.getObservations(),null,bahmniObsConceptMap);
        calculateAndAdd(bahmniEncounterTransaction, bahmniObsConceptMap);
        changeObsDateTime(bahmniEncounterTransaction);
        convertUnits(bahmniEncounterTransaction,bahmniObsConceptMap);
    }

    static def convertUnits(BahmniEncounterTransaction bahmniEncounterTransaction,Map<String,List<BahmniObservation>> bahmniObsConceptMap) {

        //Hemoglobin
        calculateAlternateObs(bahmniEncounterTransaction,bahmniObsConceptMap.get("Lab, Hemoglobin"),"Lab, Hemoglobin mmol/L Data", "Lab, Hemoglobin mmol/L", "Lab, Hemoglobin mmol/L Abnormal", "Lab, Hemoglobin Data", "Hemoglobin", "Hemoglobin Abnormal", 1.61);
        calculateAlternateObs(bahmniEncounterTransaction,bahmniObsConceptMap.get("Lab, Hemoglobin"),"Lab, Hemoglobin Data", "Hemoglobin", "Hemoglobin Abnormal", "Lab, Hemoglobin mmol/L Data", "Lab, Hemoglobin mmol/L", "Lab, Hemoglobin mmol/L Abnormal", 1 / 1.61);

        //RBC count
        calculateAlternateObs(bahmniEncounterTransaction,bahmniObsConceptMap.get("Lab, RBC count"), "Lab, RBC with other unit Data", "Lab, RBC with other unit", "Lab, RBC with other unit Abnormal", "Lab, RED BLOOD CELLS Data", "RED BLOOD CELLS", "RED BLOOD CELLS Abnormal", 1000000);
        calculateAlternateObs(bahmniEncounterTransaction,bahmniObsConceptMap.get("Lab, RBC count"),"Lab, RED BLOOD CELLS Data", "RED BLOOD CELLS", "RED BLOOD CELLS Abnormal", "Lab, RBC with other unit Data", "Lab, RBC with other unit", "Lab, RBC with other unit Abnormal", 1 / 1000000);
        
        //WBC count
        calculateAlternateObs(bahmniEncounterTransaction, bahmniObsConceptMap.get("Lab, WBC"),"Lab, WHITE BLOOD CELLS Data", "WHITE BLOOD CELLS", "WHITE BLOOD CELLS Abnormal", "Lab, WBC other unit Data", "Lab, WBC other unit", "Lab, WBC other unit Abnormal", 1000);
        calculateAlternateObs(bahmniEncounterTransaction, bahmniObsConceptMap.get("Lab, WBC"),"Lab, WBC other unit Data", "Lab, WBC other unit", "Lab, WBC other unit Abnormal", "Lab, WHITE BLOOD CELLS Data", "WHITE BLOOD CELLS", "WHITE BLOOD CELLS Abnormal", 1 / 1000);

        //Potassium
        calculateAlternateObs(bahmniEncounterTransaction,bahmniObsConceptMap.get("Lab, Potassium"), "Lab, SERUM POTASSIUM Data", "SERUM POTASSIUM", "SERUM POTASSIUM Abnormal", "Lab, Potassium other Data", "Lab, Potassium other", "Lab, Potassium other Abnormal", 3.91);
        calculateAlternateObs(bahmniEncounterTransaction,bahmniObsConceptMap.get("Lab, Potassium"), "Lab, Potassium other Data", "Lab, Potassium other", "Lab, Potassium other Abnormal", "Lab, SERUM POTASSIUM Data", "SERUM POTASSIUM", "SERUM POTASSIUM Abnormal", 1 / 3.91);

        //Magnesium
        calculateAlternateObs(bahmniEncounterTransaction,bahmniObsConceptMap.get("Lab, Magnesium") ,"Lab, Magnesium other Data", "Lab, Magnesium other", "Lab, Magnesium other Abnormal", "Lab, Magnesium test result Data", "Lab, Magnesium test result", "Lab, Magnesium test result Abnormal", 1 / 0.41);
        calculateAlternateObs(bahmniEncounterTransaction,bahmniObsConceptMap.get("Lab, Magnesium") ,"Lab, Magnesium test result Data", "Lab, Magnesium test result", "Lab, Magnesium test result Abnormal", "Lab, Magnesium other Data", "Lab, Magnesium other", "Lab, Magnesium other Abnormal", 0.41);

        //Ionised calcium
        calculateAlternateObs(bahmniEncounterTransaction,bahmniObsConceptMap.get("Lab, Ionized Calcium") ,"Lab, Ionized Calcium test result Data", "Lab, Ionized Calcium test result", "Lab, Ionized Calcium test result Abnormal", "Lab, Ionized Calcium other Data", "Lab, Ionized Calcium other", "Lab, Ionized Calcium other Abnormal", 4);
        calculateAlternateObs(bahmniEncounterTransaction,bahmniObsConceptMap.get("Lab, Ionized Calcium") ,"Lab, Ionized Calcium other Data", "Lab, Ionized Calcium other", "Lab, Ionized Calcium other Abnormal", "Lab, Ionized Calcium test result Data", "Lab, Ionized Calcium test result", "Lab, Ionized Calcium test result Abnormal", 1 / 4);

        //Urea
        calculateAlternateObs(bahmniEncounterTransaction,bahmniObsConceptMap.get("Lab, Urea"), "Lab, BLOOD UREA NITROGEN Data", "BLOOD UREA NITROGEN", "BLOOD UREA NITROGEN Abnormal", "Lab, Urea other Data", "Lab, Urea other", "Lab, Urea other Abnormal", 2.80);
        calculateAlternateObs(bahmniEncounterTransaction,bahmniObsConceptMap.get("Lab, Urea"), "Lab, Urea other Data", "Lab, Urea other", "Lab, Urea other Abnormal", "Lab, BLOOD UREA NITROGEN Data", "BLOOD UREA NITROGEN", "BLOOD UREA NITROGEN Abnormal", 1 / 2.80);

        //Creatinine
        calculateAlternateObs(bahmniEncounterTransaction,bahmniObsConceptMap.get("Lab, Creatinine"), "Lab, Creatinine other Data", "Lab, Creatinine other", "Lab, Creatinine other Abnormal", "Lab, Serum creatinine (umol/L) Data", "Serum creatinine (umol/L)", "Serum creatinine (umol/L) Abnormal", 1 / 0.01);
        calculateAlternateObs(bahmniEncounterTransaction,bahmniObsConceptMap.get("Lab, Creatinine"), "Lab, Serum creatinine (umol/L) Data", "Serum creatinine (umol/L)", "Serum creatinine (umol/L) Abnormal", "Lab, Creatinine other Data", "Lab, Creatinine other", "Lab, Creatinine other Abnormal", 0.01);

        //Glucose (fasting)
        calculateAlternateObs(bahmniEncounterTransaction,bahmniObsConceptMap.get("Lab, Glucose (Fasting)"), "Lab, Fasting blood glucose measurement (mg/dL) Data", "Fasting blood glucose measurement (mg/dL)", "Fasting blood glucose measurement (mg/dL) Abnormal", "Lab, Glucose (Fasting) other Data", "Lab, Glucose (Fasting) other", "Lab, Glucose (Fasting) other Abnormal", 18.02);
        calculateAlternateObs(bahmniEncounterTransaction,bahmniObsConceptMap.get("Lab, Glucose (Fasting)"), "Lab, Glucose (Fasting) other Data", "Lab, Glucose (Fasting) other", "Lab, Glucose (Fasting) other Abnormal", "Lab, Fasting blood glucose measurement (mg/dL) Data", "Fasting blood glucose measurement (mg/dL)", "Fasting blood glucose measurement (mg/dL) Abnormal", 1 / 18.02);

        //Glucose
        calculateAlternateObs(bahmniEncounterTransaction,bahmniObsConceptMap.get("Lab, Glucose"),"Lab, SERUM GLUCOSE Data", "SERUM GLUCOSE", "SERUM GLUCOSE Abnormal", "Lab, Glucose other Data", "Lab, Glucose other", "Lab, Glucose other Abnormal", 18.02);
        calculateAlternateObs(bahmniEncounterTransaction,bahmniObsConceptMap.get("Lab, Glucose"), "Lab, Glucose other Data", "Lab, Glucose other", "Lab, Glucose other Abnormal", "Lab, SERUM GLUCOSE Data", "SERUM GLUCOSE", "SERUM GLUCOSE Abnormal", 1 / 18.02);

        //TOTAL BILIRUBIN
        calculateAlternateObs(bahmniEncounterTransaction,bahmniObsConceptMap.get("Lab, Total Bilirubin"),"Lab, TOTAL BILIRUBIN Data", "TOTAL BILIRUBIN", "TOTAL BILIRUBIN Abnormal", "Lab, Total Bilirubin other Data", "Lab, Total Bilirubin other", "Lab, Total Bilirubin other Abnormal", 0.06);
        calculateAlternateObs(bahmniEncounterTransaction,bahmniObsConceptMap.get("Lab, Total Bilirubin"),"Lab, Total Bilirubin other Data", "Lab, Total Bilirubin other", "Lab, Total Bilirubin other Abnormal", "Lab, TOTAL BILIRUBIN Data", "TOTAL BILIRUBIN", "TOTAL BILIRUBIN Abnormal", 1 / 0.06);

    }


    static
    def calculateAlternateObs(BahmniEncounterTransaction bahmniEncounterTransaction, List<BahmniObservation> bahmniObservations, String level2CN,String level3CN, String level3AbnormalCN,
                              String level2CNConverted,String level3CNConverted,String level3AbnormalCNConverted, float conversionFactor) {

        if(bahmniObservations == null){
            return;
        }

        for (BahmniObservation grandParentObs : bahmniObservations) {
            BahmniObservation parent1Obs = findConceptInChildObs(level2CN, grandParentObs);
            BahmniObservation child1Obs1 = findConceptInChildObs(level3CN, parent1Obs);
            BahmniObservation child1Obs2 = findConceptInChildObs(level3AbnormalCN, parent1Obs);

            BahmniObservation parent2Obs = findConceptInChildObs(level2CNConverted, grandParentObs);
            BahmniObservation child2Obs1 = findConceptInChildObs(level3CNConverted, parent2Obs);
            BahmniObservation child2Obs2 = findConceptInChildObs(level3AbnormalCNConverted, parent2Obs);


            Double numericValue = getNumericValue(child1Obs1);
            Boolean abnormalValue = getBooleanValue(child1Obs2);

            if (!numericValue.equals(new Double(0))) {
                if(child2Obs1 == null){
                    parent2Obs = createObs(level2CNConverted, grandParentObs, bahmniEncounterTransaction, getDate(child1Obs1)) as BahmniObservation;
                    child2Obs1 = createObs(level3CNConverted, parent2Obs, bahmniEncounterTransaction, getDate(child1Obs1)) as BahmniObservation;
                    child2Obs2 = createObs(level3AbnormalCNConverted, parent2Obs, bahmniEncounterTransaction, getDate(child1Obs1)) as BahmniObservation;
                }

                double valueRounded = Math.round(new Double(numericValue * conversionFactor) * 100D) / 100D;
                child2Obs1.setValue(valueRounded);
                child2Obs2.setValue(abnormalValue);
            }
        }
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

            if (dateObs) {
                String target = dateObs.getValueAsString();
                DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
                Date result = df.parse(target);

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

                if (fullyObservedDaysObs == null) {
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

                def fullyObservedDays = idealTreatmentDays - (nonPrescribedDays + missedPrescribedDays + inCompletePrescribedDays) as Double

                try {
                    if (idealTreatmentDays == 0) {
                        throw new ArithmeticException()
                    } else if (idealTreatmentDays == nonPrescribedDays) {
                        throw new Exception()
                    }
                    completenessRate = (fullyObservedDays / idealTreatmentDays) * 100 as Double
                    adherenceRateDenominator = (idealTreatmentDays - nonPrescribedDays) as Double

                } catch (ArithmeticException E) {
                    throw new BahmniEmrAPIException("Value zero for MTC, Ideal total treatment days in the month")
                }
                catch (Exception E) {
                    throw new BahmniEmrAPIException("Value for MTC, Ideal total treatment days in the month is equal to MTC, Non prescribed days ")
                }
                def adherenceRate = (fullyObservedDays / adherenceRateDenominator) * 100 as Double
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


            for (BahmniObservation dotRateDetailsObs : findListOfObservationsInChildObs("MTC, DOT rate details", bahmniObs)) {
                BahmniObservation observedDaysObs = findConceptInChildObs("MTC, Drug observed days", dotRateDetailsObs)
                BahmniObservation prescribedDaysObs = findConceptInChildObs("MTC, Drug prescribed days", dotRateDetailsObs)

                def dotRateConceptName = "MTC, DOT rate"
                BahmniObservation dotRateObs = findConceptInChildObs(dotRateConceptName, dotRateDetailsObs)

                if (hasValue(observedDaysObs) && hasValue(prescribedDaysObs)) {
                    Date obsDatetime = getDate(observedDaysObs)
                    def observedDays = observedDaysObs.getValue() as Double
                    def prescribedDays = prescribedDaysObs.getValue() as Double
                    def dotRate
                    try {
                        if (prescribedDays == 0) {
                            throw new Exception()
                        }
                        dotRate = (observedDays / prescribedDays) * 100 as Double
                    } catch (Exception E) {
                        throw new BahmniEmrAPIException("Value for MTC, Drug prescribed days is equal to zero")
                    }
                    if (dotRateObs == null)
                        dotRateObs = createObs(dotRateConceptName, dotRateDetailsObs, bahmniEncounterTransaction, obsDatetime) as BahmniObservation
                    dotRateObs.setValue(Math.round(dotRate * 100.0) / 100.0)
                }
            }
        }
    }

    private
    static void calculateBMI(String templateName, Collection<BahmniObservation> observations, BahmniEncounterTransaction bahmniEncounterTransaction, Map<String, List<BahmniObservation>> bahmniObsConceptMap) {
        Collection<BahmniObservation> templateObservations = bahmniObsConceptMap.get(templateName)
        BahmniObservation heightObservation, weightObservation, parent;
        if (templateObservations != null && templateObservations.size() > 0) {
            parent = templateObservations.get(0);
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
            return
        }

        calculateBMIWithHeightAndWeight(bahmniEncounterTransaction, parent, heightObservation, weightObservation)
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
