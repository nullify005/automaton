include:
    - k8s
    - helm
    - calicoctl
    - stern

kubernetes control init:
    cmd.run:
        - name: |
            set -x
            set +e
            kubectl get ns && exit 0
            set -e
            kubeadm config images pull
            kubeadm init --token {{ salt.pillar.get('k8s:token') }} \
                --pod-network-cidr={{ salt.pillar.get('k8s:pod_cidr') }} \
                --certificate-key {{ salt.pillar.get('k8s:certificate_key') }} \
                --apiserver-advertise-address {{ salt.pillar.get('k8s:apiserver_address') }}
        - env:
              - KUBECONFIG: /etc/kubernetes/admin.conf

kubernetes flannel config:
    file.managed:
        - name: /etc/kubernetes/flannel.yaml
        - source: salt://resources/kube-flannel.yaml
        - template: jinja
        - onlyif:
            - test "{{ salt.pillar.get('k8s:network_fabric') }}" = "flannel"

kubernetes flannel apply:
    cmd.run:
        - name: |
            kubectl apply -f /etc/kubernetes/flannel.yaml
        - onlyif:
            - test "{{ salt.pillar.get('k8s:network_fabric') }}" = "flannel"
        - require:
            - file: kubernetes flannel config
        - env:
            - KUBECONFIG: /etc/kubernetes/admin.conf

kubernetes calico config:
    file.managed:
        - name: /etc/kubernetes/calico.yaml
        - source: salt://resources/calico.yaml
        - template: jinja
        - onlyif:
            - test "{{ salt.pillar.get('k8s:network_fabric') }}" = "calico"

kubernetes calico policies:
    file.managed:
        - name: /etc/kubernetes/network-policies.yaml
        - source: salt://resources/network-policies.yaml
        - template: jinja
        - onlyif:
            - test "{{ salt.pillar.get('k8s:network_fabric') }}" = "calico"

kubernetes calico apply:
    cmd.run:
        - name: |
            kubectl apply -f /etc/kubernetes/calico.yaml
        - onlyif:
            - test "{{ salt.pillar.get('k8s:network_fabric') }}" = "calico"
        - require:
            - file: kubernetes calico config
        - env:
            - KUBECONFIG: /etc/kubernetes/admin.conf

kubernetes network policy apply:
    cmd.run:
        - name: |
            calicoctl apply -f /etc/kubernetes/network-policies.yaml
        - onlyif:
            - test "{{ salt.pillar.get('k8s:network_fabric') }}" = "calico"
        - require:
            - cmd: calicoctl
        - env:
            - KUBECONFIG: /etc/kubernetes/admin.conf
            - DATASTORE_TYPE: kubernetes

#kubernetes run everywhere:
#    cmd.run:
#        - name: |
#            kubectl taint nodes --all node-role.kubernetes.io/master-
#        - env:
#            - KUBECONFIG: /etc/kubernetes/admin.conf

kubernetes service accounts config:
    file.managed:
        - name: /etc/kubernetes/service-accounts.yaml
        - source: salt://resources/service-accounts.yaml
        - template: jinja

kubernetes service accounts apply:
    cmd.run:
        - name: |
            kubectl apply -f /etc/kubernetes/service-accounts.yaml
        - env:
            - KUBECONFIG: /etc/kubernetes/admin.conf
        - require:
            - file: kubernetes service accounts config

kubernetes join token:
    cmd.run:
        - name: |
            SCRIPT="{{ salt.pillar.get('k8s:join_script') }}"
            mkdir -p `dirname ${SCRIPT}`
            kubeadm token create --print-join-command | tee {{ salt.pillar.get('k8s:join_script') }}
            chmod +x ${SCRIPT}
        - env:
            - KUBECONFIG: /etc/kubernetes/admin.conf

kubernetes KUBECONFIG bash:
    file.append:
        - name: /root/.bashrc
        - text: |
            export KUBECONFIG=/etc/kubernetes/admin.conf
            source <(kubectl completion bash)
            {%- if salt.pillar.get('k8s:network_fabric') == 'calico' %}
            export DATASTORE_TYPE=kubernetes
            {%- endif %}
