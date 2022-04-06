import oci
import os.path
import sys
OPERATING_SYSTEM = 'Oracle Linux'
# ****************************************************************************************************
def get_availability_domain(identity_client, compartment_id):
    list_availability_domains_response = oci.pagination.list_call_get_all_results(
        identity_client.list_availability_domains,
        compartment_id
    )
    availability_domain = list_availability_domains_response.data[0]
    print()
    print('Running in Availability Domain: {}'.format(availability_domain.name))
    return availability_domain
# ****************************************************************************************************
def get_shape(compute_client, compartment_id, availability_domain):
    list_shapes_response = oci.pagination.list_call_get_all_results(
        compute_client.list_shapes,
        compartment_id,
        availability_domain=availability_domain.name
    )
    shapes = list_shapes_response.data
    if len(shapes) == 0:
        raise RuntimeError('No available shape was found.')

    vm_shapes = list(filter(lambda shape: shape.shape.startswith("VM.Standard2.1"), shapes))
    if len(vm_shapes) == 0:
        raise RuntimeError('No available VM shape was found.')
    shape = vm_shapes[0]
    print('Found Shape: {}'.format(shape.shape))
    return shape
# ****************************************************************************************************
def get_image(compute, compartment_id, shape):
    list_images_response = oci.pagination.list_call_get_all_results(
        compute.list_images,
        compartment_id,
        operating_system=OPERATING_SYSTEM,
        shape=shape.shape
    )
    images = list_images_response.data
    if len(images) == 0:
        raise RuntimeError('No available image was found.')
    image = images[0]
    print('Found Image: {}'.format(image.id))
    print()
    return image

# ****************************************************************************************************
def create_vcn(virtual_network_composite_operations, compartment_id, cidr_block):
    vcn_name = 'sdk_vcn_c07'
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
    print('Created VCN: {}'.format(vcn.id))
    print('{}'.format(vcn))
    print()
    return vcn
# ***************************************************************************************************
def create_subnet(virtual_network_composite_operations, vcn, availability_domain):
    subnet_name = 'sdk_subnet_c07'
    create_subnet_details = oci.core.models.CreateSubnetDetails(
        compartment_id=vcn.compartment_id,
        availability_domain=availability_domain.name,
        display_name=subnet_name,
        vcn_id=vcn.id,
        cidr_block=vcn.cidr_block
    )
    create_subnet_response = virtual_network_composite_operations.create_subnet_and_wait_for_state(
        create_subnet_details,
        wait_for_states=[oci.core.models.Subnet.LIFECYCLE_STATE_AVAILABLE]
    )
    subnet = create_subnet_response.data
    print('Created Subnet: {}'.format(subnet.id))
    print('{}'.format(subnet))
    print()
    return subnet
# ****************************************************************************************************
def create_internet_gateway(virtual_network_composite_operations, vcn):
    internet_gateway_name = 'sdk_ig_c07'
    create_internet_gateway_details = oci.core.models.CreateInternetGatewayDetails(
        display_name=internet_gateway_name,
        compartment_id=vcn.compartment_id,
        is_enabled=True,
        vcn_id=vcn.id
    )
    create_internet_gateway_response = virtual_network_composite_operations.create_internet_gateway_and_wait_for_state(
        create_internet_gateway_details,
        wait_for_states=[oci.core.models.InternetGateway.LIFECYCLE_STATE_AVAILABLE]
    )
    internet_gateway = create_internet_gateway_response.data

    print('Created internet gateway: {}'.format(internet_gateway.id))
    print('{}'.format(internet_gateway))
    print()

    return internet_gateway
# ******************************************************************************************************
def add_route_rule_to_default_route_table_for_internet_gateway(
        virtual_network_client, virtual_network_composite_operations, vcn, internet_gateway):
    get_route_table_response = virtual_network_client.get_route_table(vcn.default_route_table_id)
    route_rules = get_route_table_response.data.route_rules

    print('Current Route Rules For VCN')
    print('===========================')
    print('{}'.format(route_rules))
    print()

    route_rule = oci.core.models.RouteRule(
        cidr_block=None,
        destination='0.0.0.0/0',
        destination_type='CIDR_BLOCK',
        network_entity_id=internet_gateway.id
    )
    route_rules.append(route_rule)
    update_route_table_details = oci.core.models.UpdateRouteTableDetails(route_rules=route_rules)
    update_route_table_response = virtual_network_composite_operations.update_route_table_and_wait_for_state(
        vcn.default_route_table_id,
        update_route_table_details,
        wait_for_states=[oci.core.models.RouteTable.LIFECYCLE_STATE_AVAILABLE]
    )
    route_table = update_route_table_response.data

    print('Updated Route Rules For VCN')
    print('===========================')
    print('{}'.format(route_table.route_rules))
    print()

    return route_table
# ****************************************************************************************************
def create_network_security_group(virtual_network_composite_operations, compartment_id, vcn):
    network_security_group_name = 'sdk_network_security_c07'
    create_network_security_group_details = oci.core.models.CreateNetworkSecurityGroupDetails(
        display_name=network_security_group_name,
        compartment_id=compartment_id,
        vcn_id=vcn.id
    )
    create_network_security_group_response = virtual_network_composite_operations.create_network_security_group_and_wait_for_state(
        create_network_security_group_details,
        wait_for_states=[oci.core.models.RouteTable.LIFECYCLE_STATE_AVAILABLE]
    )
    network_security_group = create_network_security_group_response.data

    print('Created Network Security Group: {}'.format(network_security_group.id))
    print('{}'.format(network_security_group))
    print()

    return network_security_group
