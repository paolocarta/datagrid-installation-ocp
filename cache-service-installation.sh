#!/bin/bash

# ./templates-import.sh

oc new-project demo-cache

sleep 1

oc new-app cache-service\
  -p APPLICATION_USER=test \
  -p APPLICATION_PASSWORD=test.1 \
  -p NUMBER_OF_INSTANCES=3 \
  -p REPLICATION_FACTOR=2 \
  -p TOTAL_CONTAINER_MEM=512 \
  -p EVICTION_POLICY=evict \

sleep 1


# if [ ! -d "folder" ] 
# then
#     echo "Directory istio-workshop DOES NOT exist, cloning repo" 
#     git clone address
# fi