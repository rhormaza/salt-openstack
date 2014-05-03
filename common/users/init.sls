{% for user, args in pillar['users'].iteritems() %}
{{ user }}:
  group.present:
    - gid: {{ args['gid'] }}
  user.present:
    - home: {{ args['home'] }}
    - shell: {{ args['shell'] }}
    - uid: {{ args['uid'] }}
    - gid: {{ args['gid'] }}
{% if 'password' in args %}
    - password: {{ args['password'] }}
{% if 'enforce_password' in args %}
    - enforce_password: {{ args['enforce_password'] }}
{% endif %}
{% endif %}
{% if 'groups' in args %}
    - groups: {{ args['groups'] }}
{% endif %}
    - require:
      - group: {{ user }}
{% endfor %}
