{# Note(raul): saltref is needed in here, otherwise #}
{# macro will not render properly #}

{# Package install #}
{% macro pkg_install(saltref, pkgkey) %}
{{ pkgkey }}:
  pkg.installed:
    - pkgs:
{%- for k,v in saltref['pillar.get']('pkgs:%s'|format(pkgkey), {}).items() %}
      - {{ k }}: {{ v -}}
{% endfor -%}
{% endmacro %}

{# Package uninstall #}
{% macro pkg_uninstall(saltref, pkgkey) %}
{{ pkgkey }}:
  pkg.removed:
    - pkgs:
{%- for k,v in saltref['pillar.get']('pkgs:%s'|format(pkgkey), {}).items() %}
      - {{ k }}: {{ v -}}
{% endfor -%}
{% endmacro %}


{# Include FILE_PATH in a particular *.sls #}
{% macro include_file_path() %}
{% set FILE_PATH = salt['pillar.get']('formula_rootfs', 'NOT_FOUND') %}
{% endmacro %}
