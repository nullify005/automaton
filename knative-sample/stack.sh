#!/bin/bash

function down {
  minikube delete
}

function istio_prep {
  # download and unpack Istio
  mkdir -p tmp
  cd tmp
  export ISTIO_VERSION=1.5.3
  if [ ! -x istio-${ISTIO_VERSION} ]; then curl -L https://git.io/getLatestIstio | sh -; fi
  cd istio-${ISTIO_VERSION}

  for i in install/kubernetes/helm/istio-init/files/crd*yaml; do kubectl apply -f $i; done

  # make the namespace
  cat <<EOF | kubectl apply -f -
  apiVersion: v1
  kind: Namespace
  metadata:
    name: istio-system
    labels:
      istio-injection: disabled
EOF
}

function istio_gateway {
  # Add the extra cluster local gateway.
  helm template --namespace=istio-system \
    --set gateways.custom-gateway.autoscaleMin=1 \
    --set gateways.custom-gateway.autoscaleMax=2 \
    --set gateways.custom-gateway.cpu.targetAverageUtilization=60 \
    --set gateways.custom-gateway.labels.app='cluster-local-gateway' \
    --set gateways.custom-gateway.labels.istio='cluster-local-gateway' \
    --set gateways.custom-gateway.type='ClusterIP' \
    --set gateways.istio-ingressgateway.enabled=false \
    --set gateways.istio-egressgateway.enabled=false \
    --set gateways.istio-ilbgateway.enabled=false \
    --set global.mtls.auto=false \
    install/kubernetes/helm/istio \
    -f install/kubernetes/helm/istio/example-values/values-istio-gateways.yaml \
    | sed -e "s/custom-gateway/cluster-local-gateway/g" -e "s/customgateway/clusterlocalgateway/g" \
    > ./istio-local-gateway.yaml

  kubectl apply -f istio-local-gateway.yaml
}

function istio_fat {
  istio_prep
  # A template with sidecar injection enabled.
  helm template --namespace=istio-system \
    --set sidecarInjectorWebhook.enabled=true \
    --set sidecarInjectorWebhook.enableNamespacesByDefault=true \
    --set global.proxy.autoInject=disabled \
    --set global.disablePolicyChecks=true \
    --set prometheus.enabled=false \
    --set mixer.adapters.prometheus.enabled=false \
    --set global.disablePolicyChecks=true \
    --set gateways.istio-ingressgateway.autoscaleMin=1 \
    --set gateways.istio-ingressgateway.autoscaleMax=2 \
    --set gateways.istio-ingressgateway.resources.requests.cpu=500m \
    --set gateways.istio-ingressgateway.resources.requests.memory=256Mi \
    --set pilot.autoscaleMin=2 \
    --set pilot.traceSampling=100 \
    install/kubernetes/helm/istio \
    > ./istio.yaml

  kubectl apply -f istio.yaml
  istio_gateway
}

function istio_thin {
  istio_prep
  # A lighter template, with just pilot/gateway.
  # Based on install/kubernetes/helm/istio/values-istio-minimal.yaml
  helm template --namespace=istio-system \
    --set prometheus.enabled=false \
    --set mixer.enabled=false \
    --set mixer.policy.enabled=false \
    --set mixer.telemetry.enabled=false \
    --set pilot.sidecar=false \
    --set pilot.resources.requests.memory=128Mi \
    --set galley.enabled=false \
    --set global.useMCP=false \
    --set security.enabled=false \
    --set global.disablePolicyChecks=true \
    --set sidecarInjectorWebhook.enabled=false \
    --set global.proxy.autoInject=disabled \
    --set global.omitSidecarInjectorConfigMap=true \
    --set gateways.istio-ingressgateway.autoscaleMin=1 \
    --set gateways.istio-ingressgateway.autoscaleMax=2 \
    --set pilot.traceSampling=100 \
    --set global.mtls.auto=false \
    install/kubernetes/helm/istio \
    > ./istio-lean.yaml

  kubectl apply -f istio-lean.yaml
  istio_gateway
}

function knative {
  kubectl apply --selector knative.dev/crd-install=true \
    --filename https://github.com/knative/serving/releases/download/v0.12.0/serving.yaml \
    --filename https://github.com/knative/eventing/releases/download/v0.12.0/eventing.yaml \
    --filename https://github.com/knative/serving/releases/download/v0.12.0/monitoring.yaml
  kubectl apply --filename https://github.com/knative/serving/releases/download/v0.12.0/serving.yaml \
    --filename https://github.com/knative/eventing/releases/download/v0.12.0/eventing.yaml \
    --filename https://github.com/knative/serving/releases/download/v0.12.0/monitoring.yaml
}

function minikube_cluster {
  minikube start --memory=8192 --cpus=6 \
    --kubernetes-version=v1.15.0 \
    --vm-driver=hyperkit \
    --disk-size=30g \
    --extra-config=apiserver.enable-admission-plugins="LimitRanger,NamespaceExists,NamespaceLifecycle,ResourceQuota,ServiceAccount,DefaultStorageClass,MutatingAdmissionWebhook"

  kubectl config use-context minikube
}

function provision {
  minikube_cluster
  istio_thin
  knative
  rm -rf tmp
}

case "${1}" in
  down) down ;;
  stop) minikube stop ;;
  start) minikube start ;;
  up) provision ;;
  *) provision ;;
esac
