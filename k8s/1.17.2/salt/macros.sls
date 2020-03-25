{% macro return_unless_nodes() %}
NODES=$(kubectl get node --selector='!node-role.kubernetes.io/master' --no-headers | grep -v NotReady | wc -l | sed "s/ //g")
if [ "${NODES}" -le 1 ]; then exit 0; fi
{% endmacro %}

{% macro has_tiller() -%}
kubectl -n kube-system get pods | grep tiller | grep -q Running
{% endmacro %}
