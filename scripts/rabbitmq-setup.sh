#!/bin/bash
set -euo pipefail
set -a 
source .env
set +a
echo "Starting rabbitMQ installation and setup..."

# Install Rabbitmq if missing 
if command -v rabbitmqctl >/dev/null 2>&1; then
    echo "RabbitMQ is already present : $(rabbitmqctl status | grep RabbitMQ | head -1 || true)"
else
    echo "Installing RabbitMQ..."
    apt update -y 
    apt install -y rabbitmq-server
    echo "RabbitMQ installed."
fi 

# enable management plugin
if rabbitmq-plugins list -e | grep -q rabbitmq_management; then 
    echo "RabbitMQ management plugin already enable."
else
    echo echo "Enabling RabbitMQ management plugin..."
    rabbitmq-plugins enable rabbitmq_management
fi

# start RabbitMQ service
if systemctl is-active --quiet rabbitmq-server; then
    echo "RabbitMQ service already running."
else
    echo "Starting RabbitMQ service..."
    systemctl start rabbitmq-server
    systemctl enable rabbitmq-server
    echo "RabbitMQ server service started."
fi

# create Rabbit user if missing
if rabbitmqctl list_users | grep -q "^${RABBITMQ_USER}\b"; then 
    echo "User : ${RABBITMQ_USER} already exists."
else
    echo "Creating user : ${RABBITMQ_USER}...;"
    rabbitmqctl add_user ${RABBITMQ_USER} ${RABBITMQ_PASSWORD}
    echo "User : ${RABBITMQ_USER} has been creating with password : ${RABBITMQ_PASSWORD}."
fi 

# Set the user as administrator
if rabbitmqctl list_users | grep -q "^${RABBITMQ_USER}\b.*\[administrator\]";then
    echo "User is already set as administrator."
else 
    echo "Setting user tag as administrator..."
    rabbitmqctl set_user_tags ${RABBITMQ_USER} administrator
    echo "User ${RABBITMQ_USER} tag set to administrator." 
    rabbitmqctl list_users | grep "^${RABBITMQ_USER}\b"
fi

# set all permissions to user 

if rabbitmqctl list_user_permissions ${RABBITMQ_USER} | grep -q '.* .* .*'; then # error occur bad cmd
    echo "User have already all permissions."
else 
    rabbitmqctl set_permissions -p / ${RABBITMQ_USER} ".*" ".*" ".*"
    echo "All permissions granted for user : ${RABBITMQ_USER}."
fi 

echo "RabbitMQ setup successfully finished."
