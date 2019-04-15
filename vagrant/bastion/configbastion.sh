#!/bin/bash

## Install Ansible in node bastion


yum update -y
yum upgrade -y
yum --enablerepo=extras install epel-release -y

sudo pip uninstall ansible || true
yum -y  install  pyOpenSSL python-pip python-dev sshpass python ansible # this will install ansible-2.4
sudo mkdir -p /etc/ansible
pip install --upgrade ansible  # this will install ansible-2.6



sudo pip -H install --upgrade ansible  # this will install ansible-2.6


sudo mv /tmp/ansible.cfg /etc/ansible/
sudo mv /tmp/ansible /root/
ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa

for host in lb-one.192.168.33.3.xip.io \
            lb-two.192.168.33.4.xip.io \
            lb-infra.192.168.33.5.xip.io \
            lb-infra.192.168.33.6.xip.io \
            master-two.192.168.33.8.xip.io \
            master-three.192.168.33.9.xip.io \
            infra-one.192.168.33.10.xip.io \
            infra-two.192.168.33.11.xip.io \
            app-one.192.168.33.12.xip.io \
            app-two.192.168.33.13.xip.io \
            gluster-one.192.168.33.14.xip.io \
            gluster-two.192.168.33.15.xip.io \
            gluster-three.192.168.33.16.xip.io \
            master-one.192.168.33.7.xip.io; \
            do sshpass -f /tmp/password.txt ssh-copy-id -o "StrictHostKeyChecking no" -f $host;  \
            done
