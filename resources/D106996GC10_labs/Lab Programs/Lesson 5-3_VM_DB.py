import oci
import os.path
import sys

ADMIN_PASSWORD = "ADummyPassw0rd_#1"
DB_VERSION = '12.1.0.2'
DB_SYSTEM_CPU_CORE_COUNT = 1
DB_SYSTEM_DB_EDITION = 'ENTERPRISE_EDITION'
DB_SYSTEM_SHAPE = 'VM.Standard2.1'
NODE_COUNT = 1
AVAILABLE_STORAGE = 256

def create_vcn(virtual_network, compartment_id, cidr_block):
    vcn_name = 'sdk_vm_vcnc07'
    result = virtual_network.create_vcn(
        oci.core.models.CreateVcnDetails(
            cidr_block=cidr_block,
            display_name=vcn_name,
            compartment_id=compartment_id,
            dns_label='sdkvm'
        )
    )
    get_vcn_response = oci.wait_until(
        virtual_network,
        virtual_network.get_vcn(result.data.id),
        'lifecycle_state',
        'AVAILABLE'
    )
    print('Created VCN: {}'.format(get_vcn_response.data.id))
    return get_vcn_response.data

def create_subnet(virtual_network, vcn, availability_domain):
    subnet_name = 'sdk_vm_subnetc07'
    result = virtual_network.create_subnet(
        oci.core.models.CreateSubnetDetails(
            compartment_id=vcn.compartment_id,
            availability_domain=availability_domain,
            display_name=subnet_name,
            vcn_id=vcn.id,
            cidr_block=vcn.cidr_block,
            dns_label='sdksubvm'
        )
    )
    get_subnet_response = oci.wait_until(
        virtual_network,
        virtual_network.get_subnet(result.data.id),
        'lifecycle_state',
        'AVAILABLE'
    )
    print('Created Subnet: {}'.format(get_subnet_response.data.id))

    return get_subnet_response.data

def list_db_system_shapes(database_client, compartment_id):
    list_db_shape_results = oci.pagination.list_call_get_all_results(
        database_client.list_db_system_shapes,
        availability_domain=availability_domain,
        compartment_id=compartment_id
    )

    print('\nDB System Shapes')
    print('===========================')
    print('{}\n\n'.format(list_db_shape_results.data))


def list_db_versions(database_client, compartment_id):
    list_db_version_results = oci.pagination.list_call_get_all_results(
        database_client.list_db_versions,
        compartment_id
    )

    print('\nDB Versions')
    print('===========================')
    print('{}\n\n'.format(list_db_version_results.data))

    list_db_version_results = oci.pagination.list_call_get_all_results(
        database_client.list_db_versions,
        compartment_id=compartment_id,
        db_system_shape=DB_SYSTEM_SHAPE
    )

    print('\nDB Versions by shape: {}'.format(DB_SYSTEM_SHAPE))
    print('===========================')
    print('{}\n\n'.format(list_db_version_results.data))


if len(sys.argv) != 5:
    raise RuntimeError('Invalid number of arguments provided to the script')
compartment_id = sys.argv[1]
availability_domain = sys.argv[2]
cidr_block = sys.argv[3]
ssh_public_key_path = os.path.expandvars(os.path.expanduser(sys.argv[4]))

config = oci.config.from_file()
database_client = oci.database.DatabaseClient(config)
virtual_network_client = oci.core.VirtualNetworkClient(config)
list_db_system_shapes(database_client, compartment_id)
list_db_versions(database_client, compartment_id)
vcn = None
subnet = None
try:
    vcn = create_vcn(virtual_network_client, compartment_id, cidr_block)
    subnet = create_subnet(virtual_network_client, vcn, availability_domain)
    with open(ssh_public_key_path, mode='r') as file:
        ssh_key = file.read()

    launch_db_system_details = oci.database.models.LaunchDbSystemDetails(
        availability_domain=availability_domain,
        compartment_id=compartment_id,
        cpu_core_count=DB_SYSTEM_CPU_CORE_COUNT,
        database_edition=DB_SYSTEM_DB_EDITION,
        db_home=oci.database.models.CreateDbHomeDetails(
            db_version=DB_VERSION,
            display_name='sdk vm db c07',
            database=oci.database.models.CreateDatabaseDetails(
                admin_password=ADMIN_PASSWORD,
                db_name='VMDBc07'
            )
        ),
        display_name='VMDBc07',
        hostname='sdk-vm-db-hostc07',
        shape=DB_SYSTEM_SHAPE,
        ssh_public_keys=[ssh_key],
        subnet_id=subnet.id,
        node_count=NODE_COUNT,
        initial_data_storage_size_in_gb=AVAILABLE_STORAGE
    )

    launch_response = database_client.launch_db_system(launch_db_system_details)
    print('\nLaunched DB System')
    print('===========================')
    print('{}\n\n'.format(launch_response.data))
    get_db_system_response = oci.wait_until(
        database_client,
        database_client.get_db_system(launch_response.data.id),
        'lifecycle_state',
        'AVAILABLE',
        max_interval_seconds=900,
        max_wait_seconds=21600
    )
    print('\nDB System Available')
    print('===========================')
    print('{}\n\n'.format(get_db_system_response.data))
finally:
    print('VM Database created')                                            
