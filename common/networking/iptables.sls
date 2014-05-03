#TODO(raul): config this in all the system!
#salt-iptables-rules:
#  cmd.run:
#    - name: >
#        iptables -A INPUT -p tcp -m multiport --dports 4505,4506 -j ACCEPT &&
#        service iptables save
#    - unless: grep -E "A.*INPUT.*dports.*4505.*4506.*ACCEPT" /etc/sysconfig/iptables
#
