### Work in Progress ###

# Welcome to the OpenStack Install Scripts project on GitHub

This project aims to covert the steps in the OpenStack Install guide into useful/simple scripts. The goal is not to provide a complete automation solution. But the idea is to have simple building blocks which can help developers and enthusiasts experiment with OpenStack in a much simpler fashion.

#### Platform supported - Ubuntu 16.04
#### OpenStack version - Mitaka

#### Prerequisites ####
Git packages must be installed on your Ubuntu server. This is needed to checkout the scripts to your Ubuntu server. 

If you are using VirtualBox, refer to this blog for Network settings - http://goo.gl/VTJVmv

#### OpenStack services installed ####
The following OpenStack services are installed as part these scripts:

1. Keystone (Identity)
2. Glance (Image)
3. Nova (Compute)
4. Neutron (Networking)
5. Horizon (Dashboard)
6. Ceilometer (Telemetry)
7. Heat (Orchestration)

#### Important Notes ####
1. The installation installs only Linux Bridge packages by default. Installing OVS can be done using a utility script provided in `util` directory.
2. The Nova configuration includes a setting to use `AllHostsFilter` as the default filter for scheduler. If you want the default filters of Nova, remove this entry and restart Nova services on the controller.
3. Many scripts detect the OpenStack Node Type automatically using `util/detect-nodetype.sh` script.
4. The node type controller includes network node capabilities. This is new behavior in OpenStack from Liberty release.

## How to use the scripts step by step ##

1. Edit the lib/config-parameters.sh file
   - Important: Make sure that Management and Data plane interface names are accurate
   - Change the hostname to be used for controller. This name will be used in all configuration files. 
   - Change passwords as necessary 

2. Install OpenStack packages depending upon the type of the node
   - If the node is of type controller, execute `sudo bash install.sh controller`
   - If the node is of type compute, execute `sudo bash install.sh compute`
   - If the node is of type networknode, execute `sudo bash install.sh networknode`
   - If the node is of type allinone, execute `sudo bash install.sh allinone`
   - **Note - during the installation of MariaDB, you will be required to enter DB password manually**

3. Configure OpenStack packages using `sudo bash configure.sh`. The **node type** is detected automatically.
   - If the node is of type controller, execute `sudo bash configure.sh`
   - If the node is of type compute etc, execute `sudo bash configure.sh <controller_ip_address>`
   - **Note - during the configuration of MariaDB, you will be required to enter DB password manually and confirm few DB clean up operations** 

## Updating IP Address ##

The install scripts use a name for the controller (defined in `config-parameters.sh` script). This name needs to be updated in the /etc/hosts file. Also to view the VNC console of an instance, it is convenient to use IP address in the Nova configuration file. All these changes can be done using `util/update-ip.sh` script. 

Usage: `sudo bash util/update-ip.sh <controller-host-name> <controller-ip>`. 
The second parameter is used for network nodes and compute nodes.

## Removing OpenStack packages ##

You can remove all the OpenStack packages using `sudo bash remove.sh`. The **node type** is detected automatically and the corresponding packagesa are removed.

## Restarting OpenStack services ##

Restarting OpenStack services is needed at times - especially when config file entries are changed. You can execute `sudo bash manage-services.sh` to do this. The **node type** is detected automatically.

## Updating /etc/hosts file ##

Since all configuration uses the name of the controller host, it is important to update `/etc/hosts` file on all the node to map an IP address to the controller host name. You can use the `util/update-etc-hosts.sh` script for this purpose.


