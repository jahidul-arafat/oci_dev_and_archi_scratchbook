# KeyCloak Docker Instance Configuration Backup
Keycloak is an open-source identity and access management tool that provides user federation, strong authentication, user management, fine-grained authorization, and more.

It is a single sign-on solution for web apps and RESTful web services, designed to make security simple so that it is easy for application developers to secure the apps and services they have deployed in their organization

## If you already have keycloak server running @docker 
#### **** Dont stop the Keycloak Main Server until the POC is successful
### Step-1: Taking the DB backup of the Keycloak docker instance
```bash
# Check the docker container id running the keyclock
> docker ps 
3940cd16ff60   quay.io/keycloak/keycloak:latest   "/opt/keycloak/bin/k…"   19 minutes ago   Up 19 minutes   8080/tcp, 8443/tcp, 0.0.0.0:8180->8180/tcp   keycloak

# enter into the keycloak docker instanctes shell
> docker exec -it 3940cd16ff60 /bin/bash

# upon successfully accessing keycloak docker shell, find the databases where keycloak instance is storing its confoguration data
#inside docker container
bash-5.1$ 
bash-5.1$ pwd
/
bash-5.1$ cd
bash-5.1$ pwd
/opt/keycloak       # this is the keycloak's home directory, from there we will dig into its 'data' directroy to backup the configuration data to one of our local (hosting server's) directory
bash-5.1$ ls
bin  conf  data  lib  LICENSE.txt  providers  README.md  themes  version.txt
bash-5.1$ cd /opt/keycloak/data/h2/     # lets check the dbs in the data directory
bash-5.1$ ls
keycloakdb.lock.db  keycloakdb.mv.db  keycloakdb.trace.db

# Lets copy the keycloak docker's data directory into local directory
#@local or hosting server
# docker cp <docker_container_id>:/opt/keycloak/data /path/to/local
> docker cp 3940cd16ff60:/opt/keycloak/data /Users/jarotball/study/gc_keycloak          
> ls /Users/jarotball/study/gc_keycloak/data/h2     # check if the dbs are copied successfully      
keycloakdb.lock.db	keycloakdb.mv.db	keycloakdb.trace.db

```
### Step-2: Now, create a new keycloak docker instance with this existing configuration
```bash
# Create a docker-compose file mapping the keycload's data volume with the your local volume 
# Create a new directory i.e. gc_keycloak and cd there and create a new docker-compose.yaml
# see, we are using the keycloak image 'quay.io/keycloak/keycloak:latest'
# if you have someother image, then modify the image accordingly
# certain version of the image could have an impact on your spring-application integration
> cd gc_keycloak
> vim docker-compose.yaml
version: '3'
services:
  keycloak:
    image: quay.io/keycloak/keycloak:latest
    container_name: keycloak
    ports:
      - "8180:8180"
    environment:
      - KEYCLOAK_ADMIN=admin        # change the admin username and password if required
      - KEYCLOAK_ADMIN_PASSWORD=admin
    volumes:
      - /Users/jarotball/study/gc_keycloak/data:/opt/keycloak/data      # modify the local volume name '/Users/jarotball/study/gc_keycloak/data' accordingly
    command: start-dev --http-port 8180 --http-relative-path /auth
> docker-compose up -d  # run the docker in detached mode
> docker ps         # check if the docker container up successfully

```
### Step-3: Now go to the browser and check if the old keycloak configurations are there or not
```
http://localhost:8180/auth      #login with your username and password and check if all the users, groups, client configurations are there 

```