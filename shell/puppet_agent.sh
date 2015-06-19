#!/usr/bin/env bash
#
set -e
COLLECTION=$1

if [ $COLLECTION ]
  if [ -e /etc/profile.d/puppet4 ]; then 
    echo "puppetlabs bin already added to path"
  else
  	echo 'export PATH="/opt/puppetlabs/bin:$PATH"' > /etc/profile.d/puppet4.sh
  fi

  if [ -e /opt/puppetlabs/bin/puppet ]; then 
    echo "Puppet agent already installed"
  else
      echo "Installing puppet-agent packages..."
    if [ -e "/etc/debian_version" ]; then
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
    if [ -e "/etc/debian_version" ]; then
      DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install puppet hiera facter >/dev/null
    else
      yum install -y puppet hiera facter > /dev/null
    fi
  fi
fi
