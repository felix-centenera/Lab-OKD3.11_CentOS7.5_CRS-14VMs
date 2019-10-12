Deploy OKD 3.11  (Free OpenShift 3.11)  & CentOS 7 & VirtualBox & Vagrant & Ansible
========================================

Description
--------------------------------
* This document describe the process to install OKD 3.11 (Free OpenShift 3.11) in VirtualBox. Vagrant generate the VMs and resources for us. Ansible will install requistes and OKD 3.11 for us.

* You can check the hardware requisites in Diagram/OLD LAB11.odd. It is not a mandatory requirement the disk sizing, as VirtualBox will no required the full size disk.  

*  You can change the harware definition of the VirtualMachines in the vagrantfile configuration. "vagrant/vagrantfile".

* Vagrant will create the disks under $HOME/VirtualBox/, default $Home for VirtualHost. You can change this path in the vagrantfile configuration. "vagrant/vagrantfile".


Tested under the next Configuration
--------------------------------
Host Fedora release 29

VirtualBox 6.0.4

Vagrant version: Installed Version: 2.2.4

    Vagrant  plugins:

        vagrant-disksize (0.1.3)

        vagrant-hostmanager (1.8.9)

        vagrant-persistent-storage (0.0.44)

        vagrant-share (1.1.9)

    Vagrant box list:

        centos/7  (virtualbox, 1902.01)
        CentOS Linux release 7.6.1810 (Core)

Infrastructure
--------------------------------
3 master nodes.

    master-one (Bastion node)

    master-two

    master-three

2 infra nodes.

    infra-one
    infra-two

2 app node.

    app-one
    app-two

2 loadbalancers Master nodes

    lb-one
    lb-two

2 loadbalancers Infra nodes

    lb-infra-one
    lb-infra-two    

3 Gluster nodes

    gluster-one
    gluster-two   
    gluster-three     

CRS (Container Ready Storage) as Storage solution. DEPLOY CONTAINERIZED STORAGE IN INDEPENDENT MODE

![alt text](https://github.com/felix-centenera/OKD3.11_CentOS7.5_CRS/blob/master/Diagram/diagrama.png)



Details
--------
Users Virtual Machine:

    user: root

    password: vagrant

    user: vagrant

    password: vagrant

Openshift admin user:

    user: admin

    password: r3dh4t1!



Download the project
-----------------------------------------
```
git clone  https://github.com/felix-centenera/OKD3.11_CentOS7.5_CRS.git
```
Generate VirtualBox Machines with Vagrant
-----------------------------------------
```
cd vagrant

vagrant up
```
Login in the bastion
-----------------------------------------
```
vagrant ssh master-one-okd11
```
Prepare the bastion node
-----------------------------------------
```
su root

ansible-playbook -i /root/ansible/inventories/bastion /root/ansible/playbooks/bastion.yml
```

Prepare  loadbalancers
-----------------------------------------
```

ansible-playbook -i /root/ansible/inventories/loadbalancerinfra /root/ansible/playbooks/loadbalancersinfra.yaml
ansible-playbook -i /root/ansible/inventories/loadbalancermaster /root/ansible/playbooks/loadbalancersmaster.yaml
```
Restart the loadbalancers nodes


Prepare  Gluster
-----------------------------------------
```
ansible-playbook -i /root/ansible/inventories/ocp /root/ansible/playbooks/glusterpreparation.yml
```
Restart the gluster nodes

Prepare the rest of the nodes for OKD 3.11
-----------------------------------------
```
ansible-playbook -i /root/ansible/inventories/ocp /root/ansible/playbooks/preparation.yml
```
Check prerequisites of the nodes for OKD 3.11
--------------------------------------------
```
ansible-playbook -i /root/ansible/inventories/ocp  /root/release-3.11/playbooks/prerequisites.yml
```
Install OKD 3.11
--------------------------------------------
```
ansible-playbook -i /root/ansible/inventories/ocp /root/release-3.11/playbooks/deploy_cluster.yml
```

Post installation OKD 3.11
-----------------------------------------

```
ansible-playbook -i /root/ansible/inventories/ocp /root/ansible/playbooks/postinstallation.yml
```

Deploy the console 3.11
--------------------------------------------

Modify the inventory, delete or comment the next parameter "openshift web console install=false", also you can change the parameter to true.

Then run the playbook. ;)


