# TDOO(raul): add versions.
#
# Packages
mysql-pkgs:
  pkg.installed:
    - pkgs:
      - mariadb-galera-server  # 5.5.36-6.el6
      - galera                 # 25.3.5-1.el6
      - mariadb-galera-common  # 5.5.36-6.el6
      - nc                     # 1.84-22.el6
      - perl-DBD-MySQL         # 4.013-3.el6
      - perl-DBI               # 1.609-4.el6
      - mariadb-galera
      - mysql-libs
      # Other
      - MySQL-python
      #NOTE: provides openstack-db command
      #- openstack-utils
