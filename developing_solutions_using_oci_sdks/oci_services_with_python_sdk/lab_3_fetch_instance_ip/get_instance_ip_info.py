import oci
import sys


def get_instance_ip_addresses(compute_client,virtual_network_client,instance_id):
    instance_info = {
        'pvt_ips': [],
        'pub_ips': []
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
            instance_info['pub_ips'].append(vnic.public_ip)

        pvt_ips_for_vnic = oci.pagination.list_call_get_all_results(
            virtual_network_client.list_private_ips,
            vnic_id=vnic.id
        ).data

        for pvt_ip in pvt_ips_for_vnic:
            instance_info['pvt_ips'].append(pvt_ip.ip_address)
            try:
                public_ip = virtual_network_client.get_public_ip_by_private_ip_id(
                    oci.core.models.GetPublicIpByPrivateIpIdDetails(
                        private_ip_id=pvt_ip.id
                    )
                ).data

                if public_ip.ip_address not in instance_info['pub_ips']:
                    instance_info['pub_ips'].append(public_ip.ip_address)
            except oci.exceptions.ServiceError as e:
                if e.status == 404:
                    print('No public IP mapping found for Private IP: {} ({})'.format(pvt_ip.id, pvt_ip.ip_address))
                else:
                    print("Unexpected error when retrieving public IPs: {}".format(str(e)))

    return instance_info
