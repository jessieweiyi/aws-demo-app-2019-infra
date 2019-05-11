#!/bin/bash

echo -e "Local SQS Service\n"
echo Host: $1
echo Port: $2
echo SQS Queue: $3

sleep 1

continue=1
echo -n "waiting for Local SQS Service online to create the queue"
while (($continue == 1))
do
   if nc -z $1 $2 &> /dev/null
   then
      echo -e "\nLocal SQS Service is ready!"
      continue=0
   else
      echo -n "."
   fi
done

sleep 1
AWS_DEFAULT_REGION=ap-southeast-2 AWS_ACCESS_KEY_ID=your_access_key_id AWS_SECRET_ACCESS_KEY=your_secret_access_key aws sqs create-queue --endpoint-url http://$1:$2 --queue-name $3
