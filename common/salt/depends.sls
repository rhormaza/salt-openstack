salt-iptables-rules:
  cmd.run:
    - name: >
        iptables -A INPUT -p tcp -m multiport --dports 4505,4506 -j ACCEPT &&
        service iptables save
    - unless: grep -E "A.*INPUT.*dports.*4505.*4506.*ACCEPT" /etc/sysconfig/iptables

ensure-resolv-conf:
  cmd.run:
    - name: echo "nameserver 144.136.201.10" >> /etc/resolv.conf
    - unless: grep "nameserver 144.136.201.10" /etc/resolv.conf
  
ensure-salt-host-file:
  cmd.run:
    - name: echo "10.0.0.1 salt" >> /etc/hosts
    - unless: grep "10.0.0.1 salt" /etc/hosts

sshpass:
  cmd.run:
    - name: yum -y install sshpass
    - unless: rpm -qa |grep sshpass
