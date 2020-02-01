base:
  '*':
    - dns
    - docker
    - ntp
    - shell
    - hostname
    - kubelet
  'control*':
    - control
