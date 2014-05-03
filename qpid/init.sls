
# Packages
qpid-pkgs:
  pkg.installed:
    - names:
        - qpid-cpp-client
        - qpid-cpp-server
        - qpid-qmf
        - qpid-tools
        - python-qpid-qmf
        - python-qpid

# Services
qpidd:
  service:
    - running
    - enable: True
  require:
      - pkg: qpid-pkgs
