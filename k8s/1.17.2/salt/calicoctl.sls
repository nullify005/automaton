calicoctl:
    cmd.run:
        - name: |
            set -x
            /usr/local/bin/calicoctl version | grep {{ salt.pillar.get('calicoctl:version') }} && exit 0
            set -e
            WORKDIR=$(mktemp)
            rm -rf ${WORKDIR}
            mkdir -p ${WORKDIR}
            cd ${WORKDIR}
            wget -q {{ salt.pillar.get('calicoctl:url') }} -O calicoctl
            openssl sha256 calicoctl
            mv -vf calicoctl /usr/local/bin/
            chmod +x /usr/local/bin/calicoctl
            cd
            rm -rf ${WORKDIR}
        - onlyif:
            - test {{ salt.pillar.get('k8s:network_fabric') }} = "calico"
