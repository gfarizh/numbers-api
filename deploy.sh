#!/bin/bash

function show_help() {
    cat <<EOF
Usage: ${0##*/} [-h] [-t] [-e ENVIRONMENT]
Deploys a Kubernetes Helm chart with in a given environment
         -h               display this help and exit
         -e ENVIRONMENT   environment for which the deployment is perfomed (e.g. stage)
         -t               validate only without performing any deployment
EOF
}

CHART_NAME="numbers-api"
ENVIRONMENT='stage'
DRY_RUN=false

while getopts he:tn:r:v: opt; do
    case $opt in
        h)
            show_help
            exit 0
            ;;
        e)
            ENVIRONMENT=$OPTARG
            ;;
        t)
            DRY_RUN=true
            ;;
        *)
            show_help >&2
            exit 1
            ;;
    esac
done

helm_values=" -f values-${ENVIRONMENT}.yaml"
helm_params=""

# Retrieve the Elasticsearch x-pack license if a KeyVault is provided
if [[ "$DRY_RUN" = false ]]
then
    echo "Installing $CHART_NAME helm chart..."
    helm install $CHART_NAME ./helm-chart
fi

# Install or upgrades the helm chart
(
    if [[ "$DRY_RUN" = true ]]
    then
        echo -n "Installing $CHART_NAME helm chart dry run..."
        helm install --dry-run --debug --generate-name ./helm-chart
        exit 0
    fi
)
