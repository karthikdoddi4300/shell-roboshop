#!/bin/bash
AMI_ID="ami-0220d79f3f480ecf5"
SGID="sg-0d9028f369846db6c"

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
    else 
        IP=$(
            aws ec2 describe-instances\
            --instance-ids $INSTANCE_ID\
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text
          )
    fi
done


 
    