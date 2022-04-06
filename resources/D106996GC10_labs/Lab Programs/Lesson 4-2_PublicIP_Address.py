import json
import oci
import sys

def get_instance_ip_addresses(compute_client, virtual_network_client, identity_client, instance_id, config):
    instance_info = {
        'private_ips': [],
        'public_ips': []
    }
    instance = compute_client.get_instance(instance_id).data

    vnic_attachments = oci.pagination.list_call_get_all_results(
        compute_client.list_vnic_attachments,
        compartment_id=instance.compartment_id,
        instance_id=instance.id
    ).data

    vnics = [virtual_network_client.get_vnic(va.vnic_id).data for va in vnic_attachments]
    for vnic in vnics:

        if vnic.public_ip:
            instance_info['public_ips'].append(vnic.public_ip)


        private_ips_for_vnic = oci.pagination.list_call_get_all_results(
            virtual_network_client.list_private_ips,
            vnic_id=vnic.id
        ).data

        for private_ip in private_ips_for_vnic:
            instance_info['private_ips'].append(private_ip.ip_address)

            try:
                public_ip = virtual_network_client.get_public_ip_by_private_ip_id(
                    oci.core.models.GetPublicIpByPrivateIpIdDetails(
                        private_ip_id=private_ip.id
                    )
                ).data

                if public_ip.ip_address not in instance_info['public_ips']:
                    instance_info['public_ips'].append(public_ip.ip_address)
            except oci.exceptions.ServiceError as e:
                if e.status == 404:
                    print('No public IP mapping found for private IP: {} ({})'.format(private_ip.id, private_ip.ip_address))
                else:
                    print('Unexpected error when retrieving public IPs: {}'.format(str(e)))

    return instance_info

if len(sys.argv) != 2:
    raise RuntimeError('This script expects an argument of the OCID of the instance you wish to retrieve information for')

instance_id = sys.argv[1]

config = oci.config.from_file()
compute_client = oci.core.ComputeClient(config, retry_strategy=oci.retry.DEFAULT_RETRY_STRATEGY)
virtual_network_client = oci.core.VirtualNetworkClient(config, retry_strategy=oci.retry.DEFAULT_RETRY_STRATEGY)
identity_client = oci.identity.IdentityClient(config, retry_strategy=oci.retry.DEFAULT_RETRY_STRATEGY)

ip_addresses_info = get_instance_ip_addresses(compute_client, virtual_network_client, identity_client, instance_id, config)
print('\n\nPrivate & Public IP Address')
print('========================')
print(json.dumps(ip_addresses_info, sort_keys=True, indent=5))

