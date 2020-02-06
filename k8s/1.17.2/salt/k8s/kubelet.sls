kubelet join:
    cmd.run:
        - name: bash {{ salt.pillar.get('k8s:join_script') }}
