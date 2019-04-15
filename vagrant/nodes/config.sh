#!/bin/bash

##ALLOW root login & password PasswordAuthentication

sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

##CHANGE Password to root
echo "vagrant" | passwd --stdin root

##Update the Machine
yum update -y
yum upgrade -y
