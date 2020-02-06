stern:
    cmd.run:
        - name: |
            set -x
            /usr/local/bin/stern version | grep {{ salt.pillar.get('stern:version') }} && exit 0
            set -e
            WORKDIR=$(mktemp)
            rm -rf ${WORKDIR}
            mkdir -p ${WORKDIR}
            cd ${WORKDIR}
            wget -q {{ salt.pillar.get('stern:url') }} -O stern
            openssl sha256 stern
            mv -vf stern /usr/local/bin/
            chmod +x /usr/local/bin/stern
            cd
            rm -rf ${WORKDIR}
