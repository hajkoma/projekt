#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Na spusteni tohoto skriptu je potreba mit root prava!"
  exit 1
else
  yum install wget
  wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
  chmod 755 mariadb_repo_setup
  yum install mariadb-server
  systemctl start mariadb
  mariadb-server-installation
  systemctl enable firewalld
  iptables -A INPUT -p tcp --dport 3306 -j ACCEPT
fi
