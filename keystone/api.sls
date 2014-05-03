{# Global variables used in the state #}
{% set HOST = salt['grains.get']('id').split('.')[0] -%}
{% set FILE_PATH = salt['pillar.get']('formula_rootfs', 'NOT_FOUND') %}

{% set keystone_cnf_dir = salt['pillar.get']('keystone:dir:cnf', '/etc/keystone') %}
{% set keystone_log_dir = salt['pillar.get']('keystone:dir:log', '/etc/keystone') %}
{% set keystone_user = salt['pillar.get']('keystone:os:user', '') %}
{% set keystone_group = salt['pillar.get']('keystone:os:group', '') %}

keystone-pkgs:
  pkg.installed:
    - names:
      - openstack-keystone
      - python-keystoneclient

{{ keystone_cnf_dir }}:
  file.recurse:
    - source: {{ FILE_PATH }}/keystone/files/etc
    - template: jinja
    - user: {{ keystone_user }}
    - group: {{ keystone_group }}
    - require:
      - pkg: keystone-pkgs

keystone-services:
  service:
    - running
    - enable: True
    - names:
      - openstack-keystone
    - require:
      - pkg: keystone-pkgs
    - watch:
      - file: {{ keystone_cnf_dir }}


# TODO(raul): This might not be needed, check!
keystone-cnf-dir-permissions:
  file.directory:
    - name: {{ keystone_cnf_dir }}
    - recurse:
      - user
      - group
    - user: {{ keystone_user }}
    - group: {{ keystone_group }}
    - require:
      - pkg: keystone-pkgs

keystone-log-dir-permissions:
  file.directory:
    - name: {{ keystone_log_dir }}
    - recurse:
      - user
      - group
    - user: {{ keystone_user }}
    - group: {{ keystone_group }}
    - require:
      - pkg: keystone-pkgs

include:
  - openstack.keystone.keystonerc_admin
