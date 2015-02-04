#
# Cookbook Name:: jenkins
# Recipe:: master
#
# Author: AJ Christensen <aj@junglist.gen.nz>
# Author: Dough MacEachern <dougm@vmware.com>
# Author: Fletcher Nichol <fnichol@nichol.ca>
# Author: Seth Chisamore <schisamo@getchef.com>
# Author: Guilhem Lettron <guilhem.lettron@youscribe.com>
# Author: Seth Vargo <sethvargo@gmail.com>
#
# Copyright 2010, VMWare, Inc.
# Copyright 2013, Youscribe.
# Copyright 2012-2014, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Gracefully handle the failure for an invalid installation type
begin
  include_recipe "jenkins::_master_#{node['jenkins']['master']['install_method']}"
rescue Chef::Exceptions::RecipeNotFound
  raise Chef::Exceptions::RecipeNotFound, "The install method " \
    "`#{node['jenkins']['master']['install_method']}' is not supported by " \
    "this cookbook. Please ensure you have spelled it correctly. If you " \
    "continue to encounter this error, please file an issue."
end

directory "/etc/chef" do
	action :create
end

# Install Git and HipChat plugins
jenkins_plugin 'git' do
#  notifies :restart, 'service[jenkins]', :immediately
end

jenkins_plugin 'hipchat' do
  notifies :restart, 'service[jenkins]', :immediately
end

# Place Jenkins system configuration file (includes path to maven)
cookbook_file "/var/lib/jenkins/config.xml" do
	source "jenkins_config.xml"
	action :create
	owner "jenkins"
	group "jenkins"
	mode "0644"
end

# Integrate with HipChat
template "/var/lib/jenkins/jenkins.plugins.hipchat.HipChatNotifier.xml" do
	source "jenkins.plugins.hipchat.HipChatNotifier.erb"
	action :create
	owner "jenkins"
	group "jenkins"
	mode "0644"
end

directory "/var/lib/jenkins/jobs/Build\ and\ Deploy\ App\/" do
	action :create
	owner 'jenkins'
	group 'jenkins'
	mode "0755"
	recursive true
end

directory "/var/lib/jenkins/jobs/executeshell/" do
	action :create
	owner 'jenkins'
	group 'jenkins'
	mode "0755"
	recursive true
end

cookbook_file "/var/lib/jenkins/credentials.xml" do
	source "credentials.xml"
	owner 'jenkins'
	group 'jenkins'
	mode "0644"
	action :create
end

directory "/var/lib/jenkins/.ssh" do
	action :create
	owner 'jenkins'
	group 'jenkins'
	mode '0700'
end

remote_file "/var/lib/jenkins/.ssh/innovate.pem" do
	action :create
	source "https://s3.amazonaws.com/singlestone/chef/innovate.pem"
	owner 'jenkins'
	group 'jenkins'
	mode '0600'
end

template "/var/lib/jenkins/jobs/Build\ and\ Deploy\ App\/config.xml" do
	source "job-config.erb"
	owner  'jenkins'
	group  'jenkins'
	mode   "0644"
	action :create
end

template "/var/lib/jenkins/jobs/executeshell/config.xml" do
	source "shell-job.erb"
	owner  'jenkins'
	group  'jenkins'
	mode   "0644"
	action :create
end

cookbook_file "/var/lib/jenkins/hudson.tasks.Maven.xml" do
	source "hudson.tasks.Maven.xml"
	owner 'jenkins'
	group 'jenkins'
	mode "0644"
	action :create
	notifies :restart, 'service[jenkins]', :immediately
end

bash "set permissions on deployment key" do
	code <<-EOH
	chmod 600 /var/lib/jenkins/.ssh/innovate.pem
	chown jenkins:jenkins /var/lib/jenkins/.ssh/innovate.pem
	EOH
end
