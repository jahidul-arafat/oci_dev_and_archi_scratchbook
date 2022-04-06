import oci
import time
import sys

config = oci.config.from_file()
db_list_client = oci.database.DatabaseClient(config)

def create_adb_preview(db_client,compartment_id):
    adb_request = oci.database.models.CreateAutonomousDatabaseDetails()

    adb_request.compartment_id = compartment_id
    adb_request.cpu_core_count = 1
    adb_request.data_storage_size_in_tbs = 1
    adb_request.db_name = "UsrATPDBc07"
    adb_request.display_name = "USER-AUTONOMOUS-DB-PREVIEW"
    adb_request.db_workload = "OLTP"
    adb_request.license_model = adb_request.LICENSE_MODEL_BRING_YOUR_OWN_LICENSE

    adb_request.admin_password = "Welcome1!SDK"
    adb_request.is_auto_scaling_enabled = False
    adb_request.isPreviewVersionWithServiceTermsAccepted = True

    adb_response = db_client.create_autonomous_database(
        create_autonomous_database_details=adb_request,
        retry_strategy=oci.retry.DEFAULT_RETRY_STRATEGY)

    print("Created Autonomous Preview Database {}".format(adb_response.data.id))

    return adb_response.data.id

def listPreviewVersion(compartment_id):
    response = db_list_client.list_autonomous_db_preview_versions(compartment_id)
    print("List Autonomous Preview Versions {}".format(response))

if len(sys.argv) != 2:
    raise RuntimeError('Invalid number of arguments provided to the script')

print("creating database")
compartment_id = sys.argv[1]

db_client = oci.database.DatabaseClient(config)

listPreviewVersion(compartment_id)
adb__preview_id = create_adb_preview(db_client,compartment_id)

time.sleep(180)
