{# Global variables used in the state #}
{% set HOST = salt['grains.get']('id').split('.')[0] -%}
{% set FILE_PATH = salt['pillar.get']('formula_rootfs', 'NOT_FOUND') %}

openssh:
  pkg:
    - installed
    {% if grains['os_family'] == 'Debian' %}
    - name: openssh-server
    {% endif %}
  service.running:
    - enable: True
    - name: sshd
    - require:
      - pkg: openssh
      - file: sshd_banner
    - watch:
      - file: sshd_config

sshd_config:
  file.managed:
    - name: /etc/ssh/sshd_config
    - source: {{ FILE_PATH }}/common/openssh/files/sshd_config

sshd_banner:
  file.managed:
    - name: /etc/ssh/banner
    - source: {{ FILE_PATH }}/common/openssh/files/banner
    - template: jinja

## Copy ssh public keys
#ssh_key_osbm01:
#  ssh_auth:
#    - present
#    - user: root
#    - source: {{ FILE_PATH }}/common/openssh/files/osbm01_id_rsa.pub
#
#ssh_key_osvm01:
#  ssh_auth:
#    - present
#    - user: root
#    - source: {{ FILE_PATH }}/common/openssh/files/osvm01_id_rsa.pub
  
