import org.openmrs.*
import org.bahmni.module.elisatomfeedclient.api.domain.OpenElisAccession;
import org.bahmni.module.elisatomfeedclient.api.domain.OpenElisTestDetail;
import org.bahmni.module.elisatomfeedclient.api.elisFeedInterceptor.ElisFeedAccessionInterceptor;
import java.util.*


public class FiterDonorTestResults implements ElisFeedAccessionInterceptor {

    public ArrayList<String> donorTests = ["HCV ELISA (Relative)",
                                            "HbsAg ELISA (Relative)", 
                                            "VDRL ELISA (Relative)",
                                            "HIV Tridot (Relative)",
                                            "HbsAg Rapid (Relative)",
                                            "HCV Tridot (Relative)",
                                            "HIV ELISA (Relative)",
                                            "VDRL Rapid (Relative)", 
                                            "Malaria Parasite (Relative)",
                                            "Hemoglobin (Relative)", 
                                            "Blood Group (Relative)"];
    @Override
    public void run(OpenElisAccession openElisAccession) {
        Iterator<OpenElisTestDetail> iter = openElisAccession.getTestDetails().iterator();
        while(iter.hasNext()){
            if(donorTests.contains(iter.next().getTestName())) {
                iter.remove();
            }
        }
    }

}