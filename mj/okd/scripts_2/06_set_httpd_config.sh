#!/bin/bash
source src/env
if [ -e /html ];then
  unlink /html
fi
ln -sf var/www/html /html

sed -i 's/^Listen 80$/Listen 8080/' /etc/httpd/conf/httpd.conf
systemctl enable --now httpd
