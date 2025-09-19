#!/bin/bash

INSTANCE_ID="i-xxxxxxxxxxxxxxxxx"

ipv4_address=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

file_to_find="../application/backend/.env"

current_url=$(grep FRONTEND_URL $file_to_find || true)

if [[ "$current_url" != "FRONTEND_URL=\"http://${ipv4_address}:9000\"" ]]; then
    if [ -f $file_to_find ]; then
        sed -i -e "s|FRONTEND_URL.*|FRONTEND_URL=\"http://${ipv4_address}:9000\"|g" $file_to_find
    else
        echo "ERROR: File not found."
        exit 1
    fi
fi
