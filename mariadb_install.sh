#!/bin/bash

if [[ $EUID -ne 0 ]]; then
  echo "Na spusteni tohoto skriptu je potreba mit root prava!"
  exit 1
else
  yum install wget
  wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
  bash mariadb_repo_setup
  yum install mariadb-server
  systemctl start mariadb
  mariadb-server-installation
  systemctl status mariadb
fi
