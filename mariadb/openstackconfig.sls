# Note(raul): This include the pre-req used in this state.
include:
  - .install
  - .service

# TODO(raul): Move these variables to pillar system!
{%- set dbs = [
  'cinder',
  'glance',
  'keystone',
  'neutron',
  'nova', 
  'heat'
  ] %}
{%- set allowed_hosts = { 
  'local_with_host_ip' : "127.0.0.1", 
  'localhost' : "localhost", 
  'all' : "'%'"
  } %}

{%- for db in dbs %}
{{ db }}:
  mysql_database.present:
    - name: {{ salt['pillar.get'](db+':database:db_name', '') }}
    - character_set: utf8
    - require:
      - pkg: mysql-pkgs
      #- file: /etc/mysql/my.cnf
    - watch:
      - service: mysqld

{{ db }}-user:
  mysql_user.present:
    - name: {{ salt['pillar.get'](db+':database:user', '') }}
    - password: {{ salt['pillar.get'](db+':database:pass', '') }}
    - require:
      - mysql_database: {{ db }}

{% for name, host in allowed_hosts.items() %}
{{ db }}-{{ name }}-grants:
  mysql_grants.present:
    - grant: all
    - host: {{ host }}
    - user: {{ salt['pillar.get'](db+':database:user', '') }}
    - database: {{ salt['pillar.get'](db+':database:db_name', '') }}.*
    - require:
      - mysql_database: {{ db }}
{%- endfor %}
{%- endfor %}
