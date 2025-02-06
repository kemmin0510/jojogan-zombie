#!/bin/bash

# Function to input a variable
input_variable() {
    local var_name=$1
    local var_value

    if [ -z "${!var_name}" ]; then
        read -p "Enter $var_name: " var_value
        echo "$var_name=$var_value" >> ./mlflow-docker-compose/.env
    fi
}

# Delete the .env file if it exists
if [ -f ./mlflow-docker-compose/.env ]; then
    rm ./mlflow-docker-compose/.env
fi

# Create the .env file
input_variable "AWS_ACCESS_KEY_ID"
input_variable "AWS_SECRET_ACCESS_KEY"
input_variable "MYSQL_DATABASE"
input_variable "MYSQL_USER"
input_variable "MYSQL_PASSWORD"
input_variable "MYSQL_ROOT_PASSWORD"