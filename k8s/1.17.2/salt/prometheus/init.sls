{% from 'macros.sls' import has_tiller,kubeconfig,istio_enabled with context %}

include:
  - helm
  - ingress

prometheus values:
  file.managed:
    - name: /etc/kubernetes/conf.d/prom-operator-values.yaml
    - source: salt://prometheus/resources/prom-operator-values.yaml
    - unless:
      - {{ istio_enabled() }}

prometheus helm:
  cmd.run:
    - name: |
        helm upgrade -i --namespace monitoring monitoring \
          stable/prometheus-operator -f /etc/kubernetes/conf.d/prom-operator-values.yaml
    {{ kubeconfig() | indent(4) }}
    - onlyif:
      - {{ has_tiller() }}
    - unless:
      - {{ istio_enabled() }}
    - require:
      - file: prometheus values
