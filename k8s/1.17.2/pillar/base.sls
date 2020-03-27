domain: vagrant.local
docker:
  version: 18.06.2~ce~3-0~ubuntu
hosts:
  control01: 192.168.56.10
  node01: 192.168.56.11
  node02: 192.168.56.12
  node03: 192.168.56.13
interface: enp0s8
k8s:
  # kubeadm token generate
  version: 1.15.9-00
  # version: 1.17.2-00
  token: 31wx1y.uo8irygvu16ebchc
  pod_cidr: 10.244.0.0/16
  certificate_key: "64838732f9683ca4ae3e13d3d6504a2d9cfcb51da562d6bdb2f1f816a33dd86c"
  apiserver_address: 192.168.56.10
  network_fabric: kuberouter
  join_script: /srv/salt/tmp/join.sh
  kubectl_config: /srv/salt/tmp/kubectl.conf
  local_storage:
    path: /var/lib/LocalPersistentVolumes
    volumes: 6
helm:
  # this is helm 3
  # sha256: fc75d62bafec2c3addc87b715ce2512820375ab812e6647dc724123b616586d6
  # url: https://get.helm.sh/helm-v3.0.3-linux-amd64.tar.gz
  # version: 3.0.3
  url: https://get.helm.sh/helm-v2.16.1-linux-amd64.tar.gz
  sha256: 7eebaaa2da4734242bbcdced62cc32ba8c7164a18792c8acdf16c77abffce202
  version: v2.16.1
calicoctl:
  sha256: 5b9a7d6bb7be9b6fa49875fe3ab1239a177c6856b1ea8566eb2afbc7064cd495
  url: https://github.com/projectcalico/calicoctl/releases/download/v3.12.0/calicoctl-linux-amd64
  version: 3.12.0
stern:
  sha256: e0b39dc26f3a0c7596b2408e4fb8da533352b76aaffdc18c7ad28c833c9eb7db
  url: https://github.com/wercker/stern/releases/download/1.11.0/stern_linux_amd64
  version: 1.11.0
dns:
  nameserver:
    - 172.16.10.4
    # - 172.16.130.190
istio:
  enabled: false
  namespace: istio-system
  istioctl:
    url: https://github.com/istio/istio/releases/download/1.5.0/istioctl-1.5.0-linux.tar.gz
    sha256: e841c8858f7598351caaf6d7e6a67c4a43218f343629c67cf76db5d000c9df72
    version: 1.5.0
ingress:
  namespace: ingress
  metallb:
    ippool: 192.168.56.100/32
flagger:
  slack:
    webhook: https://hooks.slack.com/services/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
    channel: "#tech-alerts-canary"
