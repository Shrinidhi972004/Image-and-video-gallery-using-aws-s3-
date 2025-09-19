#!/bin/bash

INSTANCE_ID="i-xxxxxxxxxxxxxxxxx"

ipv4_address=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

file_to_find="../application/frontend/.env"

current_url=$(grep REACT_APP_API_URL $file_to_find || true)

if [[ "$current_url" != "REACT_APP_API_URL=http://${ipv4_address}:5002" ]]; then
    if [ -f $file_to_find ]; then
        sed -i -e "s|REACT_APP_API_URL.*|REACT_APP_API_URL=http://${ipv4_address}:5002|g" $file_to_find
    else
        echo "ERROR: File not found."
        exit 1
    fi
fi
