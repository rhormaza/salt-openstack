{# Global variables used in the state #}
{% set HOST = salt['grains.get']('id').split('.')[0] -%}
{% set FILE_PATH = salt['pillar.get']('formula_rootfs', 'NOT_FOUND') %}

{% set ceilometer_cnf_dir = '/etc/ceilometer' %}
{% set ceilometer_log_dir = '/var/log/ceilometer' %}
{% set ceilometer_user = 'ceilometer' %}
{% set ceilometer_group = 'ceilometer' %}
{% set service_name = 'ceilometer' %}
ceilometer-pkgs:
  pkg.installed:
    - names:
      - openstack-ceilometer-api 
      - openstack-ceilometer-collector
      - openstack-ceilometer-central
      - python-ceilometerclient

{{ ceilometer_cnf_dir }}:
  file.recurse:
    - source: {{ FILE_PATH }}/ceilometer/files/etc
    - template: jinja
    - user: {{ ceilometer_user }}
    - group: {{ ceilometer_group }}
    - require:
      - pkg: ceilometer-pkgs

# TODO(raul): delete me, ceilometer uses mongo
#ceilometer-manage:
#  cmd.run:
#    - name: ceilometer-manage --nodebug db_sync && touch {{ ceilometer_cnf_dir }}/DB_SYNC_DONE
#    - unless: test -f {{ ceilometer_cnf_dir }}/DB_SYNC_DONE
#    - require:
#      - pkg: ceilometer-pkgs
#      - file: {{ ceilometer_cnf_dir }}

ceilometer-services:
  service:
    - running
    - enable: True
    - names:
      - openstack-ceilometer-api
      - openstack-ceilometer-collector
      - openstack-ceilometer-central
    - require:
      - pkg: ceilometer-pkgs
    - watch:
      - cmd: ceilometer-manage
      - file: {{ ceilometer_cnf_dir }}
include:
  - openstack.keystone.keystonerc_admin
