#!/bin/bash

rm -f /tmp/hosts

for i in *.json ; do
  COMPONENT=$(echo $i | sed -e 's/.json//')
  IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${COMPONENT}" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)
  if [ -z "${IP}" ]; then
    continue
  fi
  echo $IP component=$COMPONENT ansible_password=DevOps321 >>/tmp/hosts
  sed -e "s/IPADDRESS/${IP}/" -e "s/DNS_NAME/${COMPONENT}/" record >/tmp/record.json
  aws route53 change-resource-record-sets --hosted-zone-id Z00460833MOFH2ED30IKW --change-batch file:///tmp/record.json
done