{# Global variables used in the state #}
{% set HOST = salt['grains.get']('id').split('.')[0] -%}
{% set FILE_PATH = salt['pillar.get']('formula_rootfs', 'NOT_FOUND') %}

# TODO(raul): This var should be replaced by new one HOST
{% set current_host = salt['grains.get']('host', '__NOT_FOUND__') %}
{% set current_host_if_ref = 'hosts:%s:if'|format(current_host) %}  

# TODO(raul): add support for other OS/Distros. Debian-based, arch, etc.
# Note: Using "is" operator fails
#       is it really valid in jinja templates?
#       E.g.: if "RedHat" is salt['grains.get']('os_family')
{% if "RedHat" == salt['grains.get']('os_family') %}
{% set os_family_service_name = 'network' %}
{% set if_conf_file_name = '/etc/sysconfig/network-scripts/ifcfg-%s' %}
{% endif %}

network-services:
  service:
    - running
    - enable: True
    - names:
      - {{ os_family_service_name }}



{% for if_name, if_info in salt['pillar.get'](current_host_if_ref, {}).iteritems() %}

{{ if_conf_file_name|format(if_name) }}:
  file.managed:
    - template: jinja
{% if if_info.get('gateway') %}
    - source: {{ FILE_PATH }}/common/networking/files/redhat_ifcfg-if_name_with_gw_n_dns.jinja
{% elif if_info.get('bootproto') == 'dhcp' %}
    - source: {{ FILE_PATH }}/common/networking/files/redhat_ifcfg-if_name_dhcp.jinja
{% else %}
    - source: {{ FILE_PATH }}/common/networking/files/redhat_ifcfg-if_name_static.jinja
{% endif %}
    - user: root
    - group: root
    - mode: 644

    # Inject pillar values in the template file here
    - context:
        device: {{ if_name }}
        bootproto: "{{ if_info.get('bootproto', 'static') }}"
        onboot: "{{ if_info.get('onboot', 'yes') }}"
        type: {{ if_info.get('type') }} 
        mac: "{{  if_info.get('mac') }}"
        ip: {{ if_info.get('ip', '') }}
        netmask: {{ if_info.get('netmask', '') }}
        gateway:  {{ if_info.get('gateway', '') }}
        dns1: {{ if_info.get('dns1', '') }}
        dns2: {{ if_info.get('dns2', '') }}
    #- watch_in:
    #  - service: network-services

{% endfor %}
