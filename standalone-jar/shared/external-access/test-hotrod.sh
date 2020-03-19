#!/usr/bin/env bash

set -e

readonly PROGNAME=$(basename $0)
readonly ARGS="$@"
SERVICE_NAME="cache-service"

usage() {
	cat <<- EOF
	usage: $PROGNAME options

	Builds, deploys and tests the quickstart and associated services on OpenShift.

	OPTIONS:
		-c --clean               delete the services and quickstart from OpenShift.
		-h --help                show this help.
		-q --quickstart-only     only test the quickstart, it assumes the service is running.
		-s --service-name        service to test, can be either cache-service or datagrid-service.
		                         cache-service is default.
		-i --image               optional parameter with image to test.
		-x --debug               debug


	Examples:
		Test quickstart on cache-service:
		$PROGNAME

		Only tests quickstart, assumes service is already running:
		$PROGNAME --quickstart-only

		Clean and remove quickstart and cache-service deployment:
		$PROGNAME --clean

		Test quickstart on datagrid-service:
		$PROGNAME --service-name datagrid-service

		Clean and remove quickstart and datagrid-service deployment:
		$PROGNAME --clean --service-name datagrid-service

		Test quickstart on custom image:
		$PROGNAME --image ...

		Run with extra logging:
		$PROGNAME --debug
	EOF
}

cmdline() {
    local arg=
    for arg
    do
        local delim=""
        case "$arg" in
            #translate --gnu-long-options to -g (short options)
            --clean)                   args="${args}-c ";;
            --help)                    args="${args}-h ";;
            --quickstart-only)         args="${args}-q ";;
            --service-name)            args="${args}-s ";;
            --image)                   args="${args}-i ";;
            --debug)                   args="${args}-x ";;
            #pass through anything else
            *) [[ "${arg:0:1}" == "-" ]] || delim="\""
                args="${args}${delim}${arg}${delim} ";;
        esac
    done

    #Reset the positional parameters to the short options
    eval set -- $args

    while getopts "chqs:i:x" OPTION
    do
         case $OPTION in
         c)
             readonly CLEAN=1
             ;;
         h)
             usage
             exit 0
             ;;
         q)
             readonly QUICKSTART_ONLY=1
             ;;
         s)
             SERVICE_NAME=$OPTARG
             ;;
         i)
             readonly IMAGE=$OPTARG
             ;;
         x)
             readonly DEBUG='-x'
             set -x
             ;;
        esac
    done

    return 0
}

stopService() {
    local svcName=$1
    local routeName=$2
    echo "--> Stop services for template '${svcName}' and routes hotrod='${routeName}'"

    oc delete all,secrets,sa,templates,configmaps,daemonsets,clusterroles,rolebindings,serviceaccounts --selector=template=${svcName} || true
    oc delete template ${svcName} || true
    oc delete route ${routeName} || true
}


startService() {
    local svcName=$1
    local appName=$2
    echo "--> Start service from template '${svcName}' as '${appName}'"

    local imageBase="https://raw.githubusercontent.com/jboss-container-images/jboss-datagrid-7-openshift-image"

    oc create -f \
        "${imageBase}/7.3-v1.0/services/${svcName}-template.yaml"

    if [ -n "${IMAGE+1}" ]; then
        oc new-app ${svcName} \
            -p APPLICATION_USER=test \
            -p APPLICATION_PASSWORD=changeme \
            -p APPLICATION_NAME=${appName} \
            -p IMAGE=${IMAGE}
    else
        oc new-app ${svcName} \
            -p APPLICATION_USER=test \
            -p APPLICATION_PASSWORD=changeme \
            -p APPLICATION_NAME=${appName}
    fi
}


createRoutes() {
    local appName=$1
    local routeName=$2

    # Create a pass-through route
    oc create route passthrough ${routeName} --port=hotrod --service ${appName}
}


waitForService() {
    local appName=$1
    echo "--> Wait for '${appName}'"

    ready="false"
    while [ "$ready" != "true" ];
    do
        ready=`oc get pod -l application=${appName} -o jsonpath="{.items[0].status.containerStatuses[0].ready}"`
        status=`oc get pod -l application=${appName} -o jsonpath="{.items[0].status.containerStatuses[0].state}"`
        echo "Pod: ready=${ready},status=${status}"
        sleep 10
    done
}


buildQuickstart() {
    mvn -s ../../../settings.xml clean package
}


startQuickstart() {
    local appName=$1

    echo "--> Start quickstart for '${appName}'"

    mvn -s ../../../settings.xml exec:java -Dexec.args="${appName}"
}


getIp() {
    set +e
    minishift ip
    local result=$?
    if [ ${result} -ne 0 ]; then
        echo "127.0.0.1"
    fi
    set -e
}


main() {
    cmdline $ARGS

    local demo="quickstart"

    local svcName=${SERVICE_NAME}
    local appName="${svcName}-external-access"

    local routeName="${appName}-hotrod-route"

    echo "--> Test params: service=${svcName},app=${appName}";

    local publicIp=$(getIp)
    oc login ${publicIp}:8443 -u developer -p developer

    if [ -n "${CLEAN+1}" ]; then
        stopService ${svcName} ${routeName}
    else
        if [ -z "${QUICKSTART_ONLY+1}" ]; then
            echo "--> Restart service";

            stopService ${svcName} ${routeName}
            startService ${svcName} ${appName}
            createRoutes ${appName} ${routeName}
            waitForService ${appName}
        fi

        echo "--> Run quickstart";

        buildQuickstart

        startQuickstart ${appName}
    fi

}


main
