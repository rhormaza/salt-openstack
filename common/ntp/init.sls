{# Global variables used in the state #}
{% set HOST = salt['grains.get']('id').split('.')[0] -%}
{% set FILE_PATH = salt['pillar.get']('formula_rootfs', 'NOT_FOUND') %}

ntp:
  pkg.installed

/etc/ntp.conf:
  file.managed:
    - source: {{ FILE_PATH }}/common/ntp/files/ntp-client.conf
    - require:
      - pkg: ntp

ntpd:
  service.running:
    - enable: True
    - require:
      - pkg: ntp
    - watch:
      - file: /etc/ntp.conf
