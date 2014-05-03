{# Global variables used in the state #}
{% set HOST = salt['grains.get']('id').split('.')[0] -%}
{% set FILE_PATH = salt['pillar.get']('formula_rootfs', 'NOT_FOUND') %}

mongodb-pkgs:
  pkg.installed:
    - names: 
      - mongodb
      - mongodb-server

/etc/mongodb.conf:
  file.managed:
    - source: {{ FILE_PATH }}/mongodb/files/mongodb.conf
    - template: jinja
    - user: root
    - group: root
    - require:
      - pkg: mongodb-pkgs

mongodb-service:
  service:
    - running
    - enable: True
    - names:
      - mongod
    - watch:
      - pkg: mongodb-pkgs
      - file: /etc/mongodb.conf
