# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
# Redesigned by "Jahidul Arafat", Solution Architect, Oracle

#*************************************
#          IAM Specific - overriding the default defined in variables.tf
#*************************************

// ODS IAM Group Name (no spaces)
ods_group_name         = "ds-kata-group"
// ODS IAM Dynamic Group Name (no spaces)
ods_dynamic_group_name = "ds-kata-dynamic-group"
// ODS IAM Policy Name (no spaces)
ods_policy_name        = "ds-kata-policies"

#*************************************
#          Vault Specific
#*************************************
// If enabled, an OCI Vault along with the needed OCI policies to manage "Vault service" will be created
enable_vault                   = true
// ODS Vault Name
ods_vault_name                 = "Data Science Vault"
// ODS Vault Type, allowed values (VIRTUAL, DEFAULT)
ods_vault_type                 = "DEFAULT"
// If enabled, a Vault Master Key will be created.
enable_create_vault_master_key = true
// ODS Vault Master Key Name
ods_vault_master_key_name      = "Data Science Master Key"
// ODS Vault Master Key length, allowed values (16, 24, 32)
ods_vault_master_key_length    = 32

#*************************************
#           TF Requirements - Not required, as I am gonna export these from a separate .sh script
#*************************************

#OCI Region, user "Region Identifier" as documented here https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm
region           = "ap-mumbai-2"
#The Compartment OCID to provision artificats within
compartment_ocid = "aaa"
#OCI User OCID, more details can be found at https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five
user_ocid        = "aaa"
#OCI tenant OCID, more details can be found at https://docs.cloud.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#five
tenancy_ocid     = "aaa"
#Path to private key used to create OCI "API Key", more details can be found at https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/credentials.htm#two
private_key_path = "aaa"
# "API Key" fingerprint, more details can be found at https://docs.cloud.oracle.com/en-us/iaas/Content/General/Concepts/credentials.htm#two
fingerprint      = "aaa"
