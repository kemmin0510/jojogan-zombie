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

# List of input variables
input_variables = [
    "AWS_ACCESS_KEY_ID",
    "AWS_SECRET_ACCESS_KEY",
    "MYSQL_DATABASE",
    "MYSQL_USER",
    "MYSQL_PASSWORD",
    "MYSQL_ROOT_PASSWORD"
]

# Open the .env file
with open('.env', 'w') as env_file:
    for var in input_variables:
        # Request user input for the variable
        value = input(f"Nhập giá trị cho {var}: ")
        # Write the variable to the .env file
        env_file.write(f"{var}={value}\n")