{# a state to gen a CA for k8s #}

config:
  file.recurse:
    - name: /root/cfssl
    - source: salt://resources/root/cfssl
    - user: root
    - group: root
    - dirmode: 0750
    - filemode: 0640

genca:
  cmd.run:
    - name: |
        cfssl gencert -initca ca-csr.json | cfssljson -bare ca
        cfssl gencert \
          -ca=ca.pem \
          -ca-key=ca-key.pem \
          -config=ca-config.json \
          -profile=kubernetes \
          admin-csr.json | cfssljson -bare admin
        cfssl gencert \
          -ca=ca.pem \
          -ca-key=ca-key.pem \
          -config=ca-config.json \
          -profile=kubernetes \
          kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager
        cfssl gencert \
          -ca=ca.pem \
          -ca-key=ca-key.pem \
          -config=ca-config.json \
          -profile=kubernetes \
          kube-proxy-csr.json | cfssljson -bare kube-proxy
        cfssl gencert \
          -ca=ca.pem \
          -ca-key=ca-key.pem \
          -config=ca-config.json \
          -profile=kubernetes \
          kube-scheduler-csr.json | cfssljson -bare kube-scheduler
        cfssl gencert \
          -ca=ca.pem \
          -ca-key=ca-key.pem \
          -config=ca-config.json \
          -profile=kubernetes \
          service-account-csr.json | cfssljson -bare service-account
        cfssl gencert \
          -ca=ca.pem \
          -ca-key=ca-key.pem \
          -config=ca-config.json \
          -hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,192.168.56.10,192.168.56.11,192.168.56.12,127.0.0.1,kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local,vagrant.local \
          -profile=kubernetes \
          kubernetes-csr.json | cfssljson -bare kubernetes
    - cwd: /root/cfssl/
