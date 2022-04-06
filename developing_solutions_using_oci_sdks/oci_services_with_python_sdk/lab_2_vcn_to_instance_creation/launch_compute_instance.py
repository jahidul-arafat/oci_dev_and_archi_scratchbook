import oci


def get_instance_instance_details(compartment_id, AD, shape,
                                  image, subnet, ssh_public_key):
    instance_metadata = {
        'ssh_authorized_keys': ssh_public_key,
        'some_metadata_item': 'some_item_value'
    }

    instance_name = input("Enter Instance Name: ") or "oci_python_instance_dev01"
    instance_source_via_image_details = oci.core.models.InstanceSourceViaImageDetails(
        image_id=image.id
    )

    create_vnic_details = oci.core.models.CreateVnicDetails(
        subnet_id=subnet.id
    )


    launch_instance_details = oci.core.models.LaunchInstanceDetails(
        display_name=instance_name,
        compartment_id=compartment_id,
        availability_domain=AD.name,
        shape=shape.shape,
        metadata=instance_metadata,
        source_details=instance_source_via_image_details,
        create_vnic_details=create_vnic_details
    )

    return launch_instance_details

def launch_instance(compute_client_composite_operations, launch_instance_details):
    launch_instance_response = compute_client_composite_operations.launch_instance_and_wait_for_state(
        launch_instance_details,
        wait_for_states=[oci.core.models.Instance.LIFECYCLE_STATE_RUNNING]
    )

    instance = launch_instance_response.data
    print("Launched Instance: {}".format(instance.id))
    print(instance)

    return instance

def print_instance_details(compute_client, virtual_network_client, instance,compartment_id):
    list_vnic_attachments_response = oci.pagination.list_call_get_all_results(
        compute_client.list_vnic_attachments,
        compartment_id,
        instance_id=instance.id
    )

    vnic_attachments = list_vnic_attachments_response.data
    vnic_attachment = vnic_attachments[0]
    get_vnic_response = virtual_network_client.get_vnic(vnic_attachment.vnic_id)
    vnic = get_vnic_response.data
    print("Virtual Network Interface Card")
    print("==============================")
    print(vnic)
