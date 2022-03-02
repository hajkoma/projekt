#!/bin/bash

#Kontrola opravneni
if [[ $EUID -ne 0 ]]; then
  echo "Na spusteni tohoto skriptu je potreba mit root prava!"
  exit 1
else
# instalace databaze a nakonfigurovani fw
  echo "Mate uz nainstalovany PerconaXtraDB Cluster? (y/n)"
  read ynebon
  if [ "$ynebon" == "n" ]; then
    yum -y install https://repo.percona.com/yum/percona-release-latest.noarch.rpm
    yum -y update percona-release
    percona-release enable-only tools release
    yum -y install qpress
    percona-release enable-only pxc-80 release
    yum -y install percona-xtradb-cluster
    systemctl enable firewalld
    iptables -A INPUT -p tcp --dport 4567 -j ACCEPT
    iptables -A INPUT -p tcp --dport 3306 -j ACCEPT
    iptables -A INPUT -p tcp --sport 4567 -j ACCEPT
    iptables -A INPUT -p tcp --sport 3306 -j ACCEPT
  elif [ "$ynebon" == "y" ]; then
    echo "ok"
  else
    echo "bad input"
  fi

# Prirazeni Id k serveru
  echo "Jake ID chcete priradit tomuto serveru?"
  echo "ID musi byt na kazdem serveru odlisne!"
  read ids
  sed -i 's/server-id=1/server-id='$ids'/g' /etc/my.cnf

# Pojmenovani Clusteru
  echo "Jak chcete pojmenovat svuj cluster?"
  echo "Musi byt na vsech serverech stejne!"
  read cluster
  sed -i 's/wsrep_cluster_name=pxc-cluster/wsrep_cluster_name='$cluster'/g' /etc/my.cnf

# Definovani IP adres vsech serveru v clusteru
  echo "Zadejte IP adresy vsech databazi co budete pridavat do clusteru ve formatu XXX.XXX.XXX.XXX,XXX.XXX.XXX.XXX"
  echo "Musi byt stejne na vsech databazich!"
  read ip
  sed -i 's|wsrep_cluster_address=gcomm://|wsrep_cluster_address=gcomm://'$ip'|g' /etc/my.cnf

# Pojmenovani nasi databaze v clusteru
  echo "Jak chcete pojmenovat tuto konkretni databazi v ramci clusteru?"
  echo "Jmena musi byt odlisna na kazde databazi!"
  read meno
  sed -i 's/wsrep_node_name=pxc-cluster-node-1/wsrep_node_name='$meno'/g' /etc/my.cnf

# Definovani IP adresy databaze
  echo "Jaka je IP adresa teto databaze?"
  echo "Musi to byt jedna z tech co jste drive definovali!"
  read ipna
  sed -i 's/#wsrep_node_address=192.168.70.63/wsrep_node_address='$ipna'/g' /etc/my.cnf

# Vypnuti sifrovani replikace
  echo "pxc-encrypt-cluster-traffic=OFF" >> /etc/my.cnf

# Zapinani databaze podle toho jestli je prvni, kterou zapiname nebo ne
  echo "Je toto prvni databaze, kterou do clusteru pridavate? (y/n)"
  read ytakn
  if [ "$ytakn" == "n" ]; then
    systemctl start mysqld
  elif [ "$ytakn" == "y" ]; then
    systemctl start mysql@bootstrap.service
  else 
    echo "bad input"
  fi
  echo "Spustte tento skript na vsech serverech, na kterych chcete mit funkcni replikaci."
fi  
