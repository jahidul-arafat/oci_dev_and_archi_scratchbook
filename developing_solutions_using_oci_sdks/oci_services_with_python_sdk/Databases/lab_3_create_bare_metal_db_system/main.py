import oci
import os.path

#===================================== Defining  Global Variables =======================================
# A. Global OCI Variables
COMPARTMENT_OCID = input("Enter the Compartment OCID : ") or \
                   "ocid1.compartment.oc1..aaaaaaaa5hplc4q67l76kzeygvcbbu73da3kxhndhogtfvxgwtpd2xzayecq"
SUBNET_OCID = input("Enter Subnet OCID: ") or \
              "ocid1.subnet.oc1.ap-mumbai-1.aaaaaaaaiw4njnl74may6r4p3frgth5laqfr6kl6g52kkevolx43r2ugx7ra"# Public/Private subnet_ocid # I have used prublic_subnet_ocid
AD = input("Enter AD: ") or "oAOj:AP-MUMBAI-1-AD-1"
SSH_PUBLIC_KEY_PATH = input("Enter SSH Public Key Path: ") or "~/.ssh/id_rsa.pub"

# B. Global DB Variables
DB_SYSTEM_DB_NAME = "PyBMDB"
DB_SYSTEM_DISPLAY_NAME = "Python SDK BM DB"
DB_SYSTEM_HOSTNAME = "pysdk-bm-db-host"
ADMIN_PASSWORD = "ADummyPassw0rd_#1"
DB_VERSION = "19.14.0.0"
DB_SYSTEM_CPU_CORE_COUNT = 2
DB_SYSTEM_DB_EDITION = 'STANDARD_EDITION'
DB_SYSTEM_SHAPE = 'BM.DenseIO1.36'  #<<----


# Optional-1
def list_db_system_shapes(db_client):
    list_db_shape_results = oci.pagination.list_call_get_all_results(
        db_client.list_db_system_shapes,
        availability_domain=AD,
        compartment_id=COMPARTMENT_OCID
    )

    print("\nDB System Shapes Available: \n==============================")
    print("{}".format(list_db_shape_results.data))


# Optional-2
def list_db_versions(db_client):
    list_db_version_results = oci.pagination.list_call_get_all_results(
        db_client.list_db_versions,
        compartment_id=COMPARTMENT_OCID,
        db_system_shape=DB_SYSTEM_SHAPE
    )

    print("\nDB Versions Available: \n================================")
    print("{}".format(list_db_version_results.data))


# Core - Create Bare Metal DB System
def create_vm_db_system(db_client):
    with open(os.path.expandvars(os.path.expanduser(SSH_PUBLIC_KEY_PATH)), mode='r') as file:
        ssh_public_key = file.read()

    # Add the DB System Details
    # Then, get the DB System Response from these details
    db_system_details = oci.database.models.LaunchDbSystemDetails(
        # Provide Basic Information for the DB System
        compartment_id=COMPARTMENT_OCID,
        display_name=DB_SYSTEM_DB_NAME,
        availability_domain=AD,
        shape=DB_SYSTEM_SHAPE,
        cpu_core_count=DB_SYSTEM_CPU_CORE_COUNT,  # this is related to shape selection

        # Configure the DB System
        database_edition=DB_SYSTEM_DB_EDITION,

        # Configure Storage Percentage

        # Create the DB Home
        db_home=oci.database.models.CreateDbHomeDetails(
            db_version=DB_VERSION,
            display_name=DB_SYSTEM_DISPLAY_NAME,
            database=oci.database.models.CreateDatabaseDetails(
                admin_password=ADMIN_PASSWORD,
                db_name=DB_SYSTEM_DB_NAME
            )
        ),

        # Add the SSH Keys
        ssh_public_keys=[ssh_public_key],

        # Choose the License included

        # Specify the network information
        subnet_id=SUBNET_OCID,
        hostname=DB_SYSTEM_HOSTNAME #hostname-prefix
    )

    # Launching the DB System with the DB_SYSTEM_DETAILS mentioned above
    db_system_response = db_client.launch_db_system(db_system_details)

    print("\nLaunched DB System\n=================================")
    print("{}".format(db_system_response.data))

    # Once the DB System is launched, fetch the following information
    # lifecycle_state
    # Available : YES/NO
    fetch_specific_db_system_response = oci.wait_until(
        db_client,
        db_client.get_db_system(db_system_response.data.id),
        'lifecycle_state',
        'AVAILABLE',
        max_interval_seconds=900,
        max_wait_seconds=21600
    )

    print("\nDB System:: Bare Metal:: Available + LifeCycle Status\n===================================")
    print("{}".format(fetch_specific_db_system_response.data))



def intro():
    print("Create a VM Database System in Oracle Cloud Infrastructure")
    print("By Jahidul Arafat, Architect (Technology Solution and Cloud), Oracle Corporation")
    print("""
    Chef-Knife
    ---------------
    1. List the Existing DB System Shapes
    2. List the DB versions compliance with a specific Bare Metal DB System shape
    3. Create the Bare Metal Database System
    """)
    response = input("Do you want to Continue: [Y/n]")
    if response != "Y" or "y'":
        exit()

def optional_exection(db_client):
    response = input("Do you want to execute the options: [Y/n]")
    if response != "Y" or "y'":
        exit()
    list_db_system_shapes(db_client)
    list_db_versions(db_client)


def db_access_instruction():
    print("""
    Once your VM DB System is ready, try below:
    > ssh opc@<public-ip-of-db-system>
    > sqlplus / as sysdba
    SQL> show pdbs
    SQL> show con_name
    SQL> alter session set container=<pdb_of_db_system>
    SQL> show con_name
    SQL> exit
    """)


if __name__ == "__main__":
    intro()

    # Configure the clients
    config = oci.config.from_file()
    db_client = oci.database.DatabaseClient(config)
    virtual_network_client = oci.core.VirtualNetworkClient(config)

    # This is optional list, where I am gonna print the db_system_shapes and versions available
    optional_exection(db_client)

    # Core part - Lets create the DB System
    try:
        create_vm_db_system(db_client)
    finally:
        print("Bare Metal Database Created")
        db_access_instruction()


