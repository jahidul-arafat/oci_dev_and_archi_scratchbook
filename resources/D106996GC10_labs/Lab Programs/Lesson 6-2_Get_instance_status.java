import com.oracle.bmc.core.model.Instance.LifecycleState;
import com.oracle.bmc.auth.AuthenticationDetailsProvider;
import com.oracle.bmc.auth.ConfigFileAuthenticationDetailsProvider;
import com.oracle.bmc.core.model.Instance;
import com.oracle.bmc.core.requests.GetInstanceRequest;
import com.oracle.bmc.core.ComputeClient;

public class get_instance_status {
    public static void main(String[] args) throws Exception {

        String configurationFilePath = "/home/opc/.oci/config";
        String profile = "DEFAULT";
        String instanceId = args[0];

        AuthenticationDetailsProvider provider =
                new ConfigFileAuthenticationDetailsProvider(configurationFilePath, profile);
        ComputeClient compute = new ComputeClient(provider);
        GetInstanceRequest getInstanceRequest =
                GetInstanceRequest.builder().instanceId(instanceId).build();
        Instance instance = compute.getInstance(getInstanceRequest).getInstance();

        System.out.println("Instance Name :  "+ instance.getDisplayName());
        System.out.println("Domain Name of Instance :  "+ instance.getAvailabilityDomain());
        System.out.println("Life Status of " + instance.getDisplayName() + " :  " + instance.getLifecycleState());

    }
}
