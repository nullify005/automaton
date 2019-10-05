#!/bin/bash

set -ex
PKI="../salt/resources/etc/kubernetes/pki"
HOSTNAMES="10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,192.168.56.10,192.168.56.11,192.168.56.12,127.0.0.1,kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local,vagrant.local"

# gen the CA
cfssl gencert -initca ca-csr.json | cfssljson -bare ca
mv ca.pem ${PKI}/ca/cert.pem
mv ca-key.pem ${PKI}/ca/key.pem

# gen the certs
cfssl gencert \
  -ca=${PKI}/ca/cert.pem \
  -ca-key=${PKI}/ca/key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  admin-csr.json | cfssljson -bare admin
  mv admin-key.pem ${PKI}/admin/key.pem
  mv admin.pem ${PKI}/admin/cert.pem

cfssl gencert \
  -ca=${PKI}/ca/cert.pem \
  -ca-key=${PKI}/ca/key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager
  mv kube-controller-manager-key.pem ${PKI}/controller/key.pem
  mv kube-controller-manager.pem ${PKI}/controller/cert.pem

cfssl gencert \
  -ca=${PKI}/ca/cert.pem \
  -ca-key=${PKI}/ca/key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-proxy-csr.json | cfssljson -bare kube-proxy
  mv kube-proxy-key.pem ${PKI}/proxy/key.pem
  mv kube-proxy.pem ${PKI}/proxy/cert.pem

cfssl gencert \
  -ca=${PKI}/ca/cert.pem \
  -ca-key=${PKI}/ca/key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  kube-scheduler-csr.json | cfssljson -bare kube-scheduler
  mv kube-scheduler-key.pem ${PKI}/scheduler/key.pem
  mv kube-scheduler.pem ${PKI}/scheduler/cert.pem

cfssl gencert \
  -ca=${PKI}/ca/cert.pem \
  -ca-key=${PKI}/ca/key.pem \
  -config=ca-config.json \
  -profile=kubernetes \
  service-account-csr.json | cfssljson -bare service-account
  mv service-account-key.pem ${PKI}/service-account/key.pem
  mv service-account.pem ${PKI}/service-account/cert.pem

cfssl gencert \
  -ca=${PKI}/ca/cert.pem \
  -ca-key=${PKI}/ca/key.pem \
  -config=ca-config.json \
  -hostname=${HOSTNAMES} \
  -profile=kubernetes \
  kubernetes-csr.json | cfssljson -bare kubernetes
  mv kubernetes-key.pem ${PKI}/api/key.pem
  mv kubernetes.pem ${PKI}/api/cert.pem

rm *.csr
