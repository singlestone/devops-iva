hostname = `/usr/bin/curl -s http://169.254.169.254/latest/meta-data/local-ipv4`

node_name				"#{hostname}"
log_level				:debug
log_location			'/opt/chef/chef-client.log'
ssl_verify_mode			:verify_none
chef_server_url			"https://chefserver.singlestonedemo.com/organizations/ssc"
validation_client_name	"ssc-validator"
validation_key			"/opt/chef/validator.pem"
client_key				"/opt/chef/client.pem"
file_store_path			"/srv/chef/file_store"
file_cache_path			"/srv/chef/cache"
pid_file				"/var/run/chef/chef-client.pid"
json_attribs			"/opt/chef/node.json"