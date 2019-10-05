{% for name,items in salt.pillar.get('k8s:binaries').items() %}
k8s {{ name }} install:
  cmd.run:
    - name: |
        set +e; set -x
        {{ name }} version | egrep 'Client Version.*v{{ salt.pillar.get('k8s:version') }}'
        if [ $? -eq 0 ]; then exit 0; fi
        set -e
        # assume we aren't installed
        TEMP=$(mktemp)
        wget -q {{ items['url'] }} -O ${TEMP}
        openssl sha512 ${TEMP} | grep -q {{ items['sha'] }}
        tar -zxvf ${TEMP} --strip-components=3 -C /usr/local/bin/
        rm ${TEMP}
{% endfor %}

{% for name,items in salt.pillar.get('cfssl:binaries').items() %}
cfssl {{ name }} install:
  cmd.run:
    - name: |
        set +e; set -x
        if [ -e /usr/local/bin/{{ name }} ]; then exit 0; fi
        set -e
        # assume we aren't installed
        TEMP=$(mktemp)
        wget -q {{ items['url'] }} -O ${TEMP}
        openssl sha512 ${TEMP} | grep -q {{ items['sha'] }}
        mv -vf ${TEMP} /usr/local/bin/{{ name }}
        chmod +x /usr/local/bin/{{ name }}
{% endfor %}

{% set etc = salt.pillar.get('k8s:etc') %}
{% set pki = etc + '/pki' %}

k8s control plane config:
  file.recurse:
    - name: {{ etc }}
    - source: salt://resources{{ etc }}
    - user: root
    - group: root
    - file_mode: 0640
    - makedirs: true
    - dir_mode: 0750
    - template: jinja

k8s kubelet certs:
  cmd.run:
    - name: |
        if [ -e key.pem ]; then exit 0; fi # no need to if it is already there
        cfssl gencert \
          -ca={{ pki }}/ca/cert.pem \
          -ca-key={{ pki }}/ca/key.pem \
          -config={{ pki }}/ca/config.json \
          -hostname={{ grains.get('id') }},{{ grains.get('id') }}.{{ salt.pillar.get('domain') }},{{ salt.grains.get('ip_interfaces:' + salt.pillar.get('interface')) | join(',') }} \
          -profile=kubernetes \
          kubelet.json | cfssljson -bare kubelet
          mv kubelet-key.pem key.pem
          mv kubelet.pem cert.pem
          rm *.csr
    - cwd: {{ pki }}/kubelet/

k8s kubelet config:
  cmd.run:
    - name: |
        kubectl config set-cluster {{ salt.pillar.get('k8s:cluster') }} \
          --certificate-authority={{ pki }}/ca/cert.pem \
          --embed-certs=true \
          --server=https://127.0.0.1:6443 \
          --kubeconfig={{ etc }}/kubelet.conf

        kubectl config set-credentials system:node:{{ grains.get('id') }} \
          --client-certificate={{ pki }}/kubelet/cert.pem \
          --client-key={{ pki }}/kubelet/key.pem \
          --embed-certs=true \
          --kubeconfig={{ etc }}kubelet.conf

        kubectl config set-context default \
          --cluster={{ salt.pillar.get('k8s:cluster') }} \
          --user=system:node:{{ grains.get('id') }} \
          --kubeconfig={{ etc }}/kubelet.conf

        kubectl config use-context default \
          --kubeconfig={{ etc }}/kubelet.conf

k8s proxy config:
  cmd.run:
    - name: |
        kubectl config set-cluster {{ salt.pillar.get('k8s:cluster') }} \
          --certificate-authority={{ pki }}/ca/cert.pem \
          --embed-certs=true \
          --server=https://127.0.0.1:6443 \
          --kubeconfig={{ etc }}/kube-proxy.conf

        kubectl config set-credentials system:kube-proxy \
          --client-certificate={{ pki }}/proxy/cert.pem \
          --client-key={{ pki }}/proxy/key.pem \
          --embed-certs=true \
          --kubeconfig={{ etc }}/kube-proxy.conf

        kubectl config set-context default \
          --cluster={{ salt.pillar.get('k8s:cluster') }} \
          --user=system:kube-proxy \
          --kubeconfig={{ etc }}/kube-proxy.conf

        kubectl config use-context default \
          --kubeconfig={{ etc }}/kube-proxy.conf

k8s controller-manager config:
  cmd.run:
    - name: |
        kubectl config set-cluster {{ salt.pillar.get('k8s:cluster') }} \
          --certificate-authority={{ pki }}/ca/cert.pem \
          --embed-certs=true \
          --server=https://127.0.0.1:6443 \
          --kubeconfig={{ etc }}/kube-controller-manager.conf

        kubectl config set-credentials system:kube-controller-manager \
          --client-certificate={{ pki }}/controller/cert.pem \
          --client-key={{ pki }}/controller/key.pem \
          --embed-certs=true \
          --kubeconfig={{ etc }}/kube-controller-manager.conf

        kubectl config set-context default \
          --cluster={{ salt.pillar.get('k8s:cluster') }} \
          --user=system:kube-controller-manager \
          --kubeconfig={{ etc }}/kube-controller-manager.conf

        kubectl config use-context default \
          --kubeconfig={{ etc }}/kube-controller-manager.conf

k8s scheduler config:
  cmd.run:
    - name: |
        kubectl config set-cluster {{ salt.pillar.get('k8s:cluster') }} \
          --certificate-authority={{ pki }}/ca/cert.pem \
          --embed-certs=true \
          --server=https://127.0.0.1:6443 \
          --kubeconfig={{ etc }}/kube-scheduler.conf

        kubectl config set-credentials system:kube-scheduler \
          --client-certificate={{ pki }}/scheduler/cert.pem \
          --client-key={{ pki }}/scheduler/key.pem \
          --embed-certs=true \
          --kubeconfig={{ etc }}/kube-scheduler.conf

        kubectl config set-context default \
          --cluster={{ salt.pillar.get('k8s:cluster') }} \
          --user=system:kube-scheduler \
          --kubeconfig={{ etc }}/kube-scheduler.conf

        kubectl config use-context default \
          --kubeconfig={{ etc }}/kube-scheduler.conf

k8s admin config:
  cmd.run:
    - name: |
        kubectl config set-cluster {{ salt.pillar.get('k8s:cluster') }} \
          --certificate-authority={{ pki }}/ca/cert.pem \
          --embed-certs=true \
          --server=https://127.0.0.1:6443 \
          --kubeconfig={{ etc }}/admin.conf

        kubectl config set-credentials admin \
          --client-certificate={{ pki }}/admin/cert.pem \
          --client-key={{ pki }}/admin/key.pem \
          --embed-certs=true \
          --kubeconfig={{ etc }}/admin.conf

        kubectl config set-context default \
          --cluster={{ salt.pillar.get('k8s:cluster') }} \
          --user=admin \
          --kubeconfig={{ etc }}/admin.conf

        kubectl config use-context default \
          --kubeconfig={{ etc }}/admin.conf
