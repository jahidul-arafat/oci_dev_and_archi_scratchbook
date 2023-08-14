# This is a sample Python script.
import os

# Press ⌃R to execute it or replace it with your code.
# Press Double ⇧ to search everywhere for classes, files, tool windows, actions, and settings.

import oci
import ads
import numpy as np
import pandas as pd
from ads.catalog.project import ProjectCatalog
import os

os.environ["OCI_RESOURCE_PRINCIPAL_VERSION"] = "2.2"

# setting resource principal as the authentication mechanism using ads sdk
ads.set_auth(auth='resource_principal')
compartment_id = 'ocid1.compartment.oc1..aaaaaaaaoelxgznolu5rxuvmtvcyxo5zhbwyyyicdtpg7sjivrffkdcwarya'
pc = ProjectCatalog(compartment_id=compartment_id)
new_project = pc.create_project(display_name='new_project',
                                description='new project',
                                compartment_id=compartment_id)
#print the new project details
print(new_project)


def print_hi(name):
    # Use a breakpoint in the code line below to debug your script.
    print('Successfully loaded ADS SDK')  # Press ⌘F8 to toggle the breakpoint.


# Press the green button in the gutter to run the script.
if __name__ == '__main__':
    print_hi('PyCharm')

# See PyCharm help at https://www.jetbrains.com/help/pycharm/
