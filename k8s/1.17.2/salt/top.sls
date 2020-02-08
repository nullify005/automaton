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
    - k8s.control
    - helm
    - stern
  'node*':
    - k8s.kubelet
