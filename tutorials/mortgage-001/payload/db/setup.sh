#!/bin/bash

RIGHT_NOW=$(date +"%x %r %Z")
TIME_STAMP="Updated on $RIGHT_NOW by $USER"
PAYLOAD="payload"
DB2_DOCKER_NAME="icp4d-tutorial"
D=docker


##### Functions

__loadDB2Docker()
{


   $D images > /dev/null 2>&1; rc=$?;
   if [[ $rc != 0 ]]; then
                echo "Docker Not Installed. Are you on ICP4D cluster environment ?"
                exit 1
   fi

   if [[ ! `docker images --quiet store/ibmcorp/db2_developer_c:11.1.4.4-ppc64le` ]]; then
        echo -e "\nLoading Docker $DB2_DOCKER_NAME ..."
       # $D run -d --name $DB2_DOCKER_NAME -p 50000:50000 -e DB2INST1_PASSWORD=password -e LICENSE=accept  ibmcom/db2express-c:latest db2start
      docker run -h db2server_  --name $DB2_DOCKER_NAME --restart=always  --detach   --privileged=true -p 50000:50000 -p 55000:55000  --env-file .env_list   -v /root/db2cdata:/database store/ibmcorp/db2_developer_c:11.1.4.4-ppc64le

        #Wait couple of minutes to make sure db2 instance started and online
        sleep 120
   fi

   echo -e "\nMaking some space for data"
   #make a sample directory
   $D   exec $DB2_DOCKER_NAME bash -c  "mkdir -p samples/payload"

   echo -e "\nMoving Payload to DB2"
   #push the payload
   $D cp data  $DB2_DOCKER_NAME:/samples/payload
   $D cp load.sh  $DB2_DOCKER_NAME:/samples/payload
   $D cp runMortgageCmd.sh  $DB2_DOCKER_NAME:/samples/payload

   echo -e "\nDB2 being loaded with data for you to try out"

   #run setup the payload
   $D exec  $DB2_DOCKER_NAME  bash -c "cd /samples/payload && chmod -R 777 data  &&  ./load.sh"


}

__loadDB2Docker
