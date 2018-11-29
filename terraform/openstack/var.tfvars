openstack_user_name = "pravind@us.ibm.com"
openstack_password = "Rockdanew54."
openstack_project_name = "BlueRidgeGroup-P"
openstack_domain_name = "ibm"
openstack_auth_url = "https://hdc-prod-cloud.hursley.ibm.com:5000/v3"
#SLES
#openstack_image_id = "be2e4d9e-986e-414e-9649-8a2f2a934641"

#PKVM-Ubt16.04-Srv-ppc64le
openstack_image_id = "2f59b02b-4776-4130-b73b-1d926a2cf996"

#RHEL-75-ga-ppc64le
#openstack_image_id = "eb36cf6c-5705-403b-a662-5c9d0b4c1c49"

#KVM-Ubt16.04-Srv-x64
#openstack_image_id = "9bee5dc3-6522-4d82-ad31-5b38abba1380"

#openstack_image_id = "ee7a47b9-e473-4dca-a6be-7934e61cebc8"
#openstack_flavor_id_master_node = "a41216d4-95ac-4ba8-a09a-16af81d4e85a"
openstack_flavor_id_master_node = "5"
#openstack_flavor_id_worker_node = "62930e20-e31e-48ea-a384-210383ec98eb"
openstack_flavor_id_worker_node = "5"
openstack_ssh_key_file = "/root/deploy-ibm-cloud-private/keys/id_rsa"
openstack_network_name = "BlueRidgeGroup-P_Network"
openstack_floating_network_name = "admin_floating_net"
openstack_security_groups = ["default", "icp-rules"]
openstack_availability_zone = "PowerKVM"
#openstack_availability_zone = "nova"
instance_prefix = "pravin-509"
icp_version = "3.1.1"
icp_edition = "ce"
icp_install_user = "cloudusr"
#icp_download_location = "http://9.20.204.129/ICP/ibm-cloud-private-ppc64le-3.1.1.tar.gz"
#icp_download_location = "http://9.20.204.129/ICP/ibm-cloud-private-x86_64-3.1.1.tar.gz"
icp_num_workers = "1"
#icp_architecture = "amd64"
icp_architecture = "ppc64le"
