Greenfield: the virtual infrastructure demo generator
===================================================== 
Greenfield is an open source project to build demo-capable backend IT
infrastructure based mostly on Red Hat products and technologies.

More specifically, the goal of the project is to provide the means for
performing hands-off virtual deployments of a complete suite of IT
infrastructure tools suitable for the purpose of demonstration on a
laptop or similar.  Key characteristics of the project include:

* *Offline Friendly*.  All installable media are downloaded in advance
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
------

The 'Library' is where we place all of the media required to install
and configure our environment.  The media needs to be published via
http to VMs on our private network.  

1. Turn on httpd (systemctl start httpd && systemctl enable httpd).
2. Create a Library directory under /var/www/html (or symlink).  This is where we're
   going to place all of the content.  

Make sure you can access the Library from another system.  This may
require messing with firewalls and SELinux.

Here's what needs to go into the Library:

1. rhel-server-7.1-x86_64-dvd.iso
2. a new 'repos' directory

Now let's fill the repo mirrors using reposync...

    #!/bin/sh
        
    LIBRARY=/var/www/html/Library/repos
    
    for R in \
      rhel-7-server-rpms \
      rhel-7-server-satellite-6.1-rpms \
      rhel-7-server-extras-rpms \
      rhel-7-server-optional-rpms \
      rhel-server-rhscl-7-rpms \
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


