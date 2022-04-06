
# OCI CLI SDK
```shell
# get all OCI IAM commands avaibale
> oci iam 

# check the oci version
> oci --version

# get the OCI Object Storage Bucket Namespace
> oci os ns get 

# List all compartments in a given tenancy
> oci iam compartment list -c <tenancy_ocid> --all
> oci iam compartment list # of <tenancy_ocid> is not provided, it will get this info from ~/.oci/config

# List all or 5 users from an OCI tenancy
> oci iam user list -c <tenanct_ocid> --all
> oci iam user list --all
> oci iam user list --limit 5
> oci iam user list --output table 

# List all available regions in the OCI
> oci iam region list 
> oci iam region list --output table

# To access the Bucket
> oci os bucket -h  # help option
> oci os bucket list -c <tenancy_ocid>        # root compartment
> oci os bucket list -c <compartment_ocid>    # your compartment OCID
```
