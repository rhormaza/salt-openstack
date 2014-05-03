{# Global variables used in the state #}
{% set HOST = salt['grains.get']('id').split('.')[0] -%}
{% set FILE_PATH = salt['pillar.get']('formula_rootfs', 'NOT_FOUND') %}

/root/keystonerc_admin:
  file.managed:
    - source: {{ FILE_PATH }}/keystone/files/keystonerc_admin
    - template: jinja
    - user: root
    - group: root
