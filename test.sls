#grains.ls:
#  module:
#    - run
#
#salt:
#  module.run:
#    - name: keystone.user_list
#
#raul.foo:
#  module.run:
#    - name: raul.foo
#    - arg: 'uname -a'
#
#raul.bar:
#  module.run:
#    - name: raul.bar
#    - args: 
#      - 'uname -a'
#      - 'ls -la'
#
#raul.baz:
#  module.run:
#    - name: raul.baz
#    - a: whoami
#    - arg1: hostname
#    - arg2: id
#
#raul.test:
#  module.run:
#    - name: raul.test
#    - a: 
#      - 1.1
#      - 1.2
#    - kw: {
#      arg1: 2.1,
#      arg2: 2.2
#      }
#{% set FILE = 'no' -%}
#foo:
#  cmd:
#    - run
#    - name: free && touch /tmp/{{ FILE }}
#    - unless: test -f /tmp/{{ FILE }}
##    - kwargs: {hostname: 'hostname', id: 'id'}
#
#foo01:
#  cmd.run:
#    - name: keystone service-list| grep identity| cut -d\| -f2 | xargs echo
#


## Files
/tmp/__FOO__:
  file.managed:
    - source: {{ FILE_PATH }}/__foo__
    - template: jinja
    - user: nova
    - group: nova
    - mode: 644
    - context:
      ip: {{ salt['network.interfaces']()['eth2']['inet'][0]['address'] }}
      dns: __BAR__
