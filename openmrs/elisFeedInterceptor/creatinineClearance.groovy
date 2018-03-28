package org.bahmni.module.elisatomfeedclient.api.elisFeedInterceptor

import org.bahmni.module.bahmnicore.service.impl.BahmniBridge
import org.openmrs.*
import org.openmrs.api.context.Context;
import org.openmrs.api.db.hibernate.DbSessionFactory;
import org.hibernate.FlushMode;



public class CreatinineUpdate implements ElisFeedEncounterInterceptor {
    public static final String CREATININE_TEST_NAME = "Creatinine";
    public static final String CREATINIE_CLEARANCE_TEST_NAME = "Creatinine Clearance";
    public static final String HEIGHT_CONCEPT_NAME = "HEIGHT";
    public static final String WEIGHT_CONCEPT_NAME = "WEIGHT";
    public BahmniBridge bahmniBridge;

    public void run(Set<Encounter> encounters) {
        DbSessionFactory sessionFactory = Context.getRegisteredComponent("dbSessionFactory", DbSessionFactory.class);
        FlushMode flushMode = sessionFactory.getCurrentSession().getFlushMode();
        sessionFactory.getCurrentSession().setFlushMode(FlushMode.MANUAL);
        try {
            addCreatinineClearanceObs(encounters);
        } finally {
            sessionFactory.getCurrentSession().setFlushMode(flushMode)
        }

    }

    private void addCreatinineClearanceObs(Set<Encounter> encounters) {
        for (Encounter encounter : encounters) {
            processEncounter(encounter)
        }
    }

    private void processEncounter(Encounter encounter) {
        println "CreatinineClearanceGroovy: Came to process encounter";
        Obs creatinineObs = getObs(encounter, CREATININE_TEST_NAME)

        if (creatinineObs == null){
            println "CreatinineClearanceGroovy: Found creatinine Obs null";
            return;
        }

        println "CreatinineClearanceGroovy: Found Creatinine Obs";
        this.bahmniBridge = BahmniBridge.create().forPatient(creatinineObs.getPerson().getUuid());
        Obs weightObs= bahmniBridge.latestObs(WEIGHT_CONCEPT_NAME);
        if (weightObs == null) {
            println "CreatinineClearanceGroovy: Found Weight Obs null";
            return;
        }

        println "CreatinineClearanceGroovy: Found Weight Obs";
        double creatinineClearanceRate = calculateCreatinineClearanceRate(creatinineObs, weightObs);
        println "CreatinineClearanceGroovy: Calculated creatinineClearanceRate "+creatinineClearanceRate;

        Obs creatinineClearanceObs = getObs(encounter, CREATINIE_CLEARANCE_TEST_NAME);

        if(creatinineClearanceObs!= null && creatinineClearanceObs.getValueNumeric().equals(creatinineClearanceRate)){
            println "CreatinineClearanceGroovy: Found same value";
            return;
        }

        if(creatinineClearanceObs!= null){
            //to handle if creatinine value is updated
            creatinineClearanceObs.setValueNumeric(creatinineClearanceRate);
            println "CreatinineClearanceGroovy: set value";
        }
        else {
            println "CreatinineClearanceGroovy: Came to create new creatinine clearance Obs";
            Concept creatinineClearanceRateConcept = BahmniBridge.create().getConcept(CREATINIE_CLEARANCE_TEST_NAME);
            Order order = createOrder(creatinineObs, creatinineClearanceRateConcept)
            order.setEncounter(encounter);
            encounter.addOrder(order);
            creatinineClearanceObs = createObs(creatinineClearanceRateConcept, order);
            println "Setting value "+creatinineClearanceRate;


            Obs creatinineClearanceObsOne = createObs(creatinineClearanceRateConcept, order);
            creatinineClearanceObsOne.setValueNumeric(null);
            creatinineClearanceObs.addGroupMember(creatinineClearanceObsOne);

            Obs creatinineClearanceObsTwo = createObs(creatinineClearanceRateConcept, order);
            creatinineClearanceObsTwo.setValueNumeric(creatinineClearanceRate);
            creatinineClearanceObsOne.addGroupMember(creatinineClearanceObsTwo)

            println "Value "+creatinineClearanceObsTwo.getValueNumeric();
            encounter.addObs(creatinineClearanceObs);
            encounter.addObs(creatinineClearanceObsOne);
            encounter.addObs(creatinineClearanceObsTwo);
        }
        println "CreatinineClearanceGroovy: About to save the encounter";
        Context.getEncounterService().saveEncounter(encounter);
    }

    private static Obs getObs(Encounter encounter, String conceptName) {
        Obs obsForConcept = null;
        for (Obs obs : encounter.getObs()) {
            if (obs.getOrder() != null && obs.getConcept().getFullySpecifiedName(Locale.ENGLISH).getName().equals(conceptName)
                    && obs.getOrder().getConcept().getUuid().equals(obs.getConcept().getUuid())) {
                obsForConcept = obs;
            }
        }
        return obsForConcept;
    }

    private static Order createOrder(Obs obs, Concept creatinineClearanceRateConcept) {
        Order order = new Order();
        order.setOrderType(obs.getOrder().getOrderType());
        order.setConcept(creatinineClearanceRateConcept);
        order.setOrderer(obs.getOrder().getOrderer());
        order.setCareSetting(obs.getOrder().getCareSetting());
        order.setAccessionNumber(obs.getAccessionNumber());
        order.setPatient(obs.getOrder().getPatient());
        return order;
    }

    private static Obs createObs(Concept creatinineClearanceRateConcept, Order order) {
        Obs creatinineClearanceObs = new Obs();
        creatinineClearanceObs.setConcept(creatinineClearanceRateConcept);
        creatinineClearanceObs.setOrder(order);
        return creatinineClearanceObs;
    }

    private static double calculateCreatinineClearanceRate(Obs creatinineObs, Obs weightObs) {
        Integer personage = creatinineObs.getPerson().getAge();
        String gender = creatinineObs.getPerson().getGender();
        double creatinineClearanceRate = 0.0;

        if (gender.equals('M')) {
            creatinineClearanceRate = (double) Math.round((((140 - personage) * weightObs.getValueNumeric()) / (72 * (creatinineObs.getValueNumeric()))) * 100.0) / 100.0;
        } else if (gender.equals('F')) {
            creatinineClearanceRate = (double) Math.round((((140 - personage) * weightObs.getValueNumeric()) / (72 * (creatinineObs.getValueNumeric()))) * 0.85 * 100.0) / 100.0;
        }
        return creatinineClearanceRate;
    }

}
