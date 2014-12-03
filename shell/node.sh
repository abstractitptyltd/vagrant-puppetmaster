#!/usr/bin/env bash
# This bootstraps Puppet on CentOS 5.x
# It has been tested on CentOS 5.6 64bit

if [ -e "/usr/bin/puppet" ]; then
	echo "puppet already installed"
else
	# Install Puppet...
	echo "Installing puppet"
	yum install -y puppet-2.7.25 #> /dev/null
	echo "Puppet installed!"
fi