```
vi /root/ansible/inventories/ocp
```

```
ansible-playbook -i /root/ansible/inventories/ocp /root/release-3.11/playbooks/openshift-web-console/config.yml
```

NOTE:

Why? Usually the console is deployed in the first deploy installation, but the OCP installation will modified the /etc/resolve.conf with the IP of the node, this is the expected and correct funcionallity, but in Virtualbox we will need to change this IP in the /etc/resolv.conf with  the VirtualBox bridge IP, otherwise the nodes will not be able to acces to internet or resolve the routes. This change for VirtualBox has been automatizated with the playbook "postinstallation". If we deploy the console in first deploymente installation, the installation will fail as  one of the task from the Ansible installation will not be able to check that the route of the Console is working. This is the reason why we deploy OpenShift without the console, then we modified the /etc/resolve.conf with the playbook "postinstallation" and then we deploy the console.



Upgrade 3.11
--------------------------------------------
```
ansible-playbook -i /root/ansible/inventories/ocp /root/release-3.11/playbooks/byo/openshift-cluster/upgrades/v3_11/upgrade.yml
```

NOTE:
glusterfs block storage will not works in first instance due a BUG of the product. Upgrade to the last minor update if you want to used.





Prepare OKD 3.11
-----------------------------------------
```
oc login -u system:admin -n default

oc adm policy add-cluster-role-to-user cluster-admin admin

oc patch storageclass glusterfs-storage -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "true"}}}'
```

Start using OKD 3.11
-----------------------------------------
https://consoleocp.192.168.33.20.xip.io:8443/console/

OCP user : admin

OCP password : r3dh4t1!

HAProxy user: admin

HAProxy password: admin


CONSOLES:


https://consoleocp.192.168.33.20.xip.io:8443/console

https://grafana-openshift-monitoring.app.192.168.33.2.xip.io/

https://registry-console-default.app.192.168.33.2.xip.io/

https://console.app.192.168.33.2.xip.io/k8s/cluster/projects

http://192.168.33.21:1936/haproxy?stats

http://192.168.33.20:1936/haproxy?stats

http://192.168.33.2:1936/haproxy?stats


Sources:
-----------------------------------------

https://docs.openshift.com/container-platform/3.11/welcome/index.html

https://docs.okd.io/3.11/welcome/index.html

https://access.redhat.com/documentation/en-us/red_hat_cloudforms/4.6/html/high_availability_guide/configuring_haproxy

https://www.linuxtechi.com/setup-glusterfs-storage-on-centos-7-rhel-7/

https://www.maquinasvirtuales.eu/instalar-glusterfs-en-centos-7/

https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.3/html/container-native_storage_for_openshift_container_platform/chap-documentation-container_ready_storage#CRS_Installing_Red_Hat_Storage_Server_on_Red_Hat_Enterprise_Linux_Layered_Install

https://www.linuxtechi.com/setup-glusterfs-storage-on-centos-7-rhel-7/

https://docs.gluster.org/en/latest/Install-Guide/Install/#for-red-hatcentos

https://torusware.com/es/blog/2017/02/openshift-origin-jenkins-almacenamiento-persistente-glusterfs/

https://access.redhat.com/articles/3403951

https://access.redhat.com/articles/2176281#fn:8

https://access.redhat.com/articles/2356261

https://medium.com/@wilson.wilson/install-heketi-and-glusterfs-with-openshift-to-allow-dynamic-persistent-volume-management-89156340b2bd

https://glusterdocs-beta.readthedocs.io/en/latest/install-guide/Install.html

http://mirror.centos.org/centos-7/7.6.1810/storage/x86_64/gluster-3.12/

https://www.unixmen.com/install-glusterfs-server-client-centos-7/

https://github.com/gluster/gluster-block

https://buildlogs.centos.org/centos/7/storage/x86_64/gluster-5/
