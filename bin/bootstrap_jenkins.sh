#!/bin/bash -v
# Make directories
mkdir /root/.chef
mkdir /etc/.chef
mkdir /var/log/newrelic
mkdir -p /opt/chef
mkdir /tmp
mkdir -p /var/lib/jenkins/.ssh

# Grab and install Chef Client
wget -O /tmp/chef-client.rpm       https://s3.amazonaws.com/singlestone/binaries/chefdk-0.3.0-1.x86_64.rpm
rpm -Uvh /tmp/chef-client.rpm

# Grab configuration artifacts
wget -O /root/.chef/knife.rb       https://s3.amazonaws.com/singlestone/chef/jenkinsknife.rb
wget -O /tmp/hostname.sh           https://s3.amazonaws.com/singlestone/chef/hostname.sh
wget -O /opt/chef/client.rb        https://s3.amazonaws.com/singlestone/chef/jenkinsclient.rb
wget -O /opt/chef/node.json        https://s3.amazonaws.com/singlestone/chef/cinode1.json
wget -O /var/lib/jenkins/.ssh/innovate.pem	   https://s3.amazonaws.com/singlestone/chef/innovate.pem

# Grab security artifacts
wget -O /etc/.chef/client.pem       https://s3.amazonaws.com/singlestone/chef/jenkins.pem
wget -O /opt/chef/validator.pem    https://s3.amazonaws.com/singlestone/chef/my_chef_validator.pem

# Set hostname
bash /tmp/hostname.sh
hostname InnovateVaJenkins
export HOSTNAME=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/local-hostname`

# Bootstrap Jenkins
chef-client -c /opt/chef/client.rb -s 60

# Notify completion
touch /root/chef-complete