{% macro return_unless_nodes() %}
NODES=$(kubectl get node --selector='!node-role.kubernetes.io/master' --no-headers | grep -v NotReady | wc -l | sed "s/ //g")
if [ "${NODES}" -le 1 ]; then exit 0; fi
{% endmacro %}

{% macro has_tiller() -%}
kubectl -n kube-system get pods | grep tiller | grep -q Running
{% endmacro %}

{% macro has_istio_operator() -%}
kubectl -n istio-operator get pods --no-headers | grep -q Running
{% endmacro %}

{% macro has_istio_ingress() -%}
kubectl -n istio-system get pods | grep istio-ingress | grep -q Running
{% endmacro %}

{% macro has_nginx_ingress() -%}
kubectl -n ingress get pods | grep nginx-ingress | grep -q Running
{% endmacro %}

{% macro istio_enabled() -%}
{%- if salt.pillar.get('istio:enabled') %}exit 0{% else %}exit 1{% endif %}
{% endmacro %}

{% macro kubeconfig() %}
- env:
    - KUBECONFIG: /etc/kubernetes/admin.conf
{% endmacro %}
