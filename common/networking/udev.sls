{# Global variables used in the state #}
{% set HOST = salt['grains.get']('id').split('.')[0] -%}
{% set FILE_PATH = salt['pillar.get']('formula_rootfs', 'NOT_FOUND') %}

{% if "RedHat" == salt['grains.get']('os_family') %}
/etc/udev/rules.d/75-persistent-net.rules:
  file.managed:
    - template: jinja
    - source: {{ FILE_PATH }}/common/networking/files/redhat_75-persistent-net.rules.jinja
    - user: root
    - group: root
    - mode: 644

udev-rules-reload:
  cmd:
    - wait
    - name: >
        service network stop; 
        udevadm control --reload-rules; 
        udevadm trigger; 
        service network start
    - watch:
      - file: /etc/udev/rules.d/75-persistent-net.rules
{% endif %}
