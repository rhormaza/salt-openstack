{% set FILE_PATH =  salt['pillar.get']('common_rootfs', 'NOT_FOUND') %}

#TODO(raul): Add CentOS/RedHat support
/etc/hosts:
  file.managed:
    - source: {{ FILE_PATH }}/common/hosts/files/hosts
    - template: jinja
    - user: root
    - group: root
    - mode: 644
