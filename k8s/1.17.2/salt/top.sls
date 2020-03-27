base:
  '*':
    - jq
    - dns
    - docker
    - ntp
    - shell
    - hostname
    - k8s
  'control*':
    - calicoctl
    - stern
    - k8s.control
    - helm
    - istio
    - ingress
    - flagger
    #- prometheus
  'node*':
    - k8s.kubelet
