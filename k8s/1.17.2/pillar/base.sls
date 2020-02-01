domain: vagrant.local
docker:
    version: 18.06.2~ce~3-0~ubuntu
hosts:
    control01: 192.168.56.10
    node01: 192.168.56.11
    node02: 192.168.56.12
interface: enp0s8
k8s:
    # kubeadm token generate
    version: 1.17.2-00
    token: 31wx1y.uo8irygvu16ebchc
    pod_cidr: 10.244.0.0/16
    certificate_key: "64838732f9683ca4ae3e13d3d6504a2d9cfcb51da562d6bdb2f1f816a33dd86c"
    apiserver_address: 192.168.56.10
    network_fabric: calico
helm:
    sha256: fc75d62bafec2c3addc87b715ce2512820375ab812e6647dc724123b616586d6
    url: https://get.helm.sh/helm-v3.0.3-linux-amd64.tar.gz
    version: 3.0.3
dns:
    nameserver: 172.16.10.4
