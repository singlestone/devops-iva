# See http://docs.getchef.com/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
user_email  = `git config --get user.email`
home_dir    = ENV['HOME'] || ENV['HOMEDRIVE']
org         = ENV['chef_org'] || 'ssc'

knife_override = "#{home_dir}/.chef/knife_override.rb"

log_level                :info
log_location             STDOUT
node_name                "dtashner"
client_key               "/Users/davetashner/Documents/InnovateVA/chef/dtashner.pem"
validation_client_name   "ssc-validator"
validation_key           "/Users/davetashner/Documents/InnovateVA/chef/validator.pem"
chef_server_url          "https://chefserver.singlestonedemo.com/organizations/ssc"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            [ '/Users/davetashner/Documents/InnovateVA/chef/cookbooks' ]
