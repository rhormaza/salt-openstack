
# Packages
rabbitmq-pkgs:
  pkg.installed:
    - names:
        - erlang
        - rabbitmq-server

# Services
rabbitmq-server:
  service:
    - dead
    - enable: False
    #- running
    #- enable: True
  require:
      - pkg: rabbitmq-pkgs
