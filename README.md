# Welcome to the OpenStack Install Scripts project on GitHub

This project aims to covert the steps in the OpenStack Install guide into useful/simple scripts. The goal is not to provide a complete automation solution. But the idea is to have simple building blocks which can help developers and enthusiasts experiment with OpenStack in a much simpler fashion.

#### Platform supported - Ubuntu
#### OpenStack version - Juno

## How to use the scripts step by step ##

1. Update lib/config-parameters.sh script 
   - Change the hostname to be used for controller. This name will be used in all configuration files. You will need to use this name to update the /etc/hosts file for correct lookups. 
   - Change passwords as necessary 

2. Install common packages
   - Execute `sudo bash install.sh common`
   - It is a good idea to reboot the system since kernel packages may have been updated.

3. Install OpenStack packages depending upon the type of the node
   - If the node is of type controller, execute sudo bash install.sh controller
   - If the node is of type compute, execute `sudo bash install.sh compute`
   - If the node is of type networknode, execute `sudo bash install.sh networknode`
   - If the node is of type allinone, execute `sudo bash install.sh allinone`
   - **Note - during the installation of MariaDB, you will be required to enter DB password manually**

4. Configure OpenStack packages depending upon the type of the node
   - If the node is of type controller, execute `sudo bash configure.sh controller`
   - If the node is of type compute, execute `sudo bash configure.sh compute`
   - If the node is of type networknode, execute `sudo bash configure.sh networknode`
   - If the node is of type allinone, execute `sudo bash configure.sh allinone`
   - **Note - during the configuration of MariaDB, you will be required to confirm few DB clean up operations manually** 

