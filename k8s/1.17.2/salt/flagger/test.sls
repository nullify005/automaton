{% from 'macros.sls' import kubeconfig with context %}

include:
  - helm

flagger test helm:
  file.managed:
    - name: /etc/kubernetes/conf.d/podinfo.yaml
    - source: salt://flagger/resources/podinfo.yaml
    - template: jinja

flagger test ingress:
  file.managed:
    - name: /etc/kubernetes/conf.d/podinfo-ingress.yaml
    - source: salt://flagger/resources/podinfo-ingress.yaml
    - template: jinja

flagger test canary:
  file.managed:
    - name: /etc/kubernetes/conf.d/podinfo-canary.yaml
    - source: salt://flagger/resources/podinfo-canary.yaml
    - template: jinja

flagger test namespace:
  cmd.run:
    - runas: root
    - name: |
        helm repo add podinfo https://stefanprodan.github.io/podinfo
        helm upgrade -i --namespace test podinfo podinfo/podinfo -f /etc/kubernetes/conf.d/podinfo.yaml
        helm upgrade -i flagger-loadtester flagger/loadtester --namespace=test
        kubectl apply -f /etc/kubernetes/conf.d/podinfo-ingress.yaml
        kubectl apply -f /etc/kubernetes/conf.d/podinfo-canary.yaml
    {{ kubeconfig() | indent(4) }}
    - require:
      - file: flagger test helm
      - file: flagger test canary
