{% for k,v in pillar.get('hosts').iteritems() %}
host {{ k }}:
  host.present:
    - ip: {{ v }}
    - names:
      - {{ k }}
      - {{ k }}.{{ pillar.get('domain') }}
    - clean: true
{% endfor %}
