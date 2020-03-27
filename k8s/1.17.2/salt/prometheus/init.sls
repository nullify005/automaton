{% from 'macros.sls' import has_tiller,kubeconfig with context %}

include:
  - helm
  - ingress

prometheus values:
  file.managed:
    - name: /etc/kubernetes/conf.d/prom-operator-values.yaml
    - source: salt://prometheus/resources/prom-operator-values.yaml

prometheus helm:
  cmd.run:
    - name: |
        helm upgrade -i --namespace monitoring prometheus \
          stable/prometheus-operator -f /etc/kubernetes/conf.d/prom-operator-values.yaml
    {{ kubeconfig() | indent(4) }}
    - onlyif:
      - {{ has_tiller() }}
    - require:
      - file: prometheus values
