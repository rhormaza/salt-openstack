# TODO(raul): This state, based on ``apache`` formula needs more work, it is 
# functional but needs some extra changes.

{# Global variables used in the state #}
{% set HOST = salt['grains.get']('id').split('.')[0] -%}
{% set FILE_PATH = salt['pillar.get']('formula_rootfs', 'NOT_FOUND') %}

{% set apache_cnf_dir = '/etc/httpd' %}
{% set apache_log_dir = '/var/log/httpd' %}
{% set apache_user = 'apache' %}
{% set apache_group = 'apache' %}
{% set service_name = 'apache' %}

# FIXME(raul): hardcoded? find a better way to do that
{% from "openstack/apache/map.jinja" import apache with context %}

apache-pkgs:
  pkg.installed:
    - pkgs: 
      - {{ apache.server }}

mod_wsgi-pkgs:
  pkg.installed:
    - pkgs: 
      - {{ apache.mod_wsgi }}
    - require:
      - pkg: apache-pkgs


{% if grains.get('os_family') == 'RedHat' %}

{{ apache.confdir }}:
  file.recurse:
    - source: {{ FILE_PATH }}/apache/files/horizon/httpd/conf.d
    - template: jinja
    # TODO(raul): Confirm which user/group should be set here.
    - user: root
    - group: root
    - exclude_pat: E@.*.swp
    - clean: False
    - require:
      - pkg: apache-pkgs
      - pkg: mod_wsgi-pkgs

{{ apache.service }}:
  service:
    - running
    - enable: True
    - require:
      - file: {{ apache.confdir }}

{% endif %}
