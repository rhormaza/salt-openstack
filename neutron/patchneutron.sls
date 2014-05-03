{# Global variables used in the state #}
{% set HOST = salt['grains.get']('id').split('.')[0] -%}
{% set FILE_PATH = salt['pillar.get']('formula_rootfs', 'NOT_FOUND') %}
{% set OS_VER = salt['pillar.get']('openstack_version', 'icehouse') %}

neutron-patch-01:
  file.managed:
    - name: /usr/lib/python2.6/site-packages/neutron/plugins/openvswitch/agent/ovs_neutron_agent.py
    - source: {{ FILE_PATH }}/neutron/files/{{ OS_VER }}/usr/lib/python2.6/site-packages/neutron/plugins/openvswitch/agent/ovs_neutron_agent.py
