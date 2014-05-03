memcached:
  pkg:
    - installed
  service:
    - running
    - enable: True
    - require:
      - pkg: memcached

python-memcached:
  pkg:
    - installed
    - require:
      - pkg: memcached
