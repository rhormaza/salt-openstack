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

keystone-manage:
  cmd.run:
    - name: keystone-manage --nodebug db_sync && touch {{ keystone_cnf_dir }}/DB_SYNC_DONE
    - unless: test -f {{ keystone_cnf_dir }}/DB_SYNC_DONE
    - require:
      - pkg: keystone-pkgs

# New from Havana admin guide
keystone-pki-init:
  cmd:
    - run
    - name: keystone-manage --nodebug pki_setup --keystone-user keystone --keystone-group keystone
    - unless: test -d {{ keystone_cnf_dir }}/ssl


keystone-services:
  service:
    - running
    - enable: True
    - names:
      - openstack-keystone
    - require:
      - pkg: keystone-pkgs
    - watch:
      - cmd: keystone-manage
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

keystone_tenants:
  keystone.tenant_present:
    - names:
      {% for tenant in salt['pillar.get']('keystone:tenants') -%}
      - {{ tenant }}
      {% endfor %}
    - require:
      - service: keystone-services

keystone_roles:
  keystone.role_present:
    - names:
      {% for role in salt['pillar.get']('keystone:roles') -%}
      - {{ role }}
      {% endfor %}
    - require:
      - service: keystone-services

# TODO(raul): this fails in the first run...check why? and fix it!
{% for user, user_info in salt['pillar.get']('keystone:users').iteritems() -%}
{{ user }}:
  keystone.user_present:
    - password: {{ user_info.get('password') }} 
    - email: {{ user_info.get('email') }} 
    - tenant: {% for tenant in user_info.get('tenant') -%}
                {{ tenant }}
              {%- endfor %}
    - roles:
      {% for tenant, roles in user_info.get('roles').iteritems() -%}
      - {{ tenant }}:
        {% for role in roles -%}
        - {{ role }} 
        {% endfor %} 
      {% endfor %}
    - require:
      - keystone: keystone_tenants
      - keystone: keystone_roles
{% endfor %}

{% for service in salt['pillar.get']('keystone:services') -%}
{{ service.get('name') }}_service:
  keystone.service_present:
    - name: {{ service.get('name') }}
    - service_type: {{ service.get('type') }}
    - description: {{ service.get('description') }} 
    - endpoints:
      {% for endpt in service.get('endpoints') -%}
      - region: {{ endpt.get('region') }}
        adminurl: {{ endpt.get('adminurl') }}
        internalurl: {{ endpt.get('internalurl') }}
        publicurl: {{ endpt.get('publicurl') }}
      {% endfor %}
{% endfor %}

include:
  - openstack.keystone.keystonerc_admin
