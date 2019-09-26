#!/usr/bin/env bash

set -ex

gcloud_auth () {
    gcloud container clusters get-credentials $CLUSTER_NAME
}

if [[ "$TRAVIS_PULL_REQUEST" == "false" && "$TRAVIS_BRANCH" == "staging" ]]
then
    CLUSTER_NAME=staging
    gcloud_auth
    LAST_RELEASE=`helm history bc-rates-only-staging | tail -1 | awk '{print $1}'`
    gcloud kms decrypt --location=global --keyring=Env_values --key=env-vars --ciphertext-file=charts/secrets.yaml.enc --plaintext-file=charts/secrets.yaml
    helm upgrade --install bc-rates-only-staging --values charts/values.yaml --values charts/secrets.yaml --set imageTag=${TRAVIS_COMMIT} --wait charts/
    if [ $? -ne 0 ]; then
        helm rollback bc-rates-only-staging ${LAST_RELEASE}
        exit 1
    fi
elif [[ "$TRAVIS_PULL_REQUEST" == "false" && "$TRAVIS_BRANCH" == "master" ]]
then
    CLUSTER_NAME=production
    gcloud_auth
    LAST_RELEASE=`helm history bc-rates-only-production | tail -1 | awk '{print $1}'`
    gcloud kms decrypt --location=global --keyring=Env_values --key=env-vars --ciphertext-file=charts/secrets.prod.yaml.enc --plaintext-file=charts/secrets.prod.yaml 
    helm upgrade --install bc-rates-only-production --values charts/values.yaml --values charts/secrets.prod.yaml --set imageTag=${TRAVIS_COMMIT} --wait charts/
    if [ $? -ne 0 ]; then
        helm rollback bc-rates-only-production ${LAST_RELEASE}
        exit 1
    fi    
fi
