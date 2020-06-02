{% from 'macros.sls' import kubeconfig with context %}

canary config:
  file.managed:
    - name: /etc/kubernetes/conf.d/podinfo-canary.yaml
    - source: salt://flagger/resources/kubernetes/canary.yaml
    - template: jinja

flagger setup:
  cmd.run:
    - runas: root
    - name: |
        # helm delete ingress-flagger --purge
        helm upgrade -i kubernetes-flagger flagger/flagger \
          --namespace test \
          --set meshProvider=kubernetes \
          --set slack.url={{ salt.pillar.get('flagger:slack:webhook') }} \
          --set slack.channel={{ salt.pillar.get('flagger:slack:channel') }} \
          --set slack.user=flagger \
          --set metricsServer=http://prometheus-operated.monitoring:9090c
        kubectl create ns test
        kubectl apply -k github.com/weaveworks/flagger//kustomize/podinfo
        kubectl apply -k github.com/weaveworks/flagger//kustomize/tester
        kubectl apply -f /etc/kubernetes/conf.d/podinfo-canary.yaml
    {{ kubeconfig () | indent(4) }}
