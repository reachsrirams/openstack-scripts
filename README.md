# Welcome to the OpenStack Install Scripts project on GitHub

This project aims to covert the steps in the OpenStack Install guide into useful/simple scripts. The goal is not to provide a complete automation solution. But the idea is to have simple building blocks which can help developers and enthusiasts experiment with OpenStack in a much simpler fashion.

#### Platform supported - Ubuntu
#### OpenStack version - Juno

## How to use the scripts ##

1. Step 1 - update lib/config-parameters.sh script 
   - Change the hostname to be used for controller. This name will be used in all configuration files. You will need to use this name to update the /etc/hosts file for correct lookups. 
   - Change passwords as necessary 

2. Step 2 - install common packages
   - Execute _sudo bash install.sh common_
   - It is a good idea to reboot the system since kernel packages may have been updated.

3. Step 3 - install OpenStack packages depending upon the type of the node
   - If the node is of type controller, execute **sudo bash install.sh controller**
   - If the node is of type compute, execute _sudo bash install.sh compute_
   - If the node is of type networknode, execute _sudo bash install.sh networknode_
   - If the node is of type allinone, execute _sudo bash install.sh allinone_
   - **Note - during the installation of MariaDB, you will be required to enter DB password manually**


4. Step 5 - configure OpenStack packages depending upon the type of the node
   - If the node is of type controller, execute _sudo bash configure.sh controller_
   - If the node is of type compute, execute _sudo bash configure.sh compute_
   - If the node is of type networknode, execute _sudo bash configure.sh networknode_
   - If the node is of type allinone, execute _sudo bash configure.sh allinone_
   - **Note - during the configuration of MariaDB, you will be required to confirm few DB clean up operations manually** 

