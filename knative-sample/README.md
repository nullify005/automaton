It's possible that there are easier ways to do the k8s setup, as well as develop against
the thing.

Tilt (while it does work) doesn't seem to be that much of a happy camper
and the `minikube tunnel` bit to get the routing to work feels a little messy.

The development experience could definately be improved

https://dev.to/jonatasbaldin/three-solutions-to-run-knative-locally-5615

Is the answer `serverless` again?

https://www.serverless.com/blog/deploy-your-first-knative-service-with-the-serverless-framework/

Also this is how we curl it locally to see it working

```
minikube tunnel
```

```
INGRESSGATEWAY=istio-ingressgateway
INGRESS=$(echo $(minikube ip):$(kubectl get svc $INGRESSGATEWAY --namespace istio-system \
  --output 'jsonpath={.spec.ports[?(@.port==80)].nodePort}'))
curl -H "Host: helloworld.helloworld-python-local-v1.example.com" http://${INGRESS}
Hello Python Sample v1!
```
