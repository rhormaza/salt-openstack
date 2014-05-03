{# Global variables used in the state #}
{% set HOST = salt['grains.get']('id').split('.')[0] -%}
{% set FILE_PATH = salt['pillar.get']('formula_rootfs', 'NOT_FOUND') %}
{% set OS_VER = salt['pillar.get']('openstack_version', 'icehouse') %}

{% set glance_cnf_dir = '/etc/glance' %}
{% set glance_log_dir = '/var/log/glance' %}
{% set glance_user = 'glance' %}
{% set glance_group = 'glance' %}
{% set service_name = 'glance' %}

glance-pkgs:
  pkg.installed:
    - names:
      - openstack-glance
      - python-glanceclient
      - sheepdog

{{ glance_cnf_dir }}:
  file.recurse:
    - source: {{ FILE_PATH }}/glance/files/{{ OS_VER }}{{ glance_cnf_dir }}
    - template: jinja
    - user: {{ glance_user }}
    - group: {{ glance_group }}
    - require:
      - pkg: glance-pkgs

glance-manage:
  cmd.run:
    - name: glance-manage --debug db_sync && touch {{ glance_cnf_dir }}/DB_SYNC_DONE
    - unless: test -f {{ glance_cnf_dir }}/DB_SYNC_DONE
    - require:
      - pkg: glance-pkgs
      - file: {{ glance_cnf_dir }}

glance-cnf-dir-permissions:
  file.directory:
    - name: {{ glance_cnf_dir }}
    - recurse:
      - user
      - group
    - user: {{ glance_user }}
    - group: {{ glance_group }}
    - require:
      - pkg: glance-pkgs

glance-log-dir-permissions:
  file.directory:
    - name: {{ glance_log_dir }}
    - recurse:
      - user
      - group
    - user: {{ glance_user }}
    - group: {{ glance_group }}
    - require:
      - pkg: glance-pkgs


glance-services:
  service:
    - running
    - enable: True
    - names:
      - openstack-glance-api
      - openstack-glance-registry
    - require:
      - pkg: glance-pkgs
      - cmd: glance-manage
    - watch:
      - file: {{ glance_cnf_dir }}


include:
  - openstack.keystone.keystonerc_admin
