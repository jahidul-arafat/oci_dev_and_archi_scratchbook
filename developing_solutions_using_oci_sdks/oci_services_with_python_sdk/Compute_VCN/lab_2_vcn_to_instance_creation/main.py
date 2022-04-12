"""
Network Security Group- https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/networksecuritygroups.htm

"""

import oci
import os.path
import sys
from compue_instance_preq import \
    get_availability_domain, \
    get_image, \
    get_shape
from create_vcn_details import \
    create_vcn, \
    create_subnet, \
    create_igw, \
    add_igw_to_default_rt_rule, \
    create_nsg, add_nsg_secruity_rules

from launch_compute_instance import \
    get_instance_instance_details, \
    launch_instance, \
    print_instance_details

# Main
if __name__ == "__main__":
    # CommandLine Parameters
    # User Inputs
    compartment_id = input(
        "Enter the Compartment OCID : ") or "ocid1.compartment.oc1..aaaaaaaa5hplc4q67l76kzeygvcbbu73da3kxhndhogtfvxgwtpd2xzayecq"
    cidr_block = input("Enter VCN CIDR Block: ") or "10.0.0.0/16"
    pub_sunet_cidr_block = input("Enter Subnet (Public) CIDR Block: ") or "10.0.0.0/24"
    ssh_public_key_path = input("Enter SSH Public Key File Path: ") or "~/.ssh/id_rsa.pub"

    with open(os.path.expandvars(os.path.expanduser(ssh_public_key_path)), mode='r') as file:
        ssh_public_key = file.read()

    # Default Config File and Profile
    config = oci.config.from_file()
    identity_client = oci.identity.IdentityClient(config)

    compute_client = oci.core.ComputeClient(config)
    compute_client_composite_operations = oci.core.ComputeClientCompositeOperations(compute_client)

    virtual_network_client = oci.core.VirtualNetworkClient(config)
    virtual_network_composite_operations = oci.core.VirtualNetworkClientCompositeOperations(virtual_network_client)

    # get the AD
    availability_domain = get_availability_domain(identity_client, compartment_id)

    # get the shape
    shape = get_shape(compute_client, compartment_id, availability_domain)

    # get the image ocid
    image = get_image(compute_client, compartment_id, shape)

    vcn = None
    subnet = None
    igw = None
    nsg = None  # NSG- Network Security Group

    try:
        # create a VCN
        vcn = create_vcn(virtual_network_composite_operations, compartment_id, cidr_block)

        # create a subnet with IGW and Default Route Table
        subnet = create_subnet(virtual_network_composite_operations, vcn, availability_domain, pub_sunet_cidr_block)

        # create internet_gateway
        igw = create_igw(virtual_network_composite_operations, vcn)

        # add route_role to default route table
        add_igw_to_default_rt_rule(virtual_network_client, virtual_network_composite_operations, vcn, igw)

        # Create a NSG + NSG Security List
        nsg = create_nsg(virtual_network_composite_operations, vcn)
        add_nsg_secruity_rules(virtual_network_client, nsg)

        # Launch Instance without NSG
        print("launching Instance ...")
        launch_instance_details = get_instance_instance_details(compartment_id,
                                                                availability_domain,
                                                                shape,
                                                                image,subnet,ssh_public_key)
        instance = launch_instance(compute_client_composite_operations, launch_instance_details)
        print_instance_details(compute_client,virtual_network_client,instance,compartment_id)

        # Launching Instance with NSG
        print("Launching Instance with Network Security Group ...")
        launch_instance_details.create_vnic_details.nsg_ids = [nsg.id]
        instance_with_nsg = launch_instance(compute_client_composite_operations,launch_instance_details)
        print_instance_details(compute_client,virtual_network_client,instance_with_nsg,compartment_id)
    finally:
        if subnet:
            print('End of Instance Creation Script')
