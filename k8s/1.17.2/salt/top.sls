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
  'node*':
    - k8s.kubelet
