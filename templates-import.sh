#!/bin/bash

VERSION=7.3-v1.5

for resource in cache-service-template.yaml \
  datagrid-service-template.yaml
do
  oc apply -n openshift -f \
  https://raw.githubusercontent.com/jboss-container-images/jboss-datagrid-7-openshift-image/$VERSION/services/${resource}
done

