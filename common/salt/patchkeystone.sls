{# Global variables used in the state #}
{% set HOST = salt['grains.get']('id').split('.')[0] -%}
{% set FILE_PATH = salt['pillar.get']('formula_rootfs', 'NOT_FOUND') %}

salt-keystone-state-file:
  file.managed:
    - name: /usr/lib/python2.6/site-packages/salt/states/keystone.py
    - template: jinja
    - source: {{ FILE_PATH }}/common/salt/files/state_keystone.py

salt-keystone-module-file:
  file.managed:
    - name: /usr/lib/python2.6/site-packages/salt/modules/keystone.py
    - template: jinja
    - source: {{ FILE_PATH }}/common/salt/files/module_keystone.py
