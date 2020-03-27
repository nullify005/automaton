{% from 'macros.sls' import has_tiller,kubeconfig,istio_enabled with context %}

include:
  - helm
  - flagger

metallb values:
  file.managed:
    - name: /etc/kubernetes/conf.d/metallb-values.yaml
    - source: salt://ingress/resources/metallb-values.yaml
    - template: jinja

metallb ingress:
  cmd.run:
    - name: |
        helm upgrade -i --namespace {{ salt.pillar.get('ingress:namespace') }} metallb stable/metallb \
          --values /etc/kubernetes/conf.d/metallb-values.yaml
    {{ kubeconfig() | indent(4) }}
    - require:
        - file: metallb values
    - onlyif:
        - {{ has_tiller() }}

nginx helm repo:
  cmd.run:
    - name: |
        helm repo add bitnami https://charts.bitnami.com/bitnami
    {{ kubeconfig() | indent(4) }}
    - unless:
      - {{ istio_enabled() }}

nginx ingress:
  cmd.run:
    - name: |
        helm upgrade -i --namespace {{ salt.pillar.get('ingress:namespace') }} nginx-ingress stable/nginx-ingress \
          --set controller.metrics.enabled=true \
          --set controller.podAnnotations."prometheus\.io/scrape"=true \
          --set controller.podAnnotations."prometheus\.io/port"=10254 \
          --set controller.replicaCount=2 \
          --set defaultBackend.replicaCount=2
    {{ kubeconfig() | indent(4) }}
    - onlyif:
      - {{ has_tiller() }}
    - unless:
      - {{ istio_enabled() }}
    - require:
      - cmd: metallb ingress

flagger ingress:
  cmd.run:
    - name: |
        helm upgrade -i ingress-flagger flagger/flagger \
          {%- if salt.pillar.get('istio:enabled') %}
          --namespace {{ salt.pillar.get('istio:namespace') }} \
          --set crd.create=false \
          --set meshProvider=istio \
          --set metricsServer=http://prometheus:9090 \
          {%- else %}
          --namespace {{ salt.pillar.get('ingress:namespace') }} \
          --set prometheus.install=true \
          --set meshProvider=nginx \
          {%- endif %}
          --set slack.url={{ salt.pillar.get('flagger:slack:webhook') }} \
          --set slack.channel={{ salt.pillar.get('flagger:slack:channel') }} \
          --set slack.user=flagger
    {{ kubeconfig() | indent(4) }}
    - onlyif:
      - {{ has_tiller() }}
