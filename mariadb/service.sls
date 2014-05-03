{# Global variables used in the state #}
{% set HOST = salt['grains.get']('id').split('.')[0] -%}
{% set FILE_PATH = salt['pillar.get']('formula_rootfs', 'NOT_FOUND') %}

# Note(raul): This include the pre-req used in this state.
include:
  - .install

# TODO(raul): Check if this still happens when installing galera
mysql_install_db:
  cmd.run:
    - name: mysql_install_db --user=mysql --datadir=/var/lib/mysql
    - unless: test -f /var/lib/mysql/mysql/host.frm && test -f /var/lib/mysql/mysql/user.frm
    - require:
      - pkg: mysql-pkgs

/etc/my.cnf:
  file.managed:
    - source: {{ FILE_PATH }}/mariadb/files/etc/my.cnf
    - template: jinja
    - require:
      - pkg: mysql-pkgs

/etc/my.cnf.d:
  file.recurse:
    - source: {{ FILE_PATH }}/mariadb/files/etc/my.cnf.d
    - template: jinja
    - clean: True
    - require:
      - pkg: mysql-pkgs

# Services
mysqld:
  service:
    - running
    - enable: True
  require:
    - pkg: mysql-pkgs
    - watch:
      - file: /etc/my.cnf
      - file: /etc/my.cnf.d
