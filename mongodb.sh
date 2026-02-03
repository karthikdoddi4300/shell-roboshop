#!/bin/bash

#while installin a software ,we have to be in root user
userid=$(id -u)
LOGS_FOLDER="/var/log/shell-script"
LOGS_FILE="$LOGS_FOLDE/$0.log"
if [ $userid -ne 0  ]; then 
echo " please run this script with root access"
exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE(){
    if [  $1 -ne 0 ]; then  
        echo " $2  ....is failure"
        exit 1
    else 
        echo "$2  .....is success"
    fi
}

cp mongo.repo  /etc/yum.repos.d/mongo.repo
VALIDATE $? "mongo repo is copied"

dnf install mongodb-org -y 
VALIDATE $? "installing mongodb"

systemctl enable mongod 
VALIDATE $? "enabled the mongodb"

systemctl start mongod 
VALIDATE $? "started mongo db "

sed -i 's/127.0.0.1/0.0.0.0/g'  /etc/mongod.conf
VALIDATE $? "ALLOWING remote connections"

systemctl restart mongod
VALIDATE $? "restarting mongdb"

