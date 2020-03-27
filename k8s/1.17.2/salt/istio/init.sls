{% from 'macros.sls' import return_unless_nodes,has_istio_operator,has_istio_ingress,istio_enabled,kubeconfig with context %}

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
    - onlyif:
      - {{ istio_enabled() }}

istio operator:
  cmd.run:
    - name: |
        {{ return_unless_nodes() | indent(8) }}
        istioctl operator init
    - require:
        - cmd: istioctl
    {{ kubeconfig() | indent(4) }}
    - onlyif:
      - {{ istio_enabled() }}

istio demo config:
  file.managed:
    - name: /etc/kubernetes/conf.d/istio-operator.yaml
    - source: salt://istio/resources/istio-operator.yaml
    - template: jinja
    - onlyif:
      - {{ istio_enabled() }}

istio demo:
  cmd.run:
    - name: |
        {{ return_unless_nodes() | indent(8) }}
        kubectl apply -f /etc/kubernetes/conf.d/istio-operator.yaml
    {{ kubeconfig() | indent(4) }}
    - require:
      - cmd: istio operator
      - file: istio demo config
    - onlyif:
      - {{ has_istio_operator() }}
      - {{ istio_enabled() }}

istio expose config:
  file.managed:
    - name: /etc/kubernetes/conf.d/istio-expose.yaml
    - source: salt://istio/resources/istio-expose.yaml
    - template: jinja
    - onlyif:
      - {{ istio_enabled() }}

istio expose:
  cmd.run:
    - name: |
        {{ return_unless_nodes() | indent(8) }}
        kubectl apply -f /etc/kubernetes/conf.d/istio-expose.yaml
    {{ kubeconfig() | indent(4) }}
    - require:
      - file: istio expose config
    - onlyif:
      - {{ has_istio_operator() }}
      - {{ has_istio_ingress() }}
      - {{ istio_enabled() }}
