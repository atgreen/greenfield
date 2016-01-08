Greenfield: the virtual infrastructure demo generator
===================================================== 
Greenfield is an open source project to build demo-capable backend IT
infrastructure based mostly on Red Hat products and technologies.

More specifically, the goal of the project is to provide the means for
performing hands-off virtual deployments of a complete suite of IT
infrastructure tools suitable for the purpose of demonstration on a
laptop or similar.  Key characteristics of the project include:

* *Offline Friendly*.  Most installable media are downloaded in advance
to support offline deployments, and to conserve bandwidth over
multiple deployments.

* *Ease of Use*. Basic configuration is performed through a text-based
GUI configuration tool borrowed from the Linux kernel project.
Deployments and tear-downs are simple one line commands.

* *Supports the Full Stack*. Nested virtualization is leveraged where
possible to demonstrate virtualization technologies such as RHEV and
RHEL-OSP.

* *A Useful Learning Tool*. The configuration and build scripts are
intended to be well documented, demonstrating how various components
in the stack may be integrated.  Links to reference documentation are
provided where appropriate.

Prerequisites
=============

Local Software
--------------

You'll need some local software on your system.  The following should do the trick:

    $ yum install gcc make virt-manager virt-install createrepo yum-utils httpd

Private Virtual Network
-----------------------

You'll need to set up a private network for libvirt managed guests.
Drop the following file in /etc/libvirt/qemu/networks/10_0.xml :

    <network>
      <name>10_0</name>
      <uuid>fc760627-1490-3fa4-7719-7b40a1c48f65</uuid>
      <forward mode='nat'/>
      <bridge name='gf0' stp='on' forwardDelay='0' ></bridge>
      <ip address='10.0.0.1' netmask='255.255.255.0'/>
    </network>

Now do this...

    cd /etc/libvirt/qemu/networks/autostart/
    ln -s ../10_0.xml .

Restart libvirtd and you should be good to go.  We're going to place
all of the greenfield VMs on this private 10.0.0.0/24 network.


Library
-------

The 'Library' is where we place all of the media required to install
and configure our environment.  The media needs to be published via
http to VMs on our private network.  

1. Turn on httpd (systemctl start httpd && systemctl enable httpd).
2. Create a Library directory under /var/www/html (or symlink).  This is where we're
   going to place all of the content.  

Make sure you can access the Library from another system.  This may
require messing with firewalls and SELinux.

Here's what needs to go into the Library:

1. rhel-server-7.2-x86_64-dvd.iso from access.redhat.com
2. rhel-guest-image-7.1-20150224.0.x86_64.qcow2 from access.redhat.com
3. a new 'repos' directory

We'll fill the repos directory by syncing content from RHN to your
local system.  First, however, you'll need to enable the appropriate
channels.  This may require attaching to new and different
subscriptions with subscription-manager.

    #!/bin/sh

    for R in \
      rhel-7-server-rpms \
      rhel-7-server-satellite-6.1-rpms \
      rhel-7-server-ose-3.1-rpms \
      rhel-7-server-extras-rpms \
      rhel-7-server-optional-rpms \
      rhel-server-rhscl-7-rpms \
      rhel-7-server-openstack-7.0-rpms \
      rhel-7-server-aep-beta-rpms; do \
      subscription-manager repos --enable=$R; \
    done;



Now let's fill the repo mirrors using reposync...

    #!/bin/sh
        
    LIBRARY=/var/www/html/Library/repos
    
    for R in \
      rhel-7-server-rpms \
      rhel-7-server-satellite-6.1-rpms \
      rhel-7-server-ose-3.1-rpms \
      rhel-7-server-extras-rpms \
      rhel-7-server-optional-rpms \
      rhel-server-rhscl-7-rpms \
      rhel-7-server-aep-beta-rpms; do \
      rhel-7-server-openstack-7.0-rpms; do \
      reposync -lnm --repoid=$R --download_path=$LIBRARY; \
      createrepo $LIBRARY/$R; 
    done;


Local Mount Directory
---------------------

You'll need a local mount directory in which we'll mount the RHEL
ISO. I use /mnt/x, but anything is fine.

Now you are ready to configure and build!


Build Instructions
==================
* run make
* run script/install


Usage Notes
===========

Red Hat OpenShift Enterprise
----------------------------

Connect to 10.0.0.40:8443 for the console.  It is configured to allow
anyone to log in, but only after it has finished installing critical
infrastructure (the router and registry containers).  You will not be
able to login until this is complete.

Also note that the installation process involves downloading docker
images from docker.io and redhat.com.  Greenfield does not currently
support fully offline deployments at this time.


Red Hat Enterprise Linux OpenStack Platform
-------------------------------------------
 
* Log in as 'admin' and use the admin password you created at configure
time.
* A private network of 10.1.0.0/24 is available for all OSP instances.
* You'll find a RHEL7 cloud image in the image repository.
* Create new RHEL7 instances of size m1.small
* Use the following cloud-init script to enable root logins.  Set this
  during instance creation time

<pre>
    #cloud-config
    # vim:syntax=yaml
    debug: True
    ssh_pwauth: True
    disable_root: false
    chpasswd:
      list: |
        root:password
        cloud-user:password
      expire: false
    runcmd:
    - sed -i'.orig' -e's/without-password/yes/' /etc/ssh/sshd_config
    - service sshd restart
</pre>

Contributing to Greenfield
==========================
Greenfield is currently hosted on github at
[https://github.com/atgreen/greenfield/]().  Pull requests and issues
welcome!


Licensing
=========
Greenfield is licensed under the GNU General Public License, Version
2. See [LICENSE](https://github.com/atgreen/greenfield/blob/master/LICENSE)
for the fulle license text.


