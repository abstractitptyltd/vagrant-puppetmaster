#!/usr/bin/env bash
# This bootstraps Puppet and R10K on CentOS 5.x

if [ -e "/usr/bin/puppet" ]; then
	echo "puppet already installed"
else
	# Install Puppet...
	echo "Installing puppet"
	yum install -y puppet-2.7.25 #> /dev/null
	echo "Puppet installed!"
fi

if [ -e "/usr/sbin/puppetmasterd" ]; then
	echo "puppet master already installed"
else
	# Install Puppet master...
	echo "Installing puppet server"
	yum install -y puppet-server-2.7.25 #> /dev/null
	echo "Puppet server installed!"
fi

if [ -e "/usr/bin/gem" ]; then
	echo "rubygems already installed"
else
	# Install Rubygems...
	echo "Installing rubygems server"
	yum install -y rubygems #> /dev/null
	echo "rubygems installed!"
fi

if [ -e "/usr/bin/git" ]; then
	echo "Git already installed"
else
	# Install git...
	echo "Installing Git"
	yum install -y git #> /dev/null
	echo "Git installed!"
fi

if [ -e "/usr/bin/r10k" ]; then
	echo "R10K already installed"
else
	# Install R10K...
	echo "Installing R10K"
	gem install r10k #> /dev/null
	echo "R10K installed!"
fi

if [ -e "/vagrant/dot_netrc" ]; then
	echo "Copying netrc file"
	cp /vagrant/dot_netrc /root/.netrc
	mkdir -p /var/tmp/r10k_cache_carinity/
	echo "deploying environment with R10K"
	r10k deploy environment -pv -c /vagrant/puppet/puppetmaster_r10k.yaml
else
	# Netrc file doesn't exist
	echo "Please create your dot_netrc file"
fi

