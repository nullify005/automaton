{% from 'macros.sls' import has_tiller,has_istio_ingress,kubeconfig with context %}

include:
  - helm
  #- prometheus

flagger helm repo:
  cmd.run:
    - name: helm repo add flagger https://flagger.app

flagger crd config:
  file.managed:
    - name: /etc/kubernetes/conf.d/flagger-crd.yaml
    - source: salt://flagger/resources/crd.yaml

flagger crd apply:
  cmd.run:
    - name: kubectl apply -f /etc/kubernetes/conf.d/flagger-crd.yaml
    - require:
      - file: flagger crd config
    {{ kubeconfig() | indent(4) }}

{#
flagger grafana helm:
  cmd.run:
    - name: |
        helm upgrade -i istio-flagger-grafana flagger/grafana \
          --namespace monitoring \
          --set url=http://prometheus-operated:9090
    - require:
      - cmd: flagger helm repo
      - cmd: flagger crd apply
    - onlyif:
        - {{ has_tiller() }}
        - {{ has_istio_ingress() }}
    {{ kubeconfig() | indent(4) }}
#}
