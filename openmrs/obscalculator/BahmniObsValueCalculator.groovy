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
                "Post op period was uneventful,received 3 days of IV antibiotics and then Oral antibiotic along with analgesics.Foley's catheter removal done on                         POD - .Patient recovered well after surgery,tolerating full diet,at present surgical wound appears healthy,afebrile.Hence discharged in stable condition with following advice.Baby accepting feeds,passed stool and urine",
                "LSCS under SA\n" +
                        "Indication-ANC with CPD & NPOL \n" +
                        "Baby notes: \n" +
                        "Full term / Preterm,Baby cried immediately after birth, \n" +
                        "Date of Birth: \n" +
			"Time of Birth: \n" +
			"Sex: \n" +
                        "Birth wt: \n" +
			"APGAR score at 1 min - _/10, at 5 min - _/10",
                "Tab.Cephalexin 500 mg  QID for 5 days.\n" +
                        "Tab. PCM 500 mg QID  for 5 days then sos 10.\n" +
                        "Tab. Famotidine 20 mg bd for 5 days \n" +
			"Tab. Fersifol BD for 30 days \n" +
                        "Tab. Calcium BD for 30 day \n" +
			"Immunization for the baby", 
		"-- yrs old GPLAD at ---term gestation,presented with labour pain,and was taken for LSCS in view of -",
	        "LSCS under SA"
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

        def AcuteBronchitisTemplate = new DischargeSummaryTemplate("Acute Bronchitis",
                "On investigations her CXR was within normal limits.She had mild anemia.Her renal functions,electrolytes,liver functions were within normal limits.We managed her with antibiotics,antipyretics,bronchodilators and supportive treatment.she responded well.she didnt have tachypnea or fever during hospital stay.She was then discharged with stable vitals.", null,
                "1.Cap.Doxy 100 mg BD for 7 Days\n" + 
			"2.Salbutamol inhaler 2 puffs BD for 30 Days\n" +
			"3.Beclomethasone 2 puffs BD for 30 Days",
                "This elderly female, was admitted with complaints of cough,fever and breathlessness since 5 days.\n" +
			"HOPI- She was appearntly alright 5 days back when she had cough,dry in nature associated with fever,low grade without chills.She also started experiencing breathlessness ,initially on exertion but latter on rest also,not associated with chest pain.\n" +
			"No Ho palpiations or pedal edema.\n" +
			"No Ho hemoptysis or weight loss.\n" +
			"No Ho jaundice, loose stools.\n" +
			"No Ho nausea vomitting.\n" +
			"No Ho Rash or joint pain.\n" +
			"Past Ho -No ho HTN,DM,TB.\n" +
			"On general examination patient afebrile pulse of 90/min,blood pressure of 130/80 mmHg,pallor mild,RR-26/min,no icterus,no lymphadenopathy,no clubbing,no cyanosis,no pedal edema.\n" +
			"Respiratory system-Bilateral breath sounds heard equal.Bilateral rhinchi present.\n" +
			"Cardiovascular system- no murmur, S1S2 heard.\n" +
			"Per abdomen - soft non tender,no Hepatospleenomegaly,no organomegaly.\n" +
			"CNS- Conscious,oriented.", null
        )

        dischargeSummaryTemplates.put(AcuteBronchitisTemplate.name, AcuteBronchitisTemplate)

	def DKAHHNKTemplate = new DischargeSummaryTemplate("DKA HHNK",
                "Glucometer shows 'high' insulin. Lab glucose level ___ with urine ketones ___ Diagnosed as DKA/HHNK  Catheterised with 2 large bore IV access 2L fluids (NS) over 1st hour followed by 200cc/hr Inj KCl ____ added to ___ pints after lab electrolyte values showed hypokalemia Insulin started on 0.1 U per hour till ketones cleared i.e. ___ hours As patient was adequately hydrated and ready to eat, shifted to q6h regular insulin __ U with a 2 hr overlap with IV infusion of insulin The next day total insulin dose was divided as 2/3 and 1/3 mixtard with good glycemic control Counselled  regarding compliance and discharged stable.", null,
                "Inj  insulin mixtard, antibiotics ? , OHA",
                "The patient is a (XX)-year-old  male with a past medical history significant for diabetes mellitus for x years, who came to the ER with vomiting and diarrhea as well as weakness for one day. The patient denied fevers or chills, headache, chest pain, shortness of breath or abdominal pain. No recent steroid use, no skipped dose of insulin. PAST MEDICAL HISTORY:  Significant for diabetes mellitus. The patient took oral medications for the first _ years and has been on insulin as well as OHA for the last years. VITAL SIGNS: The patient was afebrile. Pulse was __ respiratory rate was __, and blood pressure was _____ O2 saturation was ___ GENERAL: The patient was awake and appeared to be in moderate distress and appeared lethargic. The tongue was parched, and the mucous membranes were dry. HEART: Examination showed a regular rate and rhythm. S1 and S2 present. There were no murmurs, rubs or gallops. LUNGS: Clear to auscultation bilaterally. ABDOMEN: Soft, nontender, and nondistended. EXTREMITIES: Revealed no clubbing, cyanosis or edema.", null
                
        )
	
	dischargeSummaryTemplates.put(DKAHHNKTemplate.name, DKAHHNKTemplate)

	def AcuteFebrileIllnessTemplate = new DischargeSummaryTemplate("Acute Febrile Illness", null,null,null,
        	"This elderly female was admitted with complaints of fever,headache since 8 days.\n" +
			"HOPI- She was appearntly alright 8 days back when she had fever, moderate to high grade, intermittent, associated with chills and headache thrombing in  nature.She also had generalised weakness and bodyache.\n" +
			"No Ho chest pain cough Dyspnea on exertionpedal edema.\n" +
			"No Ho hematuria or abdominal colicky pain.\n" +
			"No Ho jaundice loose stools.\n" +
			"No Ho nausea vomitting Rash.\n" +
			"Past Ho -No ho HTN,DM,TB.\n" +
			"On general examination patient febrile pulse of  90min blood pressure of 110/80 mmHg, pallor mild, no icterus, no lymphadenopathy, no clubbing, no cyanosis, no pedal edema.\n" +
			"Cardiovascular system- no murmur S1S2 heard.\n" +
			"Respiratory system normal, B/l vesicular breath sounds present, no crept.\n" +
			"Per abdomen - soft non tender, no Hepatospleenomegaly, no organomegaly.\n" +
			"CNS- Conscious,oriented.", null   
        )
        dischargeSummaryTemplates.put(AcuteFebrileIllnessTemplate.name,	AcuteFebrileIllnessTemplate)
	
	 def COPDAETemplate = new DischargeSummaryTemplate("COPD AE",
                "He was started on intravenous antibiotics, vigorous respiratory physiotherapy, O2 for ___ days maintaining saturation at 93%, Salbutamol nebulization q6h for ___ days followed by inhalation with spacer, Beclate inhaler, steroids (oral/IV). The patient improved on this regimen. Chest x-ray did not show any CHF. The cortisone was tapered. The patient's oxygenation improved and he was able to be discharged home at SPO2 at room air of ___%.", null, 
                "Quit smoking/ chula use Prednisone 20 mg 3 times a day for 2 days, 2 times a day for 5 days and then one daily,  Salbutamol inhaler 2puffs TDS  Beclate inhaler 2 puffs BD Can be given a pneumococcal vaccination before discharge.",
                "A __-year-old male with COPD and history of bronchospasm, who presents with a __-day history of increased cough, respiratory secretions, wheezings, and shortness of breath. Inciting factor identified to be (skipped medicines/infection/comorbid disease) He was seen in the OPD/ER on the day of admission and noted to be dyspneic with audible wheezing and he was admitted for acute asthmatic bronchitis, superimposed upon longstanding COPD.  (S)He currently (dis)contiues to smoke/ cook with chula. At the time of admission, he denied fever, diaphoresis, nausea, chest pain or other systemic symptoms.  PHYSICAL EXAMINATION:  Breath sounds are greatly diminished with rales and rhonchi over all lung fields. CXR shows hyperinflation, flat diaphragm PFT shows obstructive pattern, decreased FEV1, decreased FVC, With ratio of FEV1/FVC <0.7", null 
        )
        dischargeSummaryTemplates.put(COPDAETemplate.name, COPDAETemplate)

	def TAHTemplate = new DischargeSummaryTemplate("TAH",
                "Post op period was uneventful,received 3 days of IV antibiotics and then Oral antibiotic along with analgesics.Foley's catheter removal done on POD 7- .Vault check done - healthy and suture removal done on POD 7.Patient recovered well after surgery,tolerating full diet,at present surgical wound appears healthy,afebrile.Hence discharged in stable condition with following advice.",
                "For surgery",
                "Tab. Cephalexin 500 mg QID for 5 days.\n" + 
			"Tab. PCM 500 mg QID for 5 days then sos 10\n" +
			"Tab. Famotidine 20 mg bd for 5 days\n" +
			"Tab. Fersisol BD for 30 days Tab.\n" + 
			"Tab. Calcium BD for 30 days",
		"--yr old lady with no known comorbidities / HTN / DM / presented with c/o since \n" +
			"On examination : \n" +
			"Routine investigations done as mentioned,was diagnosed as - fibroid uterus / PID \n"+ 
			"Hence was electively posted for surgery.",
		"Total abdominal hysterectomy under SA",
        )
        dischargeSummaryTemplates.put(TAHTemplate.name, TAHTemplate)
	
	
	def MalariatemplateTemplate = new DischargeSummaryTemplate("MalariaTemplate",
                "It was diagnosed as malaria on peripheral smear and RDT. The patient had an ultrasound of the abdomen, which was normal.\n" +
			"Management: \n" +
			"Vitals were stabilized \n" +
			"ACT (oral/IV) was started artesunate (4mg/kg/D) for 3 days with Sulfadoxine-pyrimethamine (500/25mg) single dose.\n" +
			"The patient was symptomatically better by AD 3. Patient was discharged stable on AD ______",
                "Un/complicated Malaria",
                "Follow up with the patients primary doctor in 14 days to rule out reactivation/ recrudescence",
                "The patient is a (XX)-year-old male who was admitted to this facility after he had presented with severe fever with rigors followed by sweating; headache, vomiting. The patient lives in a village in chhattisgarh and does not use bed nets. He reports that there are many mosquitoes around his house. On examination: tachycardia+, patient is febrile, and hepatosplenomegaly +/- The following features were +/- \n" +
			"Impaired consciousness \n" +
			"Respiratory distress (acidotic breathing)\n" +
			"Multiple convulsions \n" +
			"Circulatory collapse \n" +
			"Pulmonary edema \n" +
			"Abnormal bleeding \n" +
			"Jaundice \n" +
			"Hemoglobinuria", null
        )

        dischargeSummaryTemplates.put(MalariatemplateTemplate.name, MalariatemplateTemplate)

	 def NormalDeliveryTemplate = new DischargeSummaryTemplate("NormalDelivery",
                "Breast Feeding Established.\n" +
                        "Baby Screened for obvious congenital malformations \n" +
			"Contraception advice given \n" +
                        "Counselling for danger signs done \n" +
			"Hb \n" +
			"TC/DC \n" +
			"P.S.for M.P. \n" +
			"P.S.for anemia \n" +
			"Others : HbsAg - Postive / Negative \n" +
			"HIV - Postive / Negative \n" +
			"VDRL - Postive / Negative \n" +
			"Sickly - Postive / Negative \n" +
			"Urine:",
                "Full Term / Preterm Normal / Assisted Delivery \n" +
			"With / Without Complications -",
                "Breast Feed 2 hrly \n" +
			"Immunize in nearby govt facility \n" +
			"Episiotomy care as advised \n" +
			"Medicine \n" +
			"1.Cap.Ampiclox 1gm QID 5 Days \n" +
			"2.Tab.Fersifol BD 30 Days \n" +
			"3.Tab.Calcium BD 30 Days",
                "G P A L , H/O _____ Months amenorrhoea,presented in early /active labour.",
                "Normal Vaginal Delivery with / without Episiotomy \n" +
			"Assisted  Forceps / Vaccum Vaginal Delivery \n" + 
			"Baby Notes - \n" +
			"DOB ->      ,TOB ->        ,Gender -> Male/Female,weight ->___kg, APGAR Score at 1min __/10 at 5min _/10"
        )

        dischargeSummaryTemplates.put(NormalDeliveryTemplate.name, NormalDeliveryTemplate)

        def ChemotherapytemplateTemplate = new DischargeSummaryTemplate("Chemotherapytemplate",
                "X years old Man/Lady KCO Ca. (Name of Carcinoma) was admitted electively for receiving X \n" +
                        "Cycle Chemotherapy.\n" +
                        "Patient received following Agents \n" +
                        "1.Inj.\n" +
                        "2.Inj.\n" +
                        "With preloading & Anti-emetics. Patient received chemotherapy under full supervision & did not develop any Anaphylaxis or Vomiting or any other systemic complaint during period of Chemotherapy.\n" +
                        "Patient is discharged in better condition & planned to follow-up after X weeks for next cycle.",
		"Ca. ____________. Status: post (Name of Surgery) with previous (X) cycles of Chemotherapy Received.",
                "1.Tab. CPZ BD for 5 days \n" +
                        "2.Tab. ondansetron 4 mg BD for 5 days \n" +
                        "3.Tab. Fersifol 1 BD for 3 weeks \n" +
                        "4.Tab. Becadex 1 BD for 3 weeks \n" +
                        "5.Aamla 2 \n" +
                        "6.Nutrition as explained.",null,null
	)
        dischargeSummaryTemplates.put(ChemotherapytemplateTemplate.name, ChemotherapytemplateTemplate)

	

      // TODO Read from actual CSV file after getting the library for CSV parser (commons-CSV ? )
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
