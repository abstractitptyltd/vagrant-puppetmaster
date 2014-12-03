#!/usr/bin/env bash
# This bootstraps Puppet on CentOS 5.x

if [ "$EUID" -ne "0" ]
then
  echo "This script must be run as root." >&2
  exit 1
fi

set -e
EPEL_REPO_URL="http://mirror.optus.net/epel/5/i386/epel-release-5-4.noarch.rpm"
PL_REPO_URL="http://yum.puppetlabs.com/el/5/products/i386/puppetlabs-release-5-11.noarch.rpm"

if [ -e "/etc/yum.repos.d/epel.repo" ]
then
	echo "epel repo already installed"
else
	# Install EPEL repo
	echo "Configuring EPEL repo..."
	epel_repo_path=$(mktemp)
	wget --output-document="${epel_repo_path}" "${EPEL_REPO_URL}" 2>/dev/null
	rpm -Uvh "${epel_repo_path}" >/dev/null
	
	# Import EPEL gpg key
	echo "Importing gpg keys"
	rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-5
fi

if [ -e "/etc/yum.repos.d/puppetlabs.repo" ]
then
	echo "puppetlabs repo already installed"
else
	# Install puppet labs repo
	echo "Configuring PuppetLabs repo..."
	pl_repo_path=$(mktemp)
	wget --output-document="${pl_repo_path}" "${PL_REPO_URL}" 2>/dev/null
	rpm -Uvh "${pl_repo_path}" >/dev/null
	
	# Import PL gpg key
	echo "Importing PL gpg keys"
	rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs
fi
