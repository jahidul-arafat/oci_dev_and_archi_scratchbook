# Provision Oracle Data Science (**_ODS_**) Using Oracle Cloud Infrastructure Resource Manager and Terraform

## Introduction
This solution allows you to provision [Oracle Data Science (**_ODS_**)](https://docs.cloud.oracle.com/en-us/iaas/data-science/using/data-science.htm) and all its related artifacts using [Terraform](https://www.terraform.io/docs/providers/oci/index.html) and [Oracle Cloud Infrastructure Resource Manager](https://docs.cloud.oracle.com/en-us/iaas/Content/ResourceManager/Concepts/resourcemanager.htm).

Below is a list of all artifacts that will be provisioned:

| Component    | Default Name            | Optional |  Notes
|--------------|-------------------------|----------|:-----------|
| [Group](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Tasks/managinggroups.htm)        | Oracle Cloud Infrastructure Users Group              | False    | All Policies are granted to this group, you can add users to this group to grant me access to ODS services.
| [Dynamic Group](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Tasks/managingdynamicgroups.htm) | Oracle Cloud Infrastructure Dynamic Group           | False    | Dynamic Group for Data Science Resources.
| [Policies (compartment)](https://docs.cloud.oracle.com/en-us/iaas/Content/Identity/Concepts/policygetstarted.htm)   | Oracle Cloud Infrastructure Security Policies        | False              | A policy at the compartment level to grant access to ODS
| [Vault Master Key](https://docs.cloud.oracle.com/en-us/iaas/Content/KeyManagement/Concepts/keyoverview.htm) | Oracle Cloud Infrastructure Vault Master Key             | True     | Oracle Cloud Infrastructure Vault Master Key can be used encrypt/decrypt credentials for secured access.

## Prerequisite

- You need a user with an **Administrator** privileges to execute the ORM stack or Terraform scripts.
- Make sure your tenancy has service limits availabilities for the above components in the table.

## Using Terraform

1. Clone repo

   ```bash
   git clone git@github.com:oracle-quickstart/oci-ods-orm.git
   cd oci-ods-orm/terraform
   ```

1. Create a copy of the file **oci-ods-orm/terraform/terraform.tfvars.example** in the same directory and name it **terraform.tfvars**.
1. Open the newly created **oci-ods-orm/terraform/terraform.tfvars** file and edit the following sections:
    - **TF Requirements** : Add your Oracle Cloud Infrastructure user and tenant details:

        ```text
           #*************************************
           #           TF Requirements
           #*************************************
           
           // Oracle Cloud Infrastructure Region, user "Region Identifier" as documented here https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm
           region=""
           // The Compartment OCID to provision artificats within
           compartment_ocid=""
           // Oracle Cloud Infrastructure User OCID, more details can be found at https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five
           user_ocid=""
           // Oracle Cloud Infrastructure tenant OCID, more details can be found at https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five
           tenancy_ocid=""
           // Path to private key used to create Oracle Cloud Infrastructure "API Key", more details can be found at https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/credentials.htm#two
           private_key_path=""
           // "API Key" fingerprint, more details can be found at https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/credentials.htm#two
           fingerprint=""
        ```

    - **IAM Requirements**: Check default values for IAM artifacts and change them if needed

        ```text
           #*************************************
           #          IAM Specific
           #*************************************
           
           // ODS IAM Group Name (no spaces)
           ods_group_name= "DataScienceGroup"
           // ODS IAM Dynamic Group Name (no spaces)
           ods_dynamic_group_name= "DataScienceDynamicGroup"
           // ODS IAM Policy Name (no spaces)
           ods_policy_name= "DataSciencePolicies"
           // If enabled, the needed OCI policies to manage "OCI Vault service" will be created 
           enable_vault_policies= true
        ```

    - **Vault Specific**: check default values for OCI Vault and change them if needed

        ```text
          #*************************************
          #          Vault Specific
          #*************************************
          // If enabled, an Oracle Cloud Infrastructure Vault along with the needed  policies to manage "Vault service" will be created
          enable_vault= true
          // ODS Vault Name
          ods_vault_name= "Data Science Vault"
          // ODS Vault Type, allowed values (VIRTUAL, DEFAULT)
          ods_vault_type = "DEFAULT"
          // If enabled, a Vault Master Key will be created.
          enable_create_vault_master_key = true
          // ODS Vault Master Key Name
          ods_vault_master_key_name = "DataScienceKey"
          // ODS Vault Master Key length, allowed values (16, 24, 32)
          ods_vault_master_key_length = 32
        ```

1. Open file **oci-ods-orm/terraform/provider.tf** and uncomment the (user_id , fingerprint, private_key_path) in the **_two_** providers (**Default Provider** and **Home Provider**)

    ```text
        // Default Provider
        provider "oci" {
          region = var.region
          tenancy_ocid = var.tenancy_ocid
          ###### Uncomment the below if running locally using terraform and not as Oracle Cloud Infrastructure Resource Manager stack #####
        //  user_ocid = var.user_ocid
        //  fingerprint = var.fingerprint
        //  private_key_path = var.private_key_path
          
        }
        
        
        
        // Home Provider
        provider "oci" {
          alias            = "home"
          region           = lookup(data.oci_identity_regions.home-region.regions[0], "name")
          tenancy_ocid = var.tenancy_ocid
          ###### Uncomment the below if running locally using terraform and not as Oracle Cloud Infrastructure Resource Manager stack #####
        //  user_ocid = var.user_ocid
        //  fingerprint = var.fingerprint
        //  private_key_path = var.private_key_path
        
        }
    ```

1. Initialize terraform provider

    ```bash
    > terraform init
    ```

1. Plan terraform scripts

    ```bash
    > terraform plan
   ```
   
1. To visualize terraform plan

    ```bash
   > terraform graph -type=plan | dot -Tpng -o graph.png
   ```

1. Run terraform scripts

    ```bash
    > terraform apply -auto-approve
   ```
To check the status of a Terraform deployment and view the created resources, you can use the Terraform CLI commands. Here are the steps:

**1. Deploy Your Terraform Configuration:**

Before you can check the status and view resources, make sure you have successfully deployed your Terraform configuration using the `terraform apply` command.

```sh
terraform apply
```

**2. Check Resource State and Status:**

After the deployment, you can use the following commands to check the status and view the resources:

- **Check Deployment Status:**

  To see the current status of your infrastructure and any planned changes, use the `terraform show` command:

  ```sh
  terraform show
  ```

- **List Resources:**

  To list the resources that were created, use the `terraform state list` command:

  ```sh
  terraform state list
  ```

- **View Resource Details:**

  To see detailed information about a specific resource, you can use the `terraform state show` command followed by the resource's address (as shown by `terraform state list`). For example:

  ```sh
  terraform state show oci_identity_dynamic_group.ods-dynamic-group

  ```

- **Check Execution Plan:**

  To see the execution plan, which shows the changes Terraform will make when you apply your configuration, use the `terraform plan` command:

  ```sh
  terraform plan
  ```

**3. Output Variables (Optional):**

If you've defined output variables in your Terraform configuration using the `output` block, you can also retrieve the values of these outputs using the `terraform output` command. For example:

```sh
terraform output instance_ip
```

This can be helpful for retrieving important information such as IP addresses, URLs, or other details about your deployed resources.

Remember that the commands and resource addresses might vary based on the providers you are using and the structure of your Terraform configuration. Always consult the Terraform documentation and specific provider documentation for more details about the commands and resources relevant to your use case.

1. To Destroy all created artifacts

    ```bash
    > terraform destroy -auto-approve
   ```

## Contributing

`oci-ods-orm` is an open source project. See [CONTRIBUTING](CONTRIBUTING.md) for details.

Oracle gratefully acknowledges the contributions to `oci-ods-orm` that have been made by the community.
