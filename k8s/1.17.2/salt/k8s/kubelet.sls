local persistent volume path:
    file.directory:
        - name: {{ salt.pillar.get('k8s:local_storage:path') }}
        - user: root
        - group: root
        - dir_mode: 750

{% for n in range(0, salt.pillar.get('k8s:local_storage:volumes')) %}
local volume file {{ n }}:
    cmd.run:
        - name: |
            set -e
            mkdir -p /mnt/disks
            truncate -s 4G /mnt/disks/vol{{ n }}
            mkfs.ext4 /mnt/disks/vol{{ n }}
        - unless:
            - test -e /mnt/disks/vol{{ n }}

local volume mount {{ n }}:
    mount.mounted:
      - name: {{ salt.pillar.get('k8s:local_storage:path') }}/vol{{ n }}
      - device: /mnt/disks/vol{{ n }}
      - fstype: ext4
      - mkmnt: True
      - opts:
          - noatime
          - nodiratime
      - require:
          - cmd: local volume file {{ n }}
{% endfor %}

kubelet join:
    cmd.run:
        - name: bash {{ salt.pillar.get('k8s:join_script') }}
        - unless:
            - test -e /etc/kubernetes/kubelet.conf
