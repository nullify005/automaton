{% from 'macros.sls' import return_unless_nodes with context %}

istioctl:
    cmd.run:
        - name: |
            set -x
            /usr/local/bin/istioctl version --remote=false | grep {{ salt.pillar.get('istio:istioctl:version') }} && exit 0
            set -e
            WORKDIR=$(mktemp)
            rm -rf ${WORKDIR}
            mkdir -p ${WORKDIR}
            cd ${WORKDIR}
            wget -q {{ salt.pillar.get('istio:istioctl:url') }} -O istioctl.tar.gz
            openssl sha256 istioctl.tar.gz | grep {{ salt.pillar.get('istio:istioctl:sha256') }}
            tar -zxvf istioctl.tar.gz
            find . -name istioctl -exec mv {} /usr/local/bin/ \;
            chmod +x /usr/local/bin/istioctl
            cd
            rm -rf ${WORKDIR}

istio operator:
    cmd.run:
        - name: |
            {{ return_unless_nodes() | indent(12) }}
            istioctl operator init
        - require:
            - cmd: istioctl
        - env:
            - KUBECONFIG: /etc/kubernetes/admin.conf

istio demo:
    cmd.run:
        - name: |
            {{ return_unless_nodes() | indent(12) }}
            kubectl create ns istio-system
            kubectl apply -f - <<EOF
            apiVersion: install.istio.io/v1alpha1
            kind: IstioOperator
            metadata:
              namespace: istio-system
              name: example-istiocontrolplane
            spec:
              profile: demo
            EOF
        - env:
            - KUBECONFIG: /etc/kubernetes/admin.conf
        - require:
            - cmd: istio operator

istio expose config:
    file.managed:
        - name: /etc/kubernetes/conf.d/istio-expose.yaml
        - source: salt://istio/resources/istio-expose.yaml

istio expose:
    cmd.run:
        - name: |
            {{ return_unless_nodes() | indent(12) }}
            kubectl apply -f /etc/kubernetes/conf.d/istio-expose.yaml
        - env:
            - KUBECONFIG: /etc/kubernetes/admin.conf
        - require:
            - file: istio expose config
