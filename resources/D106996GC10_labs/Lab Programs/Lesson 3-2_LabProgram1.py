import oci
config = oci.config.from_file()
identity = oci.identity.IdentityClient(config)
user=identity.get_user(config['user']).data
print(user)