{# Global variables used in the state #}
{% set HOST = salt['grains.get']('id').split('.')[0] -%}
{% set FILE_PATH = salt['pillar.get']('formula_rootfs', 'NOT_FOUND') %}

/etc/yum.conf:
  file.managed:
    - source: {{ FILE_PATH }}/common/yum/files/yum.conf
    - template: jinja
/etc/yum.repos.d:
  file.recurse:
    - source: {{ FILE_PATH }}/common/yum/files/yum.repos.d
    - template: jinja
    - clean: True

ensure-osvm01-host-file:
  cmd.run:
    - name: echo "10.0.0.1 osvm01" >> /etc/hosts
    - unless: grep "osvm01" /etc/hosts

