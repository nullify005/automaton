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

{#
    kubeadm join --apiserver-advertise-address string 192.168.56.10 --token eyJhbGciOiJSUzI1NiIsImtpZCI6IkJpRUxuRG5tUzNyTFNobDRVeFNoeWdxdUh4MXAtaHpGcUJxY19ZSko2cG8ifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyLXRva2VuLWRyejc4Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiJhZGJmZDEzYy0wYzQ2LTRjMTYtOTVlYy01ZmUwOTJjYjhlOGYiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZS1zeXN0ZW06YWRtaW4tdXNlciJ9.JA-Ma9Ss6fO8Wfm5Rg6bTqCF_VNFKZIA059-QWbkd8j-XunKuYrEMNHo9gKUo91U-QCMv6wq5sz7drxG_jXzZjVbqrxjk65II_wNFtzwd6Dr1zuPe6qMtjcuCHH_-uiRDVzrGK9_DRze4jaMNaEuHoNJbKA2DkwwE1h12OWp5oQ_nwzmMtFADB_BdX6OSok8KvBOAZv-stcOIk2fV4nEwEyaTnG4icl4V8_UJtwXQRec3N63257xIhVZ48mBkdszSf5QWWwnKhXAa8Z5vfQg8V8iAHqgfokYUu7t9xfSf8SjAoUlH-uAPonIFnZeEoLTk74fuYbdhvjCC9SXYURcFw
#}
