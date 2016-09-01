
# Welcome to the OpenStack Install Scripts project on GitHub

This project aims to covert the steps in the OpenStack Install guide into useful/simple scripts. The goal is not to provide a _perfect_ automation solution. But the idea is to have simple building blocks which can help developers and enthusiasts experiment with OpenStack in a much simpler fashion.

#### Platform supported - Ubuntu server 14.04
#### OpenStack version - Mitaka

#### Prerequisites ####
_git_ binaries must be installed on your Ubuntu server. This is needed to checkout the scripts to your Ubuntu server. 

If you are using VirtualBox, refer to this blog for Network settings - http://goo.gl/VTJVmv

#### OpenStack services installed ####
The following OpenStack services are installed as part these scripts:

1. Keystone (Identity)
2. Glance (Image)
3. Nova (Compute)
4. Neutron (Networking)
5. Horizon (Dashboard)
6. Heat (Orchestration) - work in progress
7. Ceilometer (Telemetry) - work in progress

#### Important Notes ####
1. The script installs Linux Bridge packages by default. Installing OVS can be done using a utility script provided in the `lib` directory.
2. The Nova configuration includes a setting to use `AllHostsFilter` as the default filter for scheduler. If you want the default filters of Nova, remove this entry and restart Nova services on the controller.
3. Many scripts detect the OpenStack Node Type automatically using `util/detect-nodetype.sh` script.
4. The node type controller includes network node capabilities. This is new behavior in OpenStack since Liberty release.
5. VXLAN is the default tenant network type used.

## How to use the scripts step by step ##

1. Edit the lib/config-parameters.sh file
   - Important: Make sure that Management and Data plane interface names are accurate. *Mandatory for Ubuntu 14.04*
   - Optional: Change the hostname to be used for controller. This name will be used in all configuration files. 
   - Optional: Change passwords as necessary 

2. Install OpenStack packages depending upon the type of the node
   - If the node is of type controller, execute `sudo bash install.sh controller`
   - If the node is of type compute, execute `sudo bash install.sh compute`
   - If the node is of type networknode, execute `sudo bash install.sh networknode`
   - If the node is of type allinone, execute `sudo bash install.sh allinone`
   - **Note - during the installation of MariaDB, you will be required to setup DB password first time manually (for Ubunutu 14.04)**

3. Configure OpenStack packages using `sudo bash configure.sh <controller_ip_address>`. The **node type** is detected automatically.
   - **Note - during the configuration of MariaDB, you will be required to enter DB password manually and confirm few DB clean up operations** 

4. Post Config Actions can be triggered using `sudo bash post-config-actions.sh` script on the controller node only. This interactive script does the following:
   - Enables web browser based view of Nova and Neutron log files.
   - Downloads and creates a Cirros Glance Image for booting up VMs.
   - Creates two OpenStack networks and their subnets
   - **Note - each step is optional and can be skipped as required**


## Useful scripts - Updating IP Address ##

If there is a change in the IP address of the controller, then use the `util/update-ip.sh` script to ensure that all config settings are updated. This command needs to be run on controller as well as the compute nodes.

Usage: `sudo bash util/update-ip.sh <management-interface-name> <controller-host-name> <controller-ip>`. 
The second and third parameter is used for network nodes and compute nodes.

## Removing OpenStack packages ##

You can remove all the OpenStack packages using `sudo bash remove.sh`. The **node type** is detected automatically and the corresponding packages are removed.

## Restarting OpenStack services ##

Restarting OpenStack services is needed at times - especially when config file entries are changed. You can execute `sudo bash manage-services.sh` to do this. The **node type** is detected automatically.

## Updating /etc/hosts file ##

Since all configuration uses the name of the controller host, it is important to update `/etc/hosts` file on all the node to map an IP address to the controller host name. You can use the `util/update-etc-hosts.sh` script for this purpose.


