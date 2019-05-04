#!/bin/bash

echo -e "Local S3 Service\n"
echo Host: $1
echo Port: $2
echo S3 Bucket: $3

sleep 1

continue=1
echo -n "waiting for Local S3 Service online to create the bucket"
while (($continue == 1))
do
   if nc -z $1 $2 &> /dev/null
   then
      echo -e "\nLocal S3 Service is ready!"
      continue=0
   else
      echo -n "."
   fi
done

sleep 1
AWS_ACCESS_KEY_ID=your_access_key_id AWS_SECRET_ACCESS_KEY=your_secret_access_key aws s3 mb --endpoint-url http://$1:$2 s3://$3
