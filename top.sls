base:
  '*':
    - openstack.common
    - openstack.common.vim
    - openstack.common.users
    - openstack.common.hosts
    - openstack.common.git
    - openstack.common.openssh
    - openstack.common.tcpdump
    - openstack.common.nmap
  'osvm01*':
    - openstack.dnsmasq
  'osvm02*':
    - openstack.mysql
    - openstack.qpid
  #'osvm03*':
  #  - openstack.keystone
  'os-vm01':
    - openstack.common.dnsmasq
  'osvm08*':
    - openstack.cinder

