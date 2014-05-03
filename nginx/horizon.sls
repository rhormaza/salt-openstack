{# Global variables used in the state #}
{% set HOST = salt['grains.get']('id').split('.')[0] -%}
{% set FILE_PATH = salt['pillar.get']('formula_rootfs', 'NOT_FOUND') %}

{% set nginx_cnf_dir = '/etc/nginx' %}
{% set nginx_log_dir = '/var/log/nginx' %}
{% set nginx_user = 'nginx' %}
{% set nginx_group = 'nginx' %}
{% set service_name = 'nginx' %}

nginx-pkgs:
  pkg.installed:
    - pkgs:
      - nginx

# TODO(raul): move this into their *.sls ...service.sls perhaps!
/etc/sysconfig/nginx:
  file.managed:
    - source: {{ FILE_PATH }}/nginx/files/etc/sysconfig/nginx
    - template: jinja
    - require:
      - pkg: nginx-pkgs

{{ nginx_cnf_dir }}:
  file.recurse:
    - source: {{ FILE_PATH }}/nginx/files/etc/nginx
    - template: jinja
    # TODO(raul): Confirm which user/group should be set here.
    - user: {{ nginx_user }}
    - group: root
    - exclude_pat: E@.*.swp
    - clean: True
    - require:
      - pkg: nginx-pkgs

{{ service_name }}: 
  service:
    - running
    - enable: True
    - require:
      - pkg: nginx-pkgs
    - watch:
      - file: {{ nginx_cnf_dir }}
