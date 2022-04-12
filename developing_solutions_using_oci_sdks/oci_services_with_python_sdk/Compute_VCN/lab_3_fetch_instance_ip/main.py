# Main
import oci
import json
from get_instance_ip_info import get_instance_ip_addresses

if __name__ == "__main__":
    instance_id = input("Enter Compute Instance OCID: ") or \
                  "ocid1.instance.oc1.ap-mumbai-1.anrg6ljr2br7taycew6m5vjlrplgujvildrqdjpdkj7hq4brsje2me5w3iwq"

    # Default Config File and Profile
    config = oci.config.from_file()
    compute_client = oci.core.ComputeClient(config)
    virtual_network_client = oci.core.VirtualNetworkClient(config)

    # Fetch the IP address information
    print("Fetching the IP address information ...")
    ip_addr_info = get_instance_ip_addresses(compute_client,virtual_network_client,instance_id)
    print("\n\nPrivate and Public IP Addresses")
    print("======================================")
    print(json.dumps(ip_addr_info,sort_keys=True, indent=5))
