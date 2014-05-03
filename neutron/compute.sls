{# Global variables used in the state #}
{% set HOST = salt['grains.get']('id').split('.')[0] -%}
{% set FILE_PATH = salt['pillar.get']('formula_rootfs', 'NOT_FOUND') %}
{% set OS_VER = salt['pillar.get']('openstack_version', 'icehouse') %}

{% set neutron_cnf_dir = '/etc/neutron' %}
{% set neutron_log_dir = '/var/log/neutron' %}
{% set neutron_user = 'neutron' %}
{% set neutron_group = 'neutron' %}
{% set service_name = 'neutron' %}

neutron-pkgs:
  pkg.installed:
    - pkgs:
      - openstack-neutron-openvswitch
      - openstack-neutron-ml2
      - python-neutron
      - python-neutronclient
      - openvswitch

{{ neutron_cnf_dir }}:
  file.recurse:
    - source: {{ FILE_PATH }}/neutron/files/{{ OS_VER }}{{ neutron_cnf_dir }}
    - template: jinja
    - user: {{ neutron_user }}
    - group: {{ neutron_group }}
    - require:
      - pkg: neutron-pkgs


#TODO(raul): openvswitch stuff should be put in a different state
ovs-services:
  service:
    - running
    - enable: True
    - names:
      - openvswitch
    - require:
      - pkg: neutron-pkgs
    - watch:
      - file: {{ neutron_cnf_dir }}

{% for i in ['br-int'] -%}
{{ i }}:
  cmd.run:
    - name: ovs-vsctl add-br {{ i }}; ifconfig {{ i }} up
    - unless: ovs-vsctl br-exists {{ i }} 
    - require:
      - service: ovs-services
{% endfor %}

neutron-services:
  service:
    - running
    - enable: True
    - names:
      - neutron-openvswitch-agent
    - require:
      - pkg: neutron-pkgs
    - watch:
      - file: {{ neutron_cnf_dir }}
