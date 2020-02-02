include:
    - docker

kube router sysctl iptables:
    sysctl.present:
        - name: net.bridge.bridge-nf-call-iptables
        - value: 1

kube router sysctl rp_filter:
    sysctl.present:
        - name: net.ipv4.conf.all.rp_filter
        - value: 1

kubernetes swap off:
    cmd.run:
        - name: swapoff -a

kubernetes pkgrepo:
    pkgrepo.managed:
        - name: deb https://apt.kubernetes.io/ kubernetes-xenial main
        - key_url: https://packages.cloud.google.com/apt/doc/apt-key.gpg

kubernetes pkg:
    pkg.installed:
        - pkgs:
            - kubelet: {{ salt.pillar.get('k8s:version') }}
            - kubeadm: {{ salt.pillar.get('k8s:version') }}
            - kubectl: {{ salt.pillar.get('k8s:version') }}
