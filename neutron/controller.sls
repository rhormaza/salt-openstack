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
      - openstack-neutron
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

neutron-db-manage:
  cmd:
    - run
    - name: >
        neutron-db-manage
        --config-file {{ neutron_cnf_dir }}/neutron.conf
        --config-file {{ neutron_cnf_dir }}/plugin.ini
        upgrade head 
        && 
        touch {{ neutron_cnf_dir }}/DB_SYNC_DONE
    - unless: test -f {{ neutron_cnf_dir }}/DB_SYNC_DONE
    - require:
      - pkg: neutron-pkgs
      - file: {{ neutron_cnf_dir }}

#TODO(raul): openvswitch stuff should be put in a different *.sls
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

{% for i in ['br-int', 'br-ex'] -%}
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
      - neutron-server
      - neutron-openvswitch-agent
      - neutron-dhcp-agent
      - neutron-l3-agent
      - neutron-metadata-agent
    - require:
      - pkg: neutron-pkgs
    - watch:
      - cmd: neutron-db-manage
      - file: {{ neutron_cnf_dir }}
