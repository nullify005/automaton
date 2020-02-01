helm:
    cmd.run:
        - name: |
            set -x
            /usr/local/bin/helm version | grep {{ salt.pillar.get('helm:version') }} && exit 0
            set -e
            WORKDIR=$(mktemp)
            rm -rf ${WORKDIR}
            mkdir -p ${WORKDIR}
            cd ${WORKDIR}
            wget -q {{ salt.pillar.get('helm:url') }} -O helm.tar.gz
            openssl sha256 helm.tar.gz
            tar -zxvf helm.tar.gz
            find . -name helm -exec mv {} /usr/local/bin/ \;
            cd
            rm -rf ${WORKDIR}

helm stable repo:
    cmd.run:
        - name: |
            helm repo add stable https://kubernetes-charts.storage.googleapis.com
        - require:
            - cmd: helm

{#
    kubectl create namespace postgres01
    helm install -n postgres01 --generate-name stable/postgresql --set persistence.enabled=false --set postgresqlPassword=password

    kubectl create namespace postgres02
    helm install -n postgres02 --generate-name stable/postgresql --set persistence.enabled=false --set postgresqlPassword=password

    helm list --all-namespaces
#}

{#
  helm install -n redis redis01 stable/redis \
      --set usePassword=false --set cluster.enabled=false \
      --set master.persistence.enabled=false --set slave.persistence.enabled=false
#}
