local persistent volume path:
    file.directory:
        - name: {{ salt.pillar.get('k8s:local_storage_path') }}
        - user: root
        - group: root
        - dir_mode: 750

kubelet join:
    cmd.run:
        - name: bash {{ salt.pillar.get('k8s:join_script') }}
