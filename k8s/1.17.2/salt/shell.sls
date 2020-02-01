bash_profile file:
  file.managed:
    - name: /home/vagrant/.bash_profile
    - contents: |
        alias highstate='sudo salt-call --local state.highstate'
        alias state='sudo salt-call --local state.sls'
        alias salt='sudo salt-call --local'
    - user: vagrant
    - group: vagrant
    - mode: 0640
