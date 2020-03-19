#!/bin/bash

# ./templates-import.sh

oc new-project demo-datagrid

sleep 1

oc new-app datagrid-service\
  -p APPLICATION_USER=test \
  -p APPLICATION_PASSWORD=test.1 \
  -p NUMBER_OF_INSTANCES=3 \
  -p TOTAL_CONTAINER_MEM=512 \
  -e AB_PROMETHEUS_ENABLE=true

sleep 2


# if [ ! -d "folder" ] 
# then
#     echo "Directory istio-workshop DOES NOT exist, cloning repo" 
#     git clone address
# fi
