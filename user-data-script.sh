#!/bin/sh
set -e -x

# Install git and puppet 
yum install git puppet -y

# Fetch puppet configuration from my public git repository.
mv /etc/puppet /etc/puppet.orig
git clone $puppet_source /etc/puppet

# Run puppet to deploy jetty 
puppet apply /etc/puppet/manifests/init.pp
