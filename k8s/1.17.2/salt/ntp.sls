ntp pkg:
  pkg.installed:
    - pkgs:
      - ntp
      - ntpdate

ntp config:
  file.managed:
    - name: /etc/ntp.conf
    - contents: |
        driftfile /var/lib/ntp/ntp.drift
        leapfile /usr/share/zoneinfo/leap-seconds.list
        statistics loopstats peerstats clockstats
        filegen loopstats file loopstats type day enable
        filegen peerstats file peerstats type day enable
        filegen clockstats file clockstats type day enable
        server 0.au.pool.ntp.org
        server 1.au.pool.ntp.org
        server 2.au.pool.ntp.org
        server 3.au.pool.ntp.org
        restrict -4 default kod notrap nomodify nopeer noquery limited
        restrict -6 default kod notrap nomodify nopeer noquery limited
        restrict 127.0.0.1
        restrict ::1
        restrict source notrap nomodify noquery

ntp service:
  service.running:
    - name: ntp
    - running: true
    - enable: true
    - watch:
      - file: ntp config
