update_etc_hosts:
  salt.state:
    - tgt: 'all'
    - tgt_type: nodegroup
    - sls: openstack.common.hosts

##################
# QPID
##################
install_qpid:
  salt.state:
    - tgt: 'memcached'
    - tgt_type: nodegroup
    - sls: openstack.qpid
    - require: 
      - salt: update_etc_hosts

##################
# Memcached
##################
install_memcached:
  salt.state:
    - tgt: 'memcached'
    - tgt_type: nodegroup
    - sls: openstack.memcached
    - require: 
      - salt: update_etc_hosts

##################
# MariaDB+Galera
##################
install_mariadb:
  salt.state:
    - tgt: 'mariadb'
    - tgt_type: nodegroup
    - sls: openstack.mariadb
    - require: 
      - salt: update_etc_hosts

##################
# Horizon
##################
install_apache_horizon:
  salt.state:
    - tgt: 'horizon'
    - tgt_type: nodegroup
    - sls: openstack.apache.horizon
    - require: 
      - salt: update_etc_hosts

install_nginx_horizon:
  salt.state:
    - tgt: 'horizon'
    - tgt_type: nodegroup
    - sls: openstack.nginx.horizon
    - require: 
      - salt: install_apache_horizon

##################
#  Keystone
##################
install_keystone:
  salt.state:
    - tgt: 'keystone'
    - tgt_type: nodegroup
    - sls: openstack.keystone
    - require: 
      - salt: update_etc_hosts

#install_apache_keystone:
#  salt.state:
#    - tgt: 'horizon'
#    - tgt_type: nodegroup
#    - sls: openstack.apache.keystone
#    - require: 
#      - salt: install_keystone

##################
#  Glance
##################
install_glance:
  salt.state:
    - tgt: 'glance'
    - tgt_type: nodegroup
    - sls: openstack.glance
    - require: 
      - salt: update_etc_hosts

##################
# Cinder
##################
install_cinder:
  salt.state:
    - tgt: 'cinder'
    - tgt_type: nodegroup
    - sls: openstack.cinder
    - require: 
      - salt: update_etc_hosts

##################
# Heat
##################
install_heat:
  salt.state:
    - tgt: 'heat'
    - tgt_type: nodegroup
    - sls: openstack.heat
    - require: 
      - salt: update_etc_hosts

##################
#  Nova Control
##################
install_nova_controller:
  salt.state:
    - tgt: 'nova'
    - tgt_type: nodegroup
    - sls: openstack.nova.controller
    - require: 
      - salt: update_etc_hosts

##################
#  Neutron Control
##################
install_neutron_controller:
  salt.state:
    - tgt: 'neutron'
    - tgt_type: nodegroup
    - sls: openstack.neutron.controller
    - require: 
      - salt: update_etc_hosts

###################
#  Nova Compute
###################
install_nova_compute:
  salt.state:
    - tgt: 'compute'
    - tgt_type: nodegroup
    - sls: openstack.nova.compute
    - require: 
      - salt: update_etc_hosts

###################
#  Neutron Compute
###################
install_neutron_compute:
  salt.state:
    - tgt: 'compute'
    - tgt_type: nodegroup
    - sls: openstack.neutron.compute
    - require: 
      - salt: update_etc_hosts





##################
# 
##################
##################
# 
##################
##################
# 
##################
##################
# 
##################
##################
# 
##################
##################
# 
##################
##################
# 
##################
##################
# 
##################
##################
# 
##################
##################
# 
##################
##################
# 
##################
##################
# 
##################
##################
# 
##################
##################
# 
##################
##################
# 
##################
##################
# 
##################
