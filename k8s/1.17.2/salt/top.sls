base:
  '*':
    - dns
    - docker
    - ntp
    - shell
    - hostname
    - k8s
  'control*':
    - k8s.control
    - helm
    - calicoctl
    - stern
  'node*':
    - k8s.kubelet
