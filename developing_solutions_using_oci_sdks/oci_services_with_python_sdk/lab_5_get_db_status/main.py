import oci

def get_db_info(db_client, db_ocid):
    db_info = db_client.get_autonomous_database(db_ocid).data
    db_info_lifecycle = db_client.get_autonomous_database(db_ocid).data.lifecycle_state
    return db_info, db_info_lifecycle


if __name__ == "__main__":
    db_ocid = input("Enter the ADB OCID : ") or \
                     "ocid1.autonomousdatabase.oc1.ap-mumbai-1.anrg6ljr2br7tayamkwwqqyklvlmuk2jzu62qfdr3qceh2fwntpixvg7xcea"

    # Default Config File and Profile
    config = oci.config.from_file()
    db_client = oci.database.DatabaseClient(config, retry_strategy=oci.retry.DEFAULT_RETRY_STRATEGY)

    db_info, db_info_lifecycle = get_db_info(db_client,db_ocid)

    print("Database LifeCycle Status: {}".format(db_info_lifecycle))
    print()
    print("Database Overall Status: {}".format(db_info))
