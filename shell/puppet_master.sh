#!/usr/bin/env bash
#

set -e
COLLECTION=$1

## install agent packages
if [ $COLLECTION ]; then
  if [ -e /etc/profile.d/puppet4 ]
  then 
    echo "puppetlabs bin already added to path"
  else
  	echo 'export PATH="/opt/puppetlabs/bin:$PATH"' > /etc/profile.d/puppet4.sh
  fi

  if [ -e /opt/puppetlabs/bin/puppet ]; then 
    echo "Puppet agent already installed"
  else
      echo "Installing Puppet Agent packages..."
    if [ -e "/etc/debian_version" ]
    then
      DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install puppet-agent >/dev/null
    else
      yum install -y puppet-agent > /dev/null
    fi
  fi
else
  if [ -e /usr/bin/puppet ]; then 
    echo "Puppet already installed"
  else
      echo "Installing puppet packages..."
    if [ -e "/etc/debian_version" ]
    then
      DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install puppet hiera facter >/dev/null
    else
      yum install -y puppet hiera facter > /dev/null
    fi
  fi
fi

# install server packages
if [ $COLLECTION ]; then
  if [ -e /opt/puppetlabs/bin/puppetserver ]; then 
    echo "Puppet server already installed"
    echo "starting puppet server"
    service puppetserver start
  else
    echo "Installing Puppet Server packages..."
    if [ -e "/etc/debian_version" ]; then
      DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install puppetserver >/dev/null
      sudo sed -i "s/2g/512m/g" /etc/default/puppetserver
      sudo sed -i "s/256m/128m/g" /etc/default/puppetserver
    else
      yum install -y puppetserver > /dev/null
      sudo sed -i "s/2g/512m/g" /etc/sysconfig/puppetserver
      sudo sed -i "s/256m/128m/g" /etc/default/puppetserver
    fi
    echo "starting puppet server"
    service puppetserver restart
  fi
else
  if [ -e /usr/bin/puppetserver ]; then 
    echo "Puppet server already installed"
    echo "starting puppet server"
    service puppetserver start
  else
    echo "Installing Puppet server packages..."
    if [ -e "/etc/debian_version" ]; then
      DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install puppetserver >/dev/null
      sudo sed -i "s/2g/512m/g" /etc/default/puppetserver
      sudo sed -i "s/256m/128m/g" /etc/default/puppetserver
    else
      yum install -y puppetserver > /dev/null
      sudo sed -i "s/2g/512m/g" /etc/sysconfig/puppetserver
      sudo sed -i "s/256m/128m/g" /etc/default/puppetserver
    fi
    echo "starting puppet server"
    service puppetserver restart
  fi
fi

if [ -e /usr/sbin/puppetdb ]
then 
  echo "PuppetDB already installed"
else
    echo "Installing PuppetDB packages..."
  if [ -e "/etc/debian_version" ]
  then
    DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install puppetdb >/dev/null
  else
    yum install -y puppetdb > /dev/null
  fi
fi

if [ -e /opt/puppetlabs/puppet/lib/ruby/vendor_ruby/puppet/util/puppetdb/command.rb ]
then
  echo "PuppetDB-terminus already installed"
else
  echo "Installing PuppetDB terminus packages..."
  if [ -e "/etc/debian_version" ]
  then
    DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install puppetdb-terminus >/dev/null
  else
    yum install -y puppetdb-terminus > /dev/null
  fi
fi

if [ -e "/usr/bin/gem" ]; then
	echo "rubygems already installed"
else
	# Install Rubygems...
	echo "Installing rubygems"
    if [ -e "/etc/debian_version" ]; then
    	DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install ruby1.9.1 >/dev/null
    else
      yum install -y rubygems > /dev/null
    fi
	echo "rubygems installed!"
fi

if [ -e "/usr/bin/git" ]; then
	echo "Git already installed"
else
	# Install git...
	echo "Installing Git"
  if [ -e "/etc/debian_version" ]; then
  	DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install git >/dev/null
  else
    yum install -y git > /dev/null
  fi
fi

if [ -e "/usr/local/bin/r10k" ]; then
	echo "R10K already installed"
else
	# Install R10K...
	echo "Installing R10K"
	gem install r10k -v 1.5.1 > /dev/null
	echo "R10K installed!"
fi

if [ -e "/vagrant/dot_netrc" ]; then
	echo "Copying netrc file"
	cp /vagrant/dot_netrc /root/.netrc
	mkdir -p /var/cache/r10k_cache_pivit/
	echo "deploying environment with R10K"
	/usr/local/bin/r10k deploy environment -pv -c /vagrant/puppet/puppetmaster_r10k.yaml
else
	# Netrc file doesn't exist
	echo "Please create your dot_netrc file"
fi
