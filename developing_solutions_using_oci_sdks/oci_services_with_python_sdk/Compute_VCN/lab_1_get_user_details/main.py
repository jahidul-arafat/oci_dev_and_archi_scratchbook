# Create a sample Python applciation to interact with OCI services.
# Here, we will create a python app to print the current OCI user details in terminal

import oci

if __name__ == "__main__":
    config = oci.config.from_file()
    # Create a service client to OCI
    identity = oci.identity.IdentityClient(config)

    # use the Service client to get the current user with all its details
    user = identity.get_user(config["user"]).data

    # Print the current user details to the terminal
    print(user)
