{% from 'macros.sls' import kubeconfig,istio_enabled with context %}

include:
  - helm

flagger nginx test helm:
  file.managed:
    - name: /etc/kubernetes/conf.d/podinfo.yaml
    - source: salt://flagger/resources/nginx/podinfo.yaml
    - template: jinja
    - require_in:
      - cmd: flagger nginx test namespace
    - unless:
      - {{ istio_enabled() }}

flagger nginx test ingress:
  file.managed:
    - name: /etc/kubernetes/conf.d/podinfo-ingress.yaml
    - source: salt://flagger/resources/nginx/podinfo-ingress.yaml
    - template: jinja
    - require_in:
      - cmd: flagger nginx test namespace
    - unless:
      - {{ istio_enabled() }}

flagger nginx test canary:
  file.managed:
    - name: /etc/kubernetes/conf.d/podinfo-canary.yaml
    - source: salt://flagger/resources/nginx/podinfo-canary.yaml
    - template: jinja
    - require_in:
      - cmd: flagger nginx test namespace
    - unless:
      - {{ istio_enabled() }}

flagger nginx test namespace:
  cmd.run:
    - runas: root
    - name: |
        helm repo add podinfo https://stefanprodan.github.io/podinfo
        helm upgrade -i --namespace test podinfo podinfo/podinfo -f /etc/kubernetes/conf.d/podinfo.yaml
        helm upgrade -i flagger-loadtester flagger/loadtester --namespace=test
        kubectl apply -f /etc/kubernetes/conf.d/podinfo-ingress.yaml
        kubectl apply -f /etc/kubernetes/conf.d/podinfo-canary.yaml
    {{ kubeconfig() | indent(4) }}
    - unless:
      - {{ istio_enabled() }}

{# --------------- ISTIO ---------------- #}

flagger istio test canary:
  file.managed:
    - name: /etc/kubernetes/conf.d/podinfo-canary.yaml
    - source: salt://flagger/resources/istio/podinfo-canary.yaml
    - template: jinja
    - onlyif:
      - {{ istio_enabled() }}

flagger istio test namespace:
  cmd.run:
    - runas: root
    - name: |
        kubectl create ns test
        kubectl label namespace test istio-injection=enabled
        kubectl apply -k github.com/weaveworks/flagger//kustomize/podinfo
        kubectl apply -k github.com/weaveworks/flagger//kustomize/tester
        kubectl apply -f /etc/kubernetes/conf.d/podinfo-canary.yaml
    {{ kubeconfig() | indent(4) }}
    - onlyif:
      - {{ istio_enabled() }}
