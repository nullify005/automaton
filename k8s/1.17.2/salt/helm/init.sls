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
        - name: helm repo add stable https://kubernetes-charts.storage.googleapis.com
        - require:
            - cmd: helm
        - onlyif:
            - /usr/local/bin/helm version | grep -q v3.

helm tiller rbac file:
    file.managed:
        - name: /etc/kubernetes/conf.d/tiller-rbac.yaml
        - source: salt://helm/resources/service-account.yaml
        - template: jinja
        - makedirs: true

helm tiller rbac apply:
    cmd.run:
        - name: |
            ACTION=apply
            /usr/local/bin/helm version | grep -q v3. && ACTION=delete
            kubectl ${ACTION} -f /etc/kubernetes/conf.d/tiller-rbac.yaml
        - env:
            - KUBECONFIG: /etc/kubernetes/admin.conf
        - require:
            - file: helm tiller rbac file

helm init:
    cmd.run:
        - name: |
            set -e
            helm init --service-account=tiller
            # helm plugin install https://github.com/mstrzele/helm-edit
            helm repo add elastic https://helm.elastic.co
            helm repo add bitnami https://charts.bitnami.com/bitnami
            helm repo add kubecost https://kubecost.github.io/cost-analyzer/
        - env:
            - KUBECONFIG: /etc/kubernetes/admin.conf
        - require:
            - cmd: helm tiller rbac apply
        - onlyif:
            - /usr/local/bin/helm version | grep -q v2.

{#
    kubectl create namespace postgres01
    helm install -n postgres01 --generate-name stable/postgresql --set persistence.enabled=false --set postgresqlPassword=password

    kubectl create namespace postgres02
    helm install -n postgres02 --generate-name stable/postgresql --set persistence.enabled=false --set postgresqlPassword=password

    helm list --all-namespaces
    helm install -n redis redis01 stable/redis \
        --set usePassword=false --set cluster.enabled=false \
        --set master.persistence.enabled=false --set slave.persistence.enabled=false

    # elastic needs helm 2

    esJavaOpts: -Xmx256m -Xms256m
    resources:
        requests:
            memory: 512m
        limits:
            memory: 512m
    persistence:
        enabled: false
    helm install --namespace elasticsearch --name elasticsearch elastic/elasticsearch \
        --set esJavaOpts="-Xmx256m -Xms256m" --set persistence.enabled=false \
        --set resources='{ requests.memory: 512m,  limits.memory}'

    helm install --namespace elasticsearch --name elasticsearch elastic/elasticsearch -f /srv/salt/helm/resources/elasticsearch-values.yaml

requests.cpu: 1000m
requests.memory: 2Gi
limits.cpu: 1000m
limits.memory: 2Gi
#}
