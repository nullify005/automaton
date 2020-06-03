{% from 'macros.sls' import has_istio_operator,has_istio_ingress,istio_enabled,kubeconfig with context %}

include:
  - istio

knative crds:
  cmd.run:
    - name: |
        {%- for r in salt.pillar.get('knative:releases') %}
        kubectl apply -f "{{ r }}"
        {%- endfor %}
    {{ kubeconfig() | indent(4) }}
    - onlyif:
      - {{ has_istio_operator() }}
      - {{ has_istio_ingress() }}
      - {{ istio_enabled() }}
