docker repo:
    pkgrepo.managed:
        - name: deb https://download.docker.com/linux/ubuntu xenial edge
        - key_url: https://download.docker.com/linux/ubuntu/gpg
        #- keyid: 0EBFCD88

docker pkg:
    pkg.installed:
        - name: docker-ce
        - version: {{ salt.pillar.get('docker:version')}}
        - require:
            - pkgrepo: docker repo

docker config:
    file.managed:
        - name: /etc/docker/daemon.json
        - source: salt://resources/daemon.json
        - user: root
        - group: root
        - mode: 0640

docker daemon service dir:
    file.directory:
        - name: /etc/systemd/system/docker.service.d
        - user: root
        - group: root
        - mode: 0755

docker systemd reload:
    cmd.run:
        - name: |
            systemctl stop docker
            systemctl daemon-reload
            systemctl start docker
        - onchanges:
            - file: docker daemon service dir

docker service:
    service.running:
        - name: docker
        - enable: true
        - reload: false
        - require:
            - pkg: docker pkg
        - onchanges:
            - file: docker config
