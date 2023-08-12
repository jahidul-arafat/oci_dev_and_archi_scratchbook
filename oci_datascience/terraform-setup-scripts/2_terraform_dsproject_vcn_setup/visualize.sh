#!/bin/bash

# Prompt the user for their name
echo "Please enter your name:"
read name

# Greet the user with a personalized message
echo "Hello, $name! Welcome to the script to visualize Terraform Plan using ROVER...!!!!!!!."

echo "generate plan file with......."
terraform plan -out plan.out

echo "convert plan file to json version with ..."
terraform show -json plan.out > plan.json

echo "running docker container with ...."
docker run --rm -it -p 9000:9000 -v $(pwd)/plan.json:/src/plan.json im2nguyen/rover:latest -planJSONPath=plan.json

echo "Go to http://localhost:9000"