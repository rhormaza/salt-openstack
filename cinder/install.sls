{# Global variables used in the state #}
{% set HOST = salt['grains.get']('id').split('.')[0] -%}
{% set FILE_PATH = salt['pillar.get']('formula_rootfs', 'NOT_FOUND') %}
{% set OS_VER = salt['pillar.get']('openstack_version', 'icehouse') %}

{% set cinder_cnf_dir = '/etc/cinder' %}
{% set cinder_log_dir = '/var/log/cinder' %}
{% set cinder_user = 'cinder' %}
{% set cinder_group = 'cinder' %}
{% set service_name = 'cinder' %}
cinder-pkgs:
  pkg.installed:
    - names:
      - openstack-cinder
      - openstack-cinder-doc
      - openstack-selinux
      - python-cinderclient
      - iscsi-initiator-utils
      - scsi-target-utils

{{ cinder_cnf_dir }}:
  file.recurse:
    - source: {{ FILE_PATH }}/cinder/files/{{ OS_VER }}{{ cinder_cnf_dir }}
    - template: jinja
    - user: {{ cinder_user }}
    - group: {{ cinder_group }}
    - backup: minion
    - require:
      - pkg: cinder-pkgs

cinder-manage:
  cmd.run:
    - name: cinder-manage --nodebug db sync && touch {{ cinder_cnf_dir }}/DB_SYNC_DONE
    - unless: test -f {{ cinder_cnf_dir }}/DB_SYNC_DONE
    - require:
      - pkg: cinder-pkgs
      - file: {{ cinder_cnf_dir }}

cinder-volume-create:
  cmd:
    - run
    - name: >
        pvcreate {{ salt['pillar.get']('cinder:volume:disk3', '') }}
        &&
        vgcreate {{ salt['pillar.get']('cinder:volume_group', '') }} 
        {{ salt['pillar.get']('cinder:volume:disk3', '') }}
    - unless: vgs {{ salt['pillar.get']('cinder:volume_group', '') }}
    - require:
      - pkg: cinder-pkgs

cinder-services:
  service:
    - running
    - enable: True
    - names:
      - openstack-cinder-api
      - openstack-cinder-scheduler
      - openstack-cinder-volume
      - tgtd
    - require:
      - pkg: cinder-pkgs
    - watch:
      - cmd: cinder-manage
      - file: {{ cinder_cnf_dir }}
#      - file: /etc/tgt/targets.conf

# TODO(raul): move this to their own *.sls
/etc/tgt/targets.conf:
  file.managed:
    - source: {{ FILE_PATH }}/cinder/files/{{ OS_VER }}/etc/tgt/targets.conf
    - template: jinja
    - user: root
    - group: root
    - backup: minion
    - require:
      - pkg: cinder-pkgs

/etc/lvm/lvm.conf:
  file.managed:
    - source: {{ FILE_PATH }}/cinder/files/{{ OS_VER }}/etc/lvm/lvm.conf
    - template: jinja
    - user: root
    - group: root
    - backup: minion
    - require:
      - pkg: cinder-pkgs

include:
  - openstack.keystone.keystonerc_admin
