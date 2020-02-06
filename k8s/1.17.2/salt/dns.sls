resolvconf removed:
    pkg.purged:
        - name: resolvconf

resolvconf fix:
    cmd.run:
        - name: |
            if [ -L /etc/resolv.conf ]; then rm -f /etc/resolv.conf; fi

resolv conf:
    file.managed:
        - name: /etc/resolv.conf
        - contents: |
            {%- for n in salt.pillar.get('dns:nameserver') %}
            nameserver {{ n }}
            {%- endfor %}
