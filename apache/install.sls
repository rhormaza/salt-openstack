{% from "openstack/apache/map.jinja" import apache with context %}

apache:
  pkg.installed:
    - name: {{ apache.server }}

mod_wsgi:
  pkg.installed:
    - name: {{ apache.mod_wsgi }}
    - require:
      - pkg: apache

{% if grains.get('os_family') == 'RedHat' %}
/etc/httpd/conf.d/wsgi.conf:
  file:
    - uncomment
    - regex: LoadModule
    - require:
      - pkg: mod_wsgi
{% endif %}

{{ apache.server }}
  service:
    - running
    - name: {{ apache.service }}
    - enable: True

apache-reload:
  module.wait:
    - name: service.reload
    - m_name: {{ apache.service }}

apache-restart:
  module.wait:
    - name: service.restart
    - m_name: {{ apache.service }}
