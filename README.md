Deploy ICP on openstack:

`# Git clone https://github.com/pravin-dsilva/deploy-ibm-cloud-private`
`# git checkout 3.1.2hdc`

Open the var.tfvars file and fill in the openstack information. Also copy the private and public in a directory and specify the path to the private key in the var.tfvars file

Incase using RHEL image, update the yum repo details in bootstrap_icp_master.sh and bootstrap_icp_worker.sh file

To deploy, install terraform from https://www.terraform.io/. (Works only on x86 systems)

Next, run `terraform init`

Next run `terraform apply --var-file var.tfvars` and type 'yes' for the resources to be created.

Run  `terraform destroy  --var-file var.tfvars` to delete the resources which have been created.








