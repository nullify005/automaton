domain: vagrant.local
docker:
  version: 17.03.3~ce-0~ubuntu-xenial
hosts:
  node01: 192.168.56.10
  node02: 192.168.56.11
  node03: 192.168.56.12
interface: enp0s8
k8s:
  version: 1.10.13
  cluster: vagrant
  etc: /etc/kubernetes
  encryption:
    key: YhN9lxGf1i7ROfGu1oQw6b03FteqJcc+RNCUIgz4K0g=
  binaries:
    kubectl:
      url: https://dl.k8s.io/v1.10.13/kubernetes-server-linux-amd64.tar.gz
      sha: 6ece286535569786579233809fee92307a103c30947e1350fa009fab29b9f45e82c065f6d3576025ea1499c9a58ee97d2386f540aee3e789aa0b2aaf2b388aca
cfssl:
  binaries:
    cfssl:
      url: https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
      sha: 344d58d43aa3948c78eb7e7dafe493c3409f98c73f27cae041c24a7bd14aff07c702d8ab6cdfb15bd6cc55c18b2552f86c5f79a6778f0c277b5e9798d3a38e37
    cfssljson:
      url: https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
      sha: b80f19e61e16244422ad3d877e5a7df5c46b34181d264c9c529db8a8fc2999c6a6f7c1fb2dec63e08d311d6657c8fe05af3186b7ff369a866a47d140d393b49b
