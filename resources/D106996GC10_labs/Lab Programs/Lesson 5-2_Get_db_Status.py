import oci
import os.path
import sys

def get_database_info_lifecycle(database_client, virtual_network_client, identity_client, db_id, config):
        db_info_lifecycle = database_client.get_autonomous_database(db_id).data.lifecycle_state
        return db_info_lifecycle

def get_database_info(database_client, virtual_network_client, identity_client, db_id, config):
        db_info = database_client.get_autonomous_database(db_id).data
        return db_info

if len(sys.argv) != 2:
    raise RuntimeError('This script expects an argument of the OCID of the database')

db_id = sys.argv[1]

config = oci.config.from_file()
database_client = oci.database.DatabaseClient(config, retry_strategy=oci.retry.DEFAULT_RETRY_STRATEGY)
compute_client = oci.core.ComputeClient(config, retry_strategy=oci.retry.DEFAULT_RETRY_STRATEGY)
virtual_network_client = oci.core.VirtualNetworkClient(config, retry_strategy=oci.retry.DEFAULT_RETRY_STRATEGY)
identity_client = oci.identity.IdentityClient(config, retry_strategy=oci.retry.DEFAULT_RETRY_STRATEGY)

database_info = get_database_info(database_client, virtual_network_client, identity_client, db_id, config)
database_info_lifecycle = get_database_info_lifecycle(database_client, virtual_network_client, identity_client, db_id, config)
print('\nDatabase LifeCycle Status')
print('========================')
print(database_info_lifecycle)
print('\n\n\nDatabase Overall Status')
print('========================')
print(database_info)