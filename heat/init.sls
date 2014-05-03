{# Global variables used in the state #}
{% set HOST = salt['grains.get']('id').split('.')[0] -%}
{% set FILE_PATH = salt['pillar.get']('formula_rootfs', 'NOT_FOUND') %}
{% set OS_VER = salt['pillar.get']('openstack_version', 'icehouse') %}

{% set heat_cnf_dir = '/etc/heat' %}
{% set heat_log_dir = '/var/log/heat' %}
{% set heat_user = 'heat' %}
{% set heat_group = 'heat' %}
{% set service_name = 'heat' %}
heat-pkgs:
  pkg.installed:
    - names:
      - openstack-heat-api 
      - openstack-heat-engine
      - openstack-heat-api-cfn  
      - python-heatclient

{{ heat_cnf_dir }}:
  file.recurse:
    - source: {{ FILE_PATH }}/heat/files/{{ OS_VER }}{{ heat_cnf_dir }}
    - template: jinja
    - user: {{ heat_user }}
    - group: {{ heat_group }}
    - require:
      - pkg: heat-pkgs

heat-manage:
  cmd.run:
    - name: heat-manage --nodebug db_sync && touch {{ heat_cnf_dir }}/DB_SYNC_DONE
    - unless: test -f {{ heat_cnf_dir }}/DB_SYNC_DONE
    - require:
      - pkg: heat-pkgs
      - file: {{ heat_cnf_dir }}

heat-services:
  service:
    - running
    - enable: True
    - names:
      - openstack-heat-api
      - openstack-heat-api-cfn
      - openstack-heat-engine
    - require:
      - pkg: heat-pkgs
    - watch:
      - cmd: heat-manage
      - file: {{ heat_cnf_dir }}
include:
  - openstack.keystone.keystonerc_admin
