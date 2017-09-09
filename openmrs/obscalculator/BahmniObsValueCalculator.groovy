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

public class BahmniObsValueCalculator implements ObsValueCalculator {

    static Double BMI_VERY_SEVERELY_UNDERWEIGHT = 16.0;
    static Double BMI_SEVERELY_UNDERWEIGHT = 17.0;
    static Double BMI_UNDERWEIGHT = 18.5;
    static Double BMI_NORMAL = 25.0;
    static Double BMI_OVERWEIGHT = 30.0;
    static Double BMI_OBESE = 35.0;
    static Double BMI_SEVERELY_OBESE = 40.0;
    static Map<BahmniObservation, BahmniObservation> obsParentMap = new HashMap<BahmniObservation, BahmniObservation>();



    public static class DischargeSummaryConceptNames {
        static TEMPLATE = "Discharge Summary, Template"
        static HOSPITAL_COURSE = "Hospital Course"
        static ADMISSION_INDICATION = "Discharge Summary, Admission Indication"
        static ADVICE_ON_DISCHARGE = "Advice on Discharge"
        static HISTORY_AND_EXAMINATION_NOTES = "History and Examination Notes"
        static SURGERIES_AND_PROCEDURES = "Discharge Summary, Surgeries and Procedures"
        static OPERATIVE_PROCEDURE = "Operative Procedure"
    }

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
        calculateAndAdd(bahmniEncounterTransaction);
    }



    private
    static void setBMIDetails(Collection<BahmniObservation> observations, BahmniEncounterTransaction bahmniEncounterTransaction) {
        BahmniObservation heightObservation = find("Height", observations, null)
        BahmniObservation weightObservation = find("Weight", observations, null)
        BahmniObservation parent = null;
        def nowAsOfEncounter = bahmniEncounterTransaction.getEncounterDateTime() != null ? bahmniEncounterTransaction.getEncounterDateTime() : new Date();

        if (hasValue(heightObservation) || hasValue(weightObservation)) {
            BahmniObservation bmiDataObservation = find("BMI Data", observations, null)
            BahmniObservation bmiObservation = find("BMI", bmiDataObservation ? [bmiDataObservation] : [], null)
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
                return;
            }

            def previousHeightValue = fetchLatestValue("Height", bahmniEncounterTransaction.getPatientUuid(), heightObservation, nowAsOfEncounter)
            def previousWeightValue = fetchLatestValue("Weight", bahmniEncounterTransaction.getPatientUuid(), weightObservation, nowAsOfEncounter)

            Double height = hasValue(heightObservation) && !heightObservation.voided ? heightObservation.getValue() as Double : previousHeightValue
            Double weight = hasValue(weightObservation) && !weightObservation.voided ? weightObservation.getValue() as Double : previousWeightValue
            Date obsDatetime = getDate(weightObservation) != null ? getDate(weightObservation) : getDate(heightObservation)

            if (height == null || weight == null) {
                voidObs(bmiDataObservation)
                voidObs(bmiObservation)
                voidObs(bmiStatusDataObservation)
                voidObs(bmiStatusObservation)
                voidObs(bmiAbnormalObservation)
                return;
            }

            bmiDataObservation = bmiDataObservation ?: createObs("BMI Data", null, bahmniEncounterTransaction, obsDatetime) as BahmniObservation
            bmiStatusDataObservation = bmiStatusDataObservation ?: createObs("BMI Status Data", null, bahmniEncounterTransaction, obsDatetime) as BahmniObservation

            def bmi = bmi(height, weight)
            bmiObservation = bmiObservation ?: createObs("BMI", bmiDataObservation, bahmniEncounterTransaction, obsDatetime) as BahmniObservation;
            bmiObservation.setValue(bmi);

            def bmiStatus = bmiStatus(bmi, patientAgeInMonthsAsOfEncounter, patient.getGender());
            bmiStatusObservation = bmiStatusObservation ?: createObs("BMI Status", bmiStatusDataObservation, bahmniEncounterTransaction, obsDatetime) as BahmniObservation;
            bmiStatusObservation.setValue(bmiStatus);

            def bmiAbnormal = bmiAbnormal(bmiStatus);
            bmiAbnormalObservation =  bmiAbnormalObservation ?: createObs("BMI Abnormal", bmiDataObservation, bahmniEncounterTransaction, obsDatetime) as BahmniObservation;
            bmiAbnormalObservation.setValue(bmiAbnormal);

            bmiStatusAbnormalObservation =  bmiStatusAbnormalObservation ?: createObs("BMI Status Abnormal", bmiStatusDataObservation, bahmniEncounterTransaction, obsDatetime) as BahmniObservation;
            bmiStatusAbnormalObservation.setValue(bmiAbnormal);

            return;
        }
    }

    static def calculateAndAdd(BahmniEncounterTransaction bahmniEncounterTransaction) {
        Collection<BahmniObservation> observations = bahmniEncounterTransaction.getObservations()
        setBMIDetails(observations, bahmniEncounterTransaction)
        setObstetricsEDD(observations, bahmniEncounterTransaction)
        setANCEDD(observations, bahmniEncounterTransaction)
        setWaistHipRatio(observations, bahmniEncounterTransaction)
        setDischargeSummaryFields(observations, bahmniEncounterTransaction)
    }
    private
    static void setObstetricsEDD(Collection<BahmniObservation> observations, BahmniEncounterTransaction bahmniEncounterTransaction) {
        BahmniObservation lmpObservation = find("Obstetrics, Last Menstrual Period", observations, null)
        def calculatedConceptName = "Estimated Date of Delivery"
        BahmniObservation parent = null;
        if (hasValue(lmpObservation)) {
            parent = obsParent(lmpObservation, null)
            def calculatedObs = find(calculatedConceptName, observations, null)

            Date obsDatetime = getDate(lmpObservation)

            LocalDate edd = new LocalDate(lmpObservation.getValue()).plusMonths(9).plusWeeks(1)
            if (calculatedObs == null)
                calculatedObs = createObs(calculatedConceptName, parent, bahmniEncounterTransaction, obsDatetime) as BahmniObservation
            calculatedObs.setValue(edd)
            return
        } else {
            def calculatedObs = find(calculatedConceptName, observations, null)
            if (hasValue(calculatedObs)) {
                voidObs(calculatedObs)
            }
        }
    }
        private
    static void setANCEDD(Collection<BahmniObservation> observations, BahmniEncounterTransaction bahmniEncounterTransaction) {
        BahmniObservation ancObservation = find("ANC, Last menstrual period", observations, null)
            BahmniObservation parent = null;
        def calculatedConceptNameanc = "ANC, Estimated Date of Delivery"
        if (hasValue(ancObservation)) {
            parent = obsParent(ancObservation, null)
            def calculatedObs = find(calculatedConceptNameanc, observations, null)

            Date obsDatetime = getDate(ancObservation)

            LocalDate edd = new LocalDate(ancObservation.getValue()).plusMonths(9).plusWeeks(1)
            if (calculatedObs == null)
                calculatedObs = createObs(calculatedConceptNameanc, parent, bahmniEncounterTransaction, obsDatetime) as BahmniObservation
            calculatedObs.setValue(edd)
        } else {
            def calculatedObs = find(calculatedConceptNameanc, observations, null)
            if (hasValue(calculatedObs)) {
                voidObs(calculatedObs)
            }
        }
    }


        private
    static void setWaistHipRatio(Collection<BahmniObservation> observations, BahmniEncounterTransaction bahmniEncounterTransaction) {
        BahmniObservation parent
        BahmniObservation waistCircumferenceObservation = find("Waist Circumference", observations, null)
        BahmniObservation hipCircumferenceObservation = find("Hip Circumference", observations, null)
        if (hasValue(waistCircumferenceObservation) && hasValue(hipCircumferenceObservation)) {
            def calculatedConceptName = "Waist/Hip Ratio"
            BahmniObservation calculatedObs = find(calculatedConceptName, observations, null)
            parent = obsParent(waistCircumferenceObservation, null)

            Date obsDatetime = getDate(waistCircumferenceObservation)
            def waistCircumference = waistCircumferenceObservation.getValue() as Double
            def hipCircumference = hipCircumferenceObservation.getValue() as Double
            def waistByHipRatio = waistCircumference / hipCircumference
            if (calculatedObs == null)
                calculatedObs = createObs(calculatedConceptName, parent, bahmniEncounterTransaction, obsDatetime) as BahmniObservation

            calculatedObs.setValue(waistByHipRatio)
        }
    }

    private static void setDischargeSummaryFields(Collection<BahmniObservation> observations, BahmniEncounterTransaction bahmniEncounterTransaction) {
        BahmniObservation parent;
        BahmniObservation templateObservation = find(DischargeSummaryConceptNames.TEMPLATE, observations, null)
        if (hasValue(templateObservation)) {
            def dischargeSummaryTemplates = getDischargeSummaryTemplates();
            def dischargeSummaryTemplate = dischargeSummaryTemplates.get(templateObservation.getValue().displayString)
            parent = obsParent(templateObservation, null)
            Date obsDatetime = getDate(templateObservation)
            setValueIfNotPresent(DischargeSummaryConceptNames.HOSPITAL_COURSE, parent, bahmniEncounterTransaction, obsDatetime, dischargeSummaryTemplate.hospitalCourse, observations)
            setValueIfNotPresent(DischargeSummaryConceptNames.ADMISSION_INDICATION, parent, bahmniEncounterTransaction, obsDatetime, dischargeSummaryTemplate.admissionIndication, observations)
            setValueIfNotPresent(DischargeSummaryConceptNames.ADVICE_ON_DISCHARGE, parent, bahmniEncounterTransaction, obsDatetime, dischargeSummaryTemplate.adviceOnDischarge, observations)
            setValueIfNotPresent(DischargeSummaryConceptNames.HISTORY_AND_EXAMINATION_NOTES, parent, bahmniEncounterTransaction, obsDatetime, dischargeSummaryTemplate.historyExamination, observations)
            if(dischargeSummaryTemplate.operativeProcedure != null){
                BahmniObservation surgeriesAndProcedure = find(DischargeSummaryConceptNames.SURGERIES_AND_PROCEDURES, observations, parent)
                if(surgeriesAndProcedure == null) {
                    surgeriesAndProcedure = createObs(DischargeSummaryConceptNames.SURGERIES_AND_PROCEDURES, parent, bahmniEncounterTransaction, obsDatetime)
                }
                setValueIfNotPresent(DischargeSummaryConceptNames.OPERATIVE_PROCEDURE, surgeriesAndProcedure, bahmniEncounterTransaction, obsDatetime, dischargeSummaryTemplate.operativeProcedure, observations)
            }


        }
    }

    private
    static void setValueIfNotPresent(String conceptName, BahmniObservation parent, BahmniEncounterTransaction bahmniEncounterTransaction, Date obsDatetime, String obsValue, observations) {
        if(obsValue == null) return
        BahmniObservation observation = find(conceptName, observations, null)
        if(! hasValue(observation)) {
            BahmniObservation obs = createObs(conceptName, parent, bahmniEncounterTransaction, obsDatetime) as BahmniObservation
            obs.setValue(obsValue)
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
        BMIChart bmiChart = readBMICSV(OpenmrsUtil.getApplicationDataDirectory() + "obscalculator/BMI_chart.csv");
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
                " order by obs.obsDatetime desc ");
        queryToGetObservations.setString("patientUuid", patientUuid);
        queryToGetObservations.setParameterList("conceptName", conceptName);
        queryToGetObservations.setParameter("till", tillDate);
        if (excludedObsIsSaved) {
            queryToGetObservations.setString("excludeObsUuid", excludeObs.uuid)
        }
        queryToGetObservations.setMaxResults(1);
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

    static BMIChart readBMICSV(String fileName) {
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


    static Map<String, DischargeSummaryTemplate> getDischargeSummaryTemplates() {

        def dischargeSummaryTemplates = new HashMap<String,DischargeSummaryTemplate>()

        def LSCSTemplate = new DischargeSummaryTemplate("LSCS",
                "Patient recovered well after surgery, received  3  days of IV antibiotics,tolerating full diet,incision line good no soakage and pus collection",
                "LSCS under SA\n" +
                        "indication-ANC with CPD & NPOL\n" +
                        "Baby notes: \n" +
                        "Full term, male baby,Baby cried immediately after birth, \n" +
                        "APGAR score _/15, \n" +
                        "Birth wt:",
                "Tab-fersisol BD Tab. Cephalexin 500 mg  QID for 5 days.\n" +
                        "Tab. PCM 500 mg QID  for 3 days.\n" +
                        "Tab. famotidine 20 mg bd for for 30 days\n" +
                        "Tab-calcium BD for 30 day", null, null
        )
        dischargeSummaryTemplates.put(LSCSTemplate.name, LSCSTemplate)

        def TBTemplate = new DischargeSummaryTemplate("TB",
                "counselled,sputum sent for sensitivity testing\n" +
                        "started on AKT (daily HRZE weight based regimen),tolerating it well.\n" +
                        "screened for diabetes and HIV.\n" +
                        "advised screening for children.",
                "A   yrs old male presented with cough with expectoration for month,fever for month ,anorexia for month ,loss of weight since month",
                "phone on- .   Follow up on - .\n" +
                        "tab INH 300 mg od \n" +
                        "cap. RIF 450 mg od\n" +
                        "tab EMB 800 mg od\n" +
                        "tab PYZ 1000 mg od for 20 days\n" +
                        "tab pyridoxine 10 mg od for 20 days\n" +
                        "chana 2 kg \n" +
                        "tab.pcm sos..10", null, null
        )
        dischargeSummaryTemplates.put(TBTemplate.name, TBTemplate)

        def inguinalHerniaTemplate = new DischargeSummaryTemplate("Inguinal Hernia",
                "Recovered well after surgery,received antibiotics,GC-Fine,discharged on oral medicines.",
                "Patient with inguinal hernia need for surgery",
                "1.Cap.Ampiclox 1 gm QID for 5 Days  \n" +
                        "2.Tab.Ibuprofen 400 mg TDS for 7 Days \n" +
                        "3.Tab.Famotidine 20 mg BD for 7 Days \n" +
                        "4.Tab.Fersifol BD for 30 Days \n" +
                        "5.Suture Removal after 7 Days",
                "C/o Swelling in inguino-scrotal region",
                "Right/Left - Herniotomy / Herniorrhapy / Hernioplasty under LA/Ketamine"
        )

        dischargeSummaryTemplates.put(inguinalHerniaTemplate.name, inguinalHerniaTemplate)

        def tubalLigationTemplate = new DischargeSummaryTemplate("Tubal Ligation",
                "Recovered well after surgery,received IV antibiotics,GC-Fine,discharged on oral medicines.",
                "Willing for tubal ligation",
                "1.Cap.Cephalexin 500 mg QID for 5 Days\n" +
                        "2.Tab.Ibuprofen 400 mg TDS for 7 Days\n" +
                        "3.Tab Famotidine 20 mg BD for 7 Days\n" +
                        "4.Tab.Fersifol BD for 30 Days\n" +
                        "5.follow up after 7 Days",
                "Para.............................., Living................................\n" +
                        "Tubal Ligation\n" +
                        "Willing for Tubal Ligation\n" +
                        "Consent taken from husband-",
                "Tubal ligation under LA/Ketamine"
        )

        dischargeSummaryTemplates.put(tubalLigationTemplate.name, tubalLigationTemplate)

        //TODO Read from actual CSV file after getting the library for CSV parser (commons-CSV ? )
//        String fileName = OpenmrsUtil.getApplicationDataDirectory() + "obscalculator/discharge_summary_templates.csv"
//        try {
//            new File(fileName).withReader { reader ->
//                def header = reader.readLine();
//                reader.splitEachLine(",") { tokens ->
//                    dischargeSummaryTemplates.put(tokens[0], new DischargeSummaryTemplate(tokens[0], tokens[1], tokens[2], tokens[3]));
//                }
//            }
//        } catch (FileNotFoundException e) {
//        }
        return dischargeSummaryTemplates;
    }

    static class DischargeSummaryTemplate {
        public String name;
        public String hospitalCourse;
        public String admissionIndication;
        public String adviceOnDischarge;
        public String historyExamination;
        public String operativeProcedure;

        DischargeSummaryTemplate(String name, String hospitalCourse, String admissionIndication, String adviceOnDischarge, String historyExamination, String operativeProcedure){
            this.name = name;
            this.hospitalCourse = hospitalCourse;
            this.admissionIndication = admissionIndication;
            this.adviceOnDischarge = adviceOnDischarge;
            this.historyExamination = historyExamination;
            this.operativeProcedure = operativeProcedure;
        }
    }

}
