{# Note(raul): saltref is needed in here, otherwise #}
{# macro will not render properly #}
{% macro pkg_install(saltref, pkgkey) %}
{{ pkgkey }}:
  pkg.installed:
    - pkgs:
{%- for k,v in saltref['pillar.get']('pkgs:%s'|format(pkgkey), {}).items() %}
      - {{ k }}: {{ v -}}
{% endfor -%}
{% endmacro %}
