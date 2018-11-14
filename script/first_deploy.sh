#!/usr/bin/env bash

set -e

export PROJECT=techperk-201607
export NAME=thx_app_prod
export TAG=$1
export IMAGE="asia.gcr.io/$PROJECT/$NAME:$TAG"

echo "deploying $IMAGE"

kubectl delete job first-deploy-tasks 2&> /dev/null || true

cat kube/first-deploy-tasks-job.yml.tmpl | envsubst | kubectl create -f -

while [ true ]; do
  phase=`kubectl get pods -a --selector="name=first-deploy-tasks" -o 'jsonpath={.items[0].status.phase}' || 'false'`
if [[ "$phase" != 'Pending' ]]; then
    break
  fi
done

echo '=============== first-deploy-tasks output'
kubectl attach $(kubectl get pods -a --selector="name=first-deploy-tasks" -o 'jsonpath={.items[0].metadata.name}')
echo '==============='

while [ true ]; do
  succeeded=`kubectl get jobs first-deploy-tasks -o 'jsonpath={.status.succeeded}'`
  failed=`kubectl get jobs first-deploy-tasks -o 'jsonpath={.status.failed}'`
if [[ "$succeeded" == "1" ]]; then
    break
  elif [[ "$failed" -gt "0" ]]; then
    kubectl describe job first-deploy-tasks
    kubectl delete job first-deploy-tasks
    echo '!!! Deploy canceled. first-deploy-tasks failed.'
    exit 1
  fi
done

kubectl describe deployment web
kubectl delete job first-deploy-tasks || true
