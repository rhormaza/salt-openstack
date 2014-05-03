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
            - openstack-nova-compute
            - openstack-nova-api

{{ nova_cnf_dir }}:
  file.recurse:
    - source: {{ FILE_PATH }}/nova/files/{{ OS_VER }}{{ nova_cnf_dir }}
    - template: jinja
    - user: {{ nova_user }}
    - group: {{ nova_group }}
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
 
nova-support:
  service:
    - running
    - enable: True
    - names:
      - libvirtd
      - messagebus

nova-services:
  service:
    - running
    - enable: True
    - names:
      - openstack-nova-compute
      #- openstack-nova-metadata-api
    - require:
      - pkg: nova-pkgs
    - watch:
      - file: {{ nova_cnf_dir }}

#TODO(raul): 
# This can be used to disabled something.
# If not needed at the end, better delete
nova-services-disabled:
  service:
    - dead 
    - enable: False
    - names:
      - openstack-nova-api
    - require:
      - pkg: nova-pkgs
    - watch:
      - file: {{ nova_cnf_dir }}


include:
  - openstack.keystone.keystonerc_admin
