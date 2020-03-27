{% from 'macros.sls' import kubeconfig with context %}

flagger test namespace:
  cmd.run:
    - name: |
        kubectl create namespace test
        kubectl apply -k github.com/weaveworks/flagger//kustomize/podinfo
        helm upgrade -i flagger-loadtester flagger/loadtester \
          --namespace=test
        kubectl apply -f - <<EOF
        apiVersion: extensions/v1beta1
        kind: Ingress
        metadata:
          name: podinfo
          namespace: test
          labels:
            app: podinfo
          annotations:
            kubernetes.io/ingress.class: "nginx"
        spec:
          rules:
            - host: podinfo.vagrant.local
              http:
                paths:
                  - backend:
                      serviceName: podinfo
                      servicePort: 80
        EOF
        kubectl apply -f - <<EOF
        apiVersion: flagger.app/v1beta1
        kind: Canary
        metadata:
          name: podinfo
          namespace: test
        spec:
          provider: nginx
          # deployment reference
          targetRef:
            apiVersion: apps/v1
            kind: Deployment
            name: podinfo
          # ingress reference
          ingressRef:
            apiVersion: extensions/v1beta1
            kind: Ingress
            name: podinfo
          # HPA reference (optional)
          autoscalerRef:
            apiVersion: autoscaling/v2beta1
            kind: HorizontalPodAutoscaler
            name: podinfo
          # the maximum time in seconds for the canary deployment
          # to make progress before it is rollback (default 600s)
          progressDeadlineSeconds: 60
          service:
            # ClusterIP port number
            port: 80
            # container port number or name
            targetPort: 9898
          analysis:
            # schedule interval (default 60s)
            interval: 10s
            # max number of failed metric checks before rollback
            threshold: 10
            # max traffic percentage routed to canary
            # percentage (0-100)
            maxWeight: 50
            # canary increment step
            # percentage (0-100)
            stepWeight: 5
            # NGINX Prometheus checks
            metrics:
            - name: request-success-rate
              # minimum req success rate (non 5xx responses)
              # percentage (0-100)
              thresholdRange:
                min: 99
              interval: 1m
            # testing (optional)
            webhooks:
              - name: acceptance-test
                type: pre-rollout
                url: http://flagger-loadtester.test/
                timeout: 30s
                metadata:
                  type: bash
                  cmd: "curl -sd 'test' http://podinfo-canary/token | grep token"
              - name: load-test
                url: http://flagger-loadtester.test/
                timeout: 5s
                metadata:
                  cmd: "hey -z 1m -q 10 -c 2 http://podinfo.vagrant.local/"
        EOF
    {{ kubeconfig() | indent(4) }}
