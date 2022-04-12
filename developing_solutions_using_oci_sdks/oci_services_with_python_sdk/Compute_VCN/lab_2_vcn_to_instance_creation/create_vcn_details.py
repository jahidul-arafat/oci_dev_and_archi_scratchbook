import oci

# Create a VCN named "oci_python_vcn"
def create_vcn(virtual_network_composite_operations, compartment_id, cidr_block):
    vcn_name = input("Enter VCN Name: ") or "oci_python_vcn"
    create_vcn_details = oci.core.models.CreateVcnDetails(
        cidr_block=cidr_block,
        display_name=vcn_name,
        compartment_id=compartment_id
    )

    create_vcn_response = virtual_network_composite_operations.create_vcn_and_wait_for_state(
        create_vcn_details,
        wait_for_states=[oci.core.models.Vcn.LIFECYCLE_STATE_AVAILABLE]
    )

    vcn = create_vcn_response.data
    print("Created VCN: {}".format(vcn.id))
    print(vcn)
    return vcn


# Create a subnet (Public)
def create_subnet(virtual_network_composite_operations, vcn, availability_domain, pub_sunet_cidr_block):
    subnet_name = input("Enter Subnet Name: ") or "oci_python_subnet_public"

    create_subnet_details = oci.core.models.CreateSubnetDetails(
        compartment_id=vcn.compartment_id,
        availability_domain=availability_domain.name,
        display_name=subnet_name,
        vcn_id=vcn.id,
        cidr_block=pub_sunet_cidr_block
    )

    create_subnet_response = virtual_network_composite_operations.create_subnet_and_wait_for_state(
        create_subnet_details,
        wait_for_states=[oci.core.models.Subnet.LIFECYCLE_STATE_AVAILABLE]
    )

    subnet = create_subnet_response.data
    print("Created Subnet: {}".format(subnet.id))
    print(subnet)
    return subnet


# Create an IGW - Internet Gateway
def create_igw(virtual_network_composite_operations, vcn):
    igw_name = input("Enter IGW Name: ") or "oci_python_igw"
    create_igw_details = oci.core.models.CreateInternetGatewayDetails(
        display_name=igw_name,
        compartment_id=vcn.compartment_id,
        is_enabled=True,
        vcn_id=vcn.id
    )

    create_igw_response = virtual_network_composite_operations.create_internet_gateway_and_wait_for_state(
        create_internet_gateway_details=create_igw_details,
        wait_for_states=[oci.core.models.InternetGateway.LIFECYCLE_STATE_AVAILABLE]
    )

    igw = create_igw_response.data
    print("Created IGW: {}".format(igw.id))
    print(igw)
    return igw


# Add IGW to Default Route Table
def add_igw_to_default_rt_rule(virtual_network_client, virtual_network_composite_operations, vcn, igw):
    get_route_table_response = virtual_network_client.get_route_table(vcn.default_route_table_id)
    route_rules = get_route_table_response.data.route_rules

    print("Current Route Rules for VCN")
    print("===========================")
    print("{}".format(route_rules))

    new_route_rule = oci.core.models.RouteRule(
        cidr_block=None,
        destination="0.0.0.0/0",
        destination_type="CIDR_BLOCK",
        network_entity_id=igw.id
    )

    route_rules.append(new_route_rule)
    update_route_table_details = oci.core.models.UpdateRouteTableDetails(route_rules=route_rules)
    update_route_table_response = virtual_network_composite_operations.update_route_table_and_wait_for_state(
        vcn.default_route_table_id,
        update_route_table_details,
        wait_for_states=[oci.core.models.RouteTable.LIFECYCLE_STATE_AVAILABLE]
    )

    route_table = update_route_table_response.data
    print("Updated Route Rules for VCN")
    print("===========================")
    print("{}".format(route_table.route_rules))


# Create NSG - Network Security Gateway
# Ref: https://docs.oracle.com/en-us/iaas/Content/Network/Concepts/networksecuritygroups.htm
# A network security group (NSG) provides a virtual firewall for a set of cloud resources that all have the same security posture.
# Compared to security lists, NSGs let you separate your VCN's subnet architecture from your application security requirements
# Unlike with security lists, the VCN does not have a default NSG. Also, each NSG you create is initially empty. It has no default security rules.

def create_nsg(virtual_network_composite_operations, vcn):
    nsg_name = input("Enter NSG Name: ") or "oci_python_nsg"
    create_nsg_details = oci.core.models.CreateNetworkSecurityGroupDetails(
        compartment_id=vcn.compartment_id,
        vcn_id=vcn.id,
        display_name=nsg_name
    )

    create_nsg_response = virtual_network_composite_operations.create_network_security_group_and_wait_for_state(
        create_nsg_details,
        wait_for_states=[oci.core.models.NetworkSecurityGroup.LIFECYCLE_STATE_AVAILABLE]
    )

    nsg = create_nsg_response.data
    print("Created NSG: {}".format(nsg.id))
    print(nsg)
    return nsg


# Add Ingress/Egress Security Rules in NSG
def add_nsg_secruity_rules(virtual_network_client, nsg):
    list_sr_response = virtual_network_client.list_network_security_group_security_rules(
        network_security_group_id=nsg.id
    )

    security_rules = list_sr_response.data
    print("Existing Security Rules in NSG")
    print("===============================")
    print(security_rules)

    new_sr_details = oci.core.models.AddSecurityRuleDetails(
        description="Incoming HTTP connections",
        direction="INGRESS",
        is_stateless=False,
        protocol="6",  # ICMP-> 1, TCP-> 6, UDP-> 17, ICMPv6-> 58
        source="0.0.0.0/0",
        source_type="CIDR_BLOCK",
        tcp_options=oci.core.models.TcpOptions(
            destination_port_range=oci.core.models.PortRange(min=80, max=80)
        )
    )

    add_sr_details = oci.core.models.AddNetworkSecurityGroupSecurityRulesDetails(
        security_rules=[new_sr_details]
    )

    virtual_network_client.add_network_security_group_security_rules(
        nsg.id,
        add_sr_details
    )

    list_sr_response = virtual_network_client.list_network_security_group_security_rules(
        nsg.id
    )

    security_rules = list_sr_response.data
    print("Updated Security Rules in NSG")
    print("=============================")
    print(security_rules)
