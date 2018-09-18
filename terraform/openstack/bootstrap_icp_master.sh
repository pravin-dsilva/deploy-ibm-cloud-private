#!/bin/bash -x

################################################################
# Module to deploy IBM Cloud Private
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Licensed Materials - Property of IBM
#
# Copyright IBM Corp. 2017.
#
################################################################

# Determine icp version
IFS='.' read -r -a iver <<< ${icp_version}
# fill in any empty digits (some only had 3)
for i in 0 1 2 3
do
    if [ -z $${iver[i]} ] ; then
        iver[$i]=0
    fi
done

# Determine the IBM Cloud Private embedded Docker image name
if [ "$${iver[0]}" -le "2" ] && [ "$${iver[1]}" -le "1" ] &&
    [ "$${iver[2]}" -le "0" ] && [ "$${iver[3]}" -le "2" ]; then
    # ICP 2.1.0.2 or earlier
    if [ "${icp_architecture}" == "ppc64le" ]; then
        ICP_DOCKER_IMAGE="ibmcom/icp-inception-ppc64le:${icp_version}"
    else
        ICP_DOCKER_IMAGE="ibmcom/icp_inception:${icp_version}"
    fi
else
    # ICP 2.1.0.3 or later
    ICP_DOCKER_IMAGE="ibmcom/icp-inception:${icp_version}"
fi

if [ "${icp_edition}" == "ee" ]; then
    ICP_DOCKER_IMAGE="$ICP_DOCKER_IMAGE-ee"
fi

# Root directory of ICP installation
ICP_ROOT_DIR="/opt/ibm-cloud-private-${icp_edition}"

# Enable NTP
/usr/bin/timedatectl set-ntp on
# Need to set vm.max_map_count to at least 262144
/sbin/sysctl -w vm.max_map_count=262144
/bin/echo "vm.max_map_count=262144" | /usr/bin/tee -a /etc/sysctl.conf

# Now for distro dependent stuff
if [ -f /etc/redhat-release ]; then
#RHEL specific steps
    # Disable the firewall
    systemctl stop firewalld
    systemctl disable firewalld
    # Make sure we're not running some old version of docker
    yum -y remove docker docker-engine docker.io
    yum -y install socat 
    # Either install the icp docker version or from the repo
    if [ ${docker_download_location} != "" ]; then
        TMP_DIR="$(/bin/mktemp -d)"
        cd "$TMP_DIR"
        /usr/bin/wget -q "${docker_download_location}"
        chmod +x *
        ./*.bin --install
        /bin/rm -rf "$TMP_DIR"
    else
        yum -y install docker-ce
    fi
    systemctl start docker
else 
# Ubuntu specific steps
    # Disable the firewall
    /usr/sbin/ufw disable
    # Prepare the system for updates, install Docker and install Python
    /usr/bin/apt update
    # Make sure we're not running some old version of docker
    /usr/bin/apt-get --assume-yes purge docker
    /usr/bin/apt-get --assume-yes purge docker-engine
    /usr/bin/apt-get --assume-yes purge docker.io
    /usr/bin/apt-get --assume-yes install apt-transport-https \
    ca-certificates curl software-properties-common python python-pip

    # Either install the icp docker version or from the repo
    if [ ${docker_download_location} != "" ]; then
        TMP_DIR="$(/bin/mktemp -d)"
        cd "$TMP_DIR"
        /usr/bin/wget -q "${docker_download_location}"
        chmod +x *
        ./*.bin --install
        /bin/rm -rf "$TMP_DIR"
    else
        # Add Docker GPG key
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        # Add the repo
        /usr/bin/add-apt-repository \
        "deb https://download.docker.com/linux/ubuntu \
         $(lsb_release -cs) stable"
        /usr/bin/apt update
        /usr/bin/apt-get --assume-yes install docker-ce
    fi
fi

# Ensure the hostnames are resolvable
IP=`/sbin/ip -4 -o addr show dev eth0 | awk '{split($4,a,"/");print a[1]}'`
/bin/echo "$IP $(hostname)" >> /etc/hosts

# Download and configure IBM Cloud Private
if [ "${icp_edition}" == "ee" ]; then
    TMP_DIR="$(/bin/mktemp -d)"
    cd "$TMP_DIR"
    /usr/bin/wget -q "${icp_download_location}"
    /bin/tar xf *.tar.gz -O | /usr/bin/docker load
else
    /usr/bin/docker pull $ICP_DOCKER_IMAGE
fi

/bin/mkdir "$ICP_ROOT_DIR"
cd "$ICP_ROOT_DIR"
/usr/bin/docker run -e LICENSE=accept -v \
    "$(pwd)":/data $ICP_DOCKER_IMAGE cp -r cluster /data

if [ "${icp_edition}" == "ee" ]; then
    /bin/mkdir -p cluster/images
    /bin/mv $TMP_DIR/*.tar.gz $ICP_ROOT_DIR/cluster/images/
    /bin/rm -rf "$TMP_DIR"
fi

# Configure the master and proxy as the same node
/bin/echo "[master]"  > cluster/hosts
/bin/echo "$IP"    >> cluster/hosts
/bin/echo "[va]"  >> cluster/hosts
/bin/echo "$IP"    >> cluster/hosts
/bin/echo "[proxy]"  >> cluster/hosts
/bin/echo "$IP"    >> cluster/hosts
# Configure the worker node(s)
for worker_ip in $( cat /root/icp_worker_nodes.txt | sed 's/|/\n/g' ); do
    /bin/echo "[worker]"     >> cluster/hosts
    /bin/echo "$worker_ip" >> cluster/hosts
done

# Modify config.yaml with appropriate variables - these come from the template
/bin/sed -i 's/.*ansible_user:.*/ansible_user: "'${install_user_name}'"/g' cluster/config.yaml
/bin/sed -i 's/.*ansible_become:.*/ansible_become: true/g' cluster/config.yaml
if [ -n "${install_user_password}" ]; then
    /bin/sed -i 's/.*ansible_become_password:.*/ansible_become_password: "'${install_user_password}'"/g' cluster/config.yaml
fi
if [ -n "${icp_disabled_services}" ]; then
    /bin/sed -i 's/.*disabled_management_services:.*/disabled_management_services: [ ${icp_disabled_services} ]/g' cluster/config.yaml
else
    /bin/sed -i 's/.*disabled_management_services:.*/disabled_management_services: [ "" ]/g' cluster/config.yaml

fi

# Setup the private key for the ICP cluster (injected at deploy time)
/bin/cp /root/id_rsa.terraform \
    $ICP_ROOT_DIR/cluster/ssh_key
/bin/chmod 400 $ICP_ROOT_DIR/cluster/ssh_key

# Deploy IBM Cloud Private
cd "$ICP_ROOT_DIR/cluster"
/usr/bin/docker run -e LICENSE=accept --net=host -t -v \
    "$(pwd)":/installer/cluster $ICP_DOCKER_IMAGE install | \
    /usr/bin/tee install.log

exit 0