#****************************************************************************************************
def add_network_security_group_security_rules(virtual_network_client, network_security_group):
    list_security_rules_response = virtual_network_client.list_network_security_group_security_rules(
        network_security_group.id
    )
    security_rules = list_security_rules_response.data

    print('Current Security Rules in Network Security Group')
    print('================================================')
    print('{}'.format(security_rules))
    print()

    add_security_rule_details = oci.core.models.AddSecurityRuleDetails(
        description="Incoming HTTP connections",
        direction="INGRESS",
        is_stateless=False,
        protocol="6",  # 1: ICMP, 6: TCP, 17: UDP, 58: ICMPv6
        source="0.0.0.0/0",
        source_type="CIDR_BLOCK",
        tcp_options=oci.core.models.TcpOptions(
            destination_port_range=oci.core.models.PortRange(min=80, max=80)
        )
    )
    add_security_rules_details = oci.core.models.AddNetworkSecurityGroupSecurityRulesDetails(
        security_rules=[add_security_rule_details]
    )
    virtual_network_client.add_network_security_group_security_rules(
        network_security_group.id,
        add_security_rules_details
    )

    list_security_rules_response = virtual_network_client.list_network_security_group_security_rules(
        network_security_group.id
    )
    security_rules = list_security_rules_response.data

    print('Updated Security Rules in Network Security Group')
    print('================================================')
    print('{}'.format(security_rules))
    print()
# ****************************************************************************************************
def get_launch_instance_details(compartment_id, availability_domain, shape, image, subnet, ssh_public_key):
    instance_metadata = {
        'ssh_authorized_keys': ssh_public_key,
        'some_metadata_item': 'some_item_value'
    }

    instance_name = 'sdk_instance_c07'
    instance_source_via_image_details = oci.core.models.InstanceSourceViaImageDetails(
        image_id=image.id
    )
    create_vnic_details = oci.core.models.CreateVnicDetails(
        subnet_id=subnet.id
    )
    launch_instance_details = oci.core.models.LaunchInstanceDetails(
        display_name=instance_name,
        compartment_id=compartment_id,
        availability_domain=availability_domain.name,
        shape=shape.shape,
        metadata=instance_metadata,
        source_details=instance_source_via_image_details,
        create_vnic_details=create_vnic_details
    )
    return launch_instance_details
# ****************************************************************************************************
def launch_instance(compute_client_composite_operations, launch_instance_details):
    launch_instance_response = compute_client_composite_operations.launch_instance_and_wait_for_state(
        launch_instance_details,
        wait_for_states=[oci.core.models.Instance.LIFECYCLE_STATE_RUNNING]
    )
    instance = launch_instance_response.data
    print('Launched Instance: {}'.format(instance.id))
    print('{}'.format(instance))
    print()
    return instance
# ****************************************************************************************************
def print_instance_details(compute_client, virtual_network_client, instance):
    list_vnic_attachments_response = oci.pagination.list_call_get_all_results(
        compute_client.list_vnic_attachments,
        compartment_id,
        instance_id=instance.id
    )
    vnic_attachments = list_vnic_attachments_response.data
    vnic_attachment = vnic_attachments[0]
    get_vnic_response = virtual_network_client.get_vnic(vnic_attachment.vnic_id)
    vnic = get_vnic_response.data
    print('Virtual Network Interface Card')
    print('==============================')
    print('{}'.format(vnic))
    print()
# ****************************************************************************************************
if __name__ == "__main__":
    if len(sys.argv) != 4:
        raise RuntimeError('Invalid number of arguments')

    compartment_id = sys.argv[1]
    cidr_block = sys.argv[2]
    with open(os.path.expandvars(os.path.expanduser(sys.argv[3])), mode='r') as file:
        ssh_public_key = file.read()

    # Default config file and profile
    config = oci.config.from_file()
    identity_client = oci.identity.IdentityClient(config)
    compute_client = oci.core.ComputeClient(config)
    compute_client_composite_operations = oci.core.ComputeClientCompositeOperations(compute_client)
    virtual_network_client = oci.core.VirtualNetworkClient(config)
    virtual_network_composite_operations = oci.core.VirtualNetworkClientCompositeOperations(virtual_network_client)

    availability_domain = get_availability_domain(identity_client, compartment_id)
    shape = get_shape(compute_client, compartment_id, availability_domain)
    image = get_image(compute_client, compartment_id, shape)

    vcn = None
    subnet = None
    internet_gateway = None
    network_security_group = None
    instance = None
    instance_with_network_security_group = None

    try:
        vcn = create_vcn(virtual_network_composite_operations, compartment_id, cidr_block)
        subnet = create_subnet(virtual_network_composite_operations, vcn, availability_domain)
        internet_gateway = create_internet_gateway(virtual_network_composite_operations, vcn)
        add_route_rule_to_default_route_table_for_internet_gateway(virtual_network_client, virtual_network_composite_operations, vcn, internet_gateway)

        network_security_group = create_network_security_group(virtual_network_composite_operations, compartment_id, vcn)
        add_network_security_group_security_rules(virtual_network_client, network_security_group)

        print('Launching Instance ...')
        launch_instance_details = get_launch_instance_details(
            compartment_id, availability_domain, shape, image, subnet, ssh_public_key
        )
        instance = launch_instance(compute_client_composite_operations, launch_instance_details)
        print_instance_details(compute_client, virtual_network_client, instance)

        print('Launching Instance with Network Security Group ...')
        launch_instance_details.create_vnic_details.nsg_ids = [network_security_group.id]
        instance_with_network_security_group = launch_instance(
            compute_client_composite_operations, launch_instance_details
        )
        print_instance_details(compute_client, virtual_network_client, instance_with_network_security_group)

    finally:
        if subnet:
            print('End of Instance creation script')

                                                                         
