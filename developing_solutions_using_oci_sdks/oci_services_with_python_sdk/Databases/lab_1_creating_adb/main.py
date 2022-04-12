# Before creating ADB with Python SDK
# Please do this lab in
# https://apexapps.oracle.com/pls/apex/dbpm/r/livelabs/workshop-attendee-2?p210_workshop_id=582&p210_type=2&session=117480241536119

import oci
import time


def create_adb_preview(db_client, compartment_id):
    # Create an adb_details object
    adb_details = oci.database.models.CreateAutonomousDatabaseDetails()

    # Provide Basic Information for the ADB
    # The Autonomous Database name can contain only alphanumeric characters
    adb_details.compartment_id = compartment_id
    adb_details.db_name = "PythonSDKADB"
    adb_details.display_name = "python-sdk-adb"

    # Choose a workload type
    # Type-1: Data Warehouse (ADW)
    # Type-2: Transaction Processing (OLTP)
    # Type-3: JSON
    # Type-4: APEX
    adb_details.db_workload = "OLTP"

    # Choose a deployment type
    # Shared Infrastructure
    # Dedicated Infrastructure
    adb_details.is_dedicated = False

    # Configure the Database
    adb_details.is_free_tier = True
    adb_details.cpu_core_count = 1
    adb_details.data_storage_size_in_tbs = 1
    adb_details.is_auto_scaling_enabled = False

    # Create Administrator Credentials
    # Username: ADMIN # You cant change it
    adb_details.admin_password = "ComplexPa$s0rd!"

    # Choose Network Access

    # Choose a License Type
    adb_details.license_model = adb_details.LICENSE_MODEL_LICENSE_INCLUDED

    # Accept the terms and proceed to creating the ADB
    adb_details.isPreviewVersionWithServiceTermsAccepted = True

    # Create the ADB now
    adb_response = db_client.create_autonomous_database(
        create_autonomous_database_details=adb_details,
        retry_strategy=oci.retry.DEFAULT_RETRY_STRATEGY
    )

    print("Created Autonomous Database Preview {}".format(adb_response.data.id))

    return adb_response.data.id



if __name__ == "__main__":
    compartment_id = input("Enter the Compartment OCID : ") or \
                     "ocid1.compartment.oc1..aaaaaaaa5hplc4q67l76kzeygvcbbu73da3kxhndhogtfvxgwtpd2xzayecq"

    # Default Config File and Profile
    config = oci.config.from_file()
    db_client = oci.database.DatabaseClient(config)

    print("Creating Database ...")
    adb_preview_id = create_adb_preview(db_client, compartment_id)

    time.sleep(180) # this will be running for 3 minutes until ADB creation completes
