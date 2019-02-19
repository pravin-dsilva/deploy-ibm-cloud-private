Deploy ICP on openstack:



## Steps to run the automation 
1. Clone and open the deploy-ibm-cloud-private/terraform/openstack on an x86 system

`# git clone https://github.com/pravin-dsilva/deploy-ibm-cloud-private`

`# cd deploy-ibm-cloud-private/terraform/openstack`

`# git checkout 3.1.2hdc`

2a. Open the var.tfvars file. This file contains all the user variables needed to be filled for openstack project and images. Fill in the openstack information. <br />
2b. Create a private and public key in a directory and specify the path to the private key in the var.tfvars file <br />
2c. Incase using RHEL image, update the yum repo details in bootstrap_icp_master.sh and bootstrap_icp_worker.sh file <br />

3. Install terraform from https://www.terraform.io/downloads.html. (Works only on x86 systems)
4. Run `terraform init`
5. Next run `terraform apply --var-file var.tfvars` and type 'yes' for the resources to be created.

To destroy the resources.
Run  `terraform destroy  --var-file var.tfvars` to delete the resources which have been created.








