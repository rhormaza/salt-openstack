{# Global variables used in the state #}
{% set HOST = salt['grains.get']('id').split('.')[0] -%}
{% set FILE_PATH = salt['pillar.get']('formula_rootfs', 'NOT_FOUND') %}

include:
  - openstack.common.salt.depends

salt-pkgs:
  pkg.installed:
    - names:
      - salt-minion

salt-minion-id:
  cmd.run:
    - name: hostname -s > /etc/salt/minion_id
    - unless: grep `hostname -s` /etc/salt/minion_id
    - require:
      - pkg: salt-pkgs

salt-minion-cnf-file:
  file.managed:
    - name: /etc/salt/minion
    - template: jinja
    - source: {{ FILE_PATH }}/common/salt/files/minion.jinja

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

salt-services:
  service:
    - running
    - enable: True
    - names:
      - salt-minion
    - require:
      - pkg: salt-pkgs
      - cmd: salt-minion-id
    - watch:
      - file: salt-minion-cnf-file
