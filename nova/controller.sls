{# Global variables used in the state #}
{% set HOST = salt['grains.get']('id').split('.')[0] -%}
{% set FILE_PATH = salt['pillar.get']('formula_rootfs', 'NOT_FOUND') %}
{% set OS_VER = salt['pillar.get']('openstack_version', 'icehouse') %}

{% set nova_cnf_dir = '/etc/nova' %}
{% set nova_log_dir = '/var/log/nova' %}
{% set nova_user = 'nova' %}
{% set nova_group = 'nova' %}
{% set service_name = 'nova' %}

nova-pkgs:
    pkg.installed:
        - names:
            - openstack-nova

{{ nova_cnf_dir }}:
  file.recurse:
    # TODO(raul): Find out if there is a better way to reference sources
    # For instance:
    # - source: salt://.files/{{ OS_VER }}...
    # - source: file/{{ OS_VER }}...
    - source: {{ FILE_PATH }}/nova/files/{{ OS_VER }}{{ nova_cnf_dir }}
    - template: jinja
    - user: {{ nova_user }}
    - group: {{ nova_group }}
    # TODO(raul): add this in all file.recurse entries
    - exclude_pat: E@.*.swp
    - clean: False
    - require:
      - pkg: nova-pkgs
    - context:
{# Get horizon external interface from salt mine #}
{% set minion_id = salt['pillar.get']('nova:novncproxy_base_hostname') %}
{% for id, data in salt['mine.get'](minion_id, 'network.interfaces').items() %}
        horizon_ext: {{ data['eth0']['inet'][0]['address'] if data['eth0'].has_key('inet') else 'NOT_FOUND' }}
{% endfor %}

nova-manage:
  cmd.run:
    - name: nova-manage --nodebug db sync && touch {{ nova_cnf_dir }}/DB_SYNC_DONE
    - unless: test -f {{ nova_cnf_dir }}/DB_SYNC_DONE
    - require:
      - pkg: nova-pkgs
      - file: {{ nova_cnf_dir }}

nova-services:
  service.running:
    - enable: True
    - names:
      - openstack-nova-api
      - openstack-nova-cert
      - openstack-nova-conductor
      - openstack-nova-consoleauth
      - openstack-nova-novncproxy
      - openstack-nova-scheduler
    - require:
      - pkg: nova-pkgs
    - watch:
      - cmd: nova-manage
      - file: {{ nova_cnf_dir }}

nova-services-disabled:
  service.dead: 
    - enable: False
    - names:
      - openstack-nova-objectstore
      - openstack-nova-network
      #- openstack-nova-volume
    - require:
      - pkg: nova-pkgs
    - watch:
      - cmd: nova-manage
      - file: {{ nova_cnf_dir }}

include:
  - openstack.keystone.keystonerc_admin
