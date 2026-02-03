#!/bin/bash
AMI_ID="ami-0220d79f3f480ecf5"
SGID="sg-0d9028f369846db6c"
HOSTED_ZONE="Z05627073KQ1HLECLE2G7 "
DOMAIN_NAME="hodophile.online"

for instance in $@
do 
    INSTANCE_ID=$(aws ec2 run-instances \
        --image-id $AMI_ID\
        --instance-type t3.micro \
        --security-group-ids $SGID \
        --key-name karthikkeypai \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]"\
        --query 'Instances[0].InstanceId' \
        --output text 
        )
    if [ $instance == frontend ]; then
         IP=$(
            aws ec2 describe-instances\
            --instance-ids $INSTANCE_ID\
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text
          )
          RECORD_NAME="$DOMAIN_NAME" # hodophile.online
    else 
        IP=$(
            aws ec2 describe-instances\
            --instance-ids $INSTANCE_ID\
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text
          )
          RECORD_NAME="$instance.$DOMAIN_NAME" #mongodb.hodophile.online
    fi
    echo "ip address : $IP"

aws route53 change-resource-record-sets \
    --hosted-zone-id $HOSTED_ZONE \
    --change-batch '
        {
        "Comment": "Update A record to new IP address",
        "Changes": [
            {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "A",
                "TTL": 300,
                "ResourceRecords": [
                {
                    "Value": "'$IP'"
                }
                ]
            }
            }
        ]
        }

        '

done


 
    