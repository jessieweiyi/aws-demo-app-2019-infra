#!/bin/bash

echo -e "Local DynamoDB Service\n"
echo Host: $1
echo Port: $2
echo DynamoDB Table: $3

sleep 4

continue=1
echo -n "waiting for Local Dynamodb Service online to create the table"
while (($continue == 1))
do
   if nc -z $1 $2 &> /dev/null
   then
      echo -e "\nLocal DynamoDB Service is ready!"
      continue=0
   else
      echo -n "."
   fi
done

sleep 5
AWS_ACCESS_KEY_ID=your_access_key_id AWS_SECRET_ACCESS_KEY=your_secret_access_key aws dynamodb create-table --endpoint-url http://$1:$2 --table-name $3 --attribute-definitions AttributeName=jobId,AttributeType=S --key-schema AttributeName=jobId,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
