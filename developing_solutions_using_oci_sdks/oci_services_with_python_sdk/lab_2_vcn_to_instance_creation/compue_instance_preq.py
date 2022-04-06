import oci
import sys
import os.path

OPERATING_SYSTEM = 'Oracle Linux'

# Get the ADs in current Region and choose 1 AD
def get_availability_domain(identity_client, compartment_id):
    list_availability_domain_response = oci.pagination.list_call_get_all_results(
        identity_client.list_availability_domains,
        compartment_id
    )
    availability_domain = list_availability_domain_response.data[0]
    print("Running in AD: {}".format(availability_domain.name))
    return availability_domain


# get the instance shape
def get_shape(compute_client, compartment_id, availability_domain):
    list_shapes_response = oci.pagination.list_call_get_all_results(
        compute_client.list_shapes,
        compartment_id,
        availability_domain=availability_domain.name
    )

    shapes = list_shapes_response.data
    if len(shapes) == 0:
        raise RuntimeError('No available shape found.')

    vm_shapes = list(filter(lambda shape: shape.shape.startswith("VM.Standard2.1"), shapes))
    if len(vm_shapes) == 0:
        raise RuntimeError('No available VM shape was found.')
    shape = vm_shapes[0]
    print("Found shape: {}".format(shape.shape))
    return shape


# get instance image
def get_image(compute_client, compartment_id, shape):
    list_image_response = oci.pagination.list_call_get_all_results(
        compute_client.list_images,
        compartment_id,
        operating_system=OPERATING_SYSTEM,
        shape=shape.shape
    )

    images = list_image_response.data
    if len(images) == 0:
        raise RuntimeError("No available image was found.")

    image = images[0]
    print("Found Image : {}".format(image))
    return image
