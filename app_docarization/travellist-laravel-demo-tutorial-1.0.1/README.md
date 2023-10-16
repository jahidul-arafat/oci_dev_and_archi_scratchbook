# Travellist - Laravel Demo App

This is a Laravel 6 demo application to support our Laravel guides.
```bash
# Checkout the below three dockerfiles
cat Dockerfile-app
cat Dockerfile-db
cat Dockerfile-nginx

# Then, build an image with each of these docker file using 
docker build -t <your_dockerhub_repo_name>/travellist-app:<version> -f Dockerfile-app
docker build -t <your_dockerhub_repo_name>/travellist-db:<version> -f Dockerfile-db
docker build -t <your_dockerhub_repo_name>/travellist-nginx:<version> -f Dockerfile-nginx

# then push those images into the docker artifact repo (for now the public repo)
docker push <your_dockerhub_repo_name>/travellist-app:<version>
docker push <your_dockerhub_repo_name>/travellist-db:<version>
docker push <your_dockerhub_repo_name>/travellist-nginx:<version>

# then finally check the docker-compose.yml file
cat docker-compose.yml

# run this file in deattched mode / running in the background
docker run docker-compose up -d

# hit the url using, nginx here will accept your call at port 8000 and forward to app server, which is exposed at port app:900
# check the nginx config here
cat ./doker-compose/nginx/travellist.conf

# check the .env file for db user name and password
cat ./.env

# hit the url
http://localhost:8000    
```
