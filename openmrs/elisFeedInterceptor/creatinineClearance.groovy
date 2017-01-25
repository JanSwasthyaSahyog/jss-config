import org.bahmni.module.bahmnicore.service.impl.BahmniBridge
import org.openmrs.*
import org.bahmni.module.elisatomfeedclient.api.elisFeedInterceptor.ElisFeedEncounterInterceptor;import java.util.Locale
import java.util.Set
import org.openmrs.api.OrderContext;
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
            Obs creatinineObs = getCreatinineObs(encounters);
        } finally {
            sessionFactory.getCurrentSession().setFlushMode(flushMode)
        }

    }

    private Obs getCreatinineObs(Set<Encounter> encounters) {
        for (Encounter encounter : encounters) {
            for (Obs obs : encounter.getObs()) {
                if (obs.getOrder() != null && obs.getConcept().getFullySpecifiedName(Locale.ENGLISH).getName().equals(CREATININE_TEST_NAME)
                        && obs.getOrder().getConcept().getUuid().equals(obs.getConcept().getUuid())) {

                    Concept creatinineClearanceRateConcept = BahmniBridge.create().getConcept(CREATINIE_CLEARANCE_TEST_NAME);
                    Order order = new Order();
                    order.setOrderType(obs.getOrder().getOrderType());
                    order.setConcept(creatinineClearanceRateConcept);
                    order.setOrderer(obs.getOrder().getOrderer());
                    order.setCareSetting(obs.getOrder().getCareSetting());
                    order.setAccessionNumber(obs.getAccessionNumber());
                    order.setEncounter(encounter);
                    order.setPatient(obs.getOrder().getPatient());
encounter.addOrder(order);
                    Obs creatinineClearanceObs = getObs(obs, creatinineClearanceRateConcept,order);
                    if(creatinineClearanceObs != null){
		   	Obs creatinineClearanceObsOne = getObs(obs, creatinineClearanceRateConcept,order);
                        creatinineClearanceObs.setValueNumeric(null);
                        creatinineClearanceObs.addGroupMember(creatinineClearanceObsOne);
                        
                        Obs creatinineClearanceObsTwo = getObs(obs, creatinineClearanceRateConcept,order);
                        creatinineClearanceObsOne.setValueNumeric(null);
                        creatinineClearanceObsOne.addGroupMember(creatinineClearanceObsTwo)
                        
                        encounter.addObs(creatinineClearanceObs);
                        encounter.addObs(creatinineClearanceObsOne);
                        encounter.addObs(creatinineClearanceObsTwo);
		    }
Context.getEncounterService().saveEncounter(encounter);
                    	return creatinineClearanceObs;
                }
            }
        }
        return null;
    }

    private Obs getObs(Obs obs, Concept creatinineClearanceRateConcept, Order order) {

        this.bahmniBridge = BahmniBridge.create().forPatient(obs.getPerson().getUuid());
        Obs weighttval=bahmniBridge.latestObs(WEIGHT_CONCEPT_NAME);
	if (weighttval == null)
		return null;
        Integer personage = obs.getPerson().getAge();
        String gender = obs.getPerson().getGender();
        double CreatinineClearanceRate = 0.0;

        if (gender.equals('M')) {
            CreatinineClearanceRate = (double)Math.round((((140 - personage) * weighttval.getValueNumeric()) / (72 * (obs.getValueNumeric())))* 100.0) / 100.0;
        } else if (gender.equals('F')) {
            CreatinineClearanceRate = (double)Math.round((((140 - personage) * weighttval.getValueNumeric()) / (72 * (obs.getValueNumeric()))) * 0.85* 100.0) / 100.0;
        }


        Obs creatinineClearanceObs = new Obs();
        creatinineClearanceObs.setConcept(creatinineClearanceRateConcept);
        creatinineClearanceObs.setValueNumeric(CreatinineClearanceRate);
        creatinineClearanceObs.setOrder(order);
        return creatinineClearanceObs;
    }

}
