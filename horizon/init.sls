{# Global variables used in the state #}
{% set HOST = salt['grains.get']('id').split('.')[0] -%}
{% set FILE_PATH = salt['pillar.get']('formula_rootfs', 'NOT_FOUND') %}
{% set OS_VER = salt['pillar.get']('openstack_version', 'icehouse') %}

# TODO(raul): does this belong to here?
include:
  - openstack.apache
  - openstack.memcached

horizon:
  pkg.installed:
    - name: {{ pkg.name }}
    - watch_in:
      - service: apache

/etc/openstack-dashboard/local_settings:
  file.managed:
    - source: {{ FILE_PATH }}/horizon/files/{{ OS_VER }}/etc/openstack-dashboard/local_settings
    - template: jinja
    - user: root
    # TODO(raul): validate that the group is apache! also..template it?
    - group: apache 
    - require:
      - pkg: horizon
    - watch_in:
      - service: apache

/etc/httpd/conf.d/openstack-dashboard.conf:
  file:
    - managed
    - name: {{ pkg.wsgi_conf }}
    - source: {{ FILE_PATH }}/horizon/files/{{ OS_VER }}/etc/httpd/conf.d/openstack-dashboard.conf
    - template: jinja
    - require:
      - pkg: horizon
    - watch_in:
      - service: apache
