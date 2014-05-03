install_rabbitmq:
  salt.state:
    - tgt: 'lxapp51(35n|57)'
    - tgt_type: pcre
    - sls: zenoss.rabbitmq


config_rabbitmq_cluster:
  salt.state:
    - tgt: 'lxapp51(35n|57)'
    - tgt_type: pcre
    - sls: zenoss.rabbitmq.config_cluster
    - require: 
      - salt: install_rabbitmq

