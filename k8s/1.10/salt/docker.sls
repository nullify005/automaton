docker pkgrepo:
  pkgrepo.managed:
    - name: deb [arch=amd64] https://download.docker.com/linux/ubuntu {{ grains.get('oscodename') }} stable
    - key_url: https://download.docker.com/linux/ubuntu/gpg

docker pkg:
  pkg.installed:
    - name: docker-ce
    - version: {{ salt.pillar.get('docker:version') }}
    - hold: true

docker service:
  service.running:
    - name: docker
    - enable: true
    - running: true
