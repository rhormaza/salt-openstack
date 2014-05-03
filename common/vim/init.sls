{# Global variables used in the state #}
{% set HOST = salt['grains.get']('id').split('.')[0] -%}
{% set FILE_PATH = salt['pillar.get']('formula_rootfs', 'NOT_FOUND') %}

{% if grains['os_family'] == 'RedHat' %}
{% set source_file = 'redhat_vimrc' %}
{% set pkg_name = 'vim-enhanced' %}
{% elif grains['os'] == 'Debian' %}
{% set source_file = 'vimrc' %}
{% set pkg_name = 'vim-nox' %}
{% elif grains['os'] == 'Arch' %}
{% set source_file = 'arch_vimrc' %}
{% set pkg_name = 'vim' %}
{% endif %}

vim:
  pkg:
    - installed
    - name: {{ pkg_name }}

/etc/vimrc:
  file:
    - managed
    - source: {{ FILE_PATH }}/common/files/{{ source_file }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - makedirs: True
    - require:
      - pkg: vim
