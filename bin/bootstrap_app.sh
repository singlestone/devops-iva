#!/bin/bash -v
# Make directories
mkdir /var/log/newrelic
mkdir -p /opt/chef
mkdir /tmp

# Grab and install Chef Client
wget -O /tmp/chef-client.rpm       https://s3.amazonaws.com/singlestone/binaries/chefdk-0.3.0-1.x86_64.rpm
rpm -Uvh /tmp/chef-client.rpm

# Grab configuration artifacts
wget -O /tmp/hostname.sh           https://s3.amazonaws.com/singlestone/chef/hostname.sh
wget -O /opt/chef/client.rb        https://s3.amazonaws.com/singlestone/chef/webclient.rb
wget -O /opt/chef/node.json        https://s3.amazonaws.com/singlestone/chef/webnode1.json

# Grab security artifacts
wget -O /opt/chef/validator.pem    https://s3.amazonaws.com/singlestone/chef/my_chef_validator.pem

# Set hostname
bash /tmp/hostname.sh
hostname InnovateVaApp
export HOSTNAME=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/local-hostname`

# Bootstrap App Server
chef-client -c /opt/chef/client.rb -s 60

# Notify completion
touch /root/chef-complete