#!/bin/sh

cd ~/

curl -L https://www.opscode.com/chef/install.sh | bash

wget http://github.com/opscode/chef-repo/tarball/master
tar -zxf master
mv opscode-chef-repo* chef-repo
rm master

cd chef-repo
ls

mkdir .chef
echo "cookbook_path [ '/root/chef-repo/cookbooks' ]" > .chef/knife.rb

knife cookbook create phpapp

cd cookbooks/phpapp
ls

cd ..
knife cookbook site download apache2
tar zxf apache2*
rm apache2*.tar.gz
knife cookbook site download apt
tar zxf apt*
rm apt*.tar.gz

cd phpapp

echo "
depends \"apache2\"" >> metadata.rb

echo "
include_recipe \"apache2\"" >> recipes/default.rb

cd ../..

echo "file_cache_path \"/root/chef-solo\"
cookbook_path \"/root/chef-repo/cookbooks\"" > solo.rb

echo "{
  \"run_list\": [ \"recipe[apt]\", \"recipe[phpapp]\" ]
}" > web.json

chef-solo -c solo.rb -j web.json

cd cookbooks
knife cookbook site download mysql 
tar zxf mysql*
rm mysql-*.tar.gz

cd mysql/recipes
ls

cd ../../phpapp

echo "depends \"mysql\"" >> metadata.rb

echo "include_recipe \"mysql::client\"
include_recipe \"mysql::server\"" >> recipes/default.rb

cd ../..
chef-solo -c solo.rb -j web.json

cd cookbooks
knife cookbook site download openssl
tar zxf openssl*.tar.gz
rm openssl*.tar.gz
knife cookbook site download build-essential
tar zxf build-essential-*.tar.gz
rm build-essential-*.tar.gz

cd ..
chef-solo -c solo.rb -j web.json

echo "{
  \"mysql\": {\"server_root_password\": \"808052769e2c6d909027a2905b224bad\", \"server_debian_password\": \"569d1ed2d46870cc020fa87be83af98d\", \"server_repl_password\": \"476911180ee92a2ee5a471f33340f6f4\"},
  \"run_list\": [ \"recipe[apt]\", \"recipe[phpapp]\" ]
}" > web.json

chef-solo -c solo.rb -j web.json

cd cookbooks/
knife cookbook site download php
tar zxf php*.tar.gz
rm php*.tar.gz

knife cookbook site download xml
tar zxf xml-*.tar.gz
rm xml-*.tar.gz

cd phpapp

echo "depends \"php\"" >> metadata.rb

echo "include_recipe \"php\"
include_recipe \"php::module_mysql\"
include_recipe \"apache2::mod_php5\"

apache_site \"default\" do
  enable true
end" >> recipes/default.rb

cd ../..
chef-solo -c solo.rb -j web.json

echo "<?php phpinfo(); ?>" > /var/www/test.php

rm /var/www/test.php

cd cookbooks
knife cookbook site download database
tar zxf database-*.tar.gz
knife cookbook site download postgresql
tar zxf postgresql-*.tar.gz
knife cookbook site download xfs
tar zxf xfs-*.tar.gz
knife cookbook site download aws
tar zxf aws-*.tar.gz
rm *.tar.gz

cd phpapp

echo "depends \"database\"" >> metadata.rb

echo "#
# Cookbook Name:: phpapp
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe \"apache2\"
include_recipe \"mysql::client\"
include_recipe \"mysql::server\"
include_recipe \"php\"
include_recipe \"php::module_mysql\"
include_recipe \"apache2::mod_php5\"
include_recipe \"mysql::ruby\"

apache_site \"default\" do
  enable true
end

mysql_database node['phpapp']['database'] do
  connection ({:host => 'localhost', :username => 'root', :password => node['mysql']['server_root_password']})
  action :create
end" > recipes/default.rb

cd ../..
chef-solo -c solo.rb -j web.json

cd cookbooks/phpapp

echo "default[\"phpapp\"][\"database\"] = \"phpapp\"" > attributes/default.rb

cd ../..
chef-solo -c solo.rb -j web.json

cd cookbooks/phpapp

echo "#
# Cookbook Name:: phpapp
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe \"apache2\"
include_recipe \"mysql::client\"
include_recipe \"mysql::server\"
include_recipe \"php\"
include_recipe \"php::module_mysql\"
include_recipe \"apache2::mod_php5\"
include_recipe \"mysql::ruby\"

apache_site \"default\" do
  enable true
end

mysql_database node['phpapp']['database'] do
  connection ({:host => 'localhost', :username => 'root', :password => node['mysql']['server_root_password']})
  action :create
end

mysql_database_user node['phpapp']['db_username'] do
  connection ({:host => 'localhost', :username => 'root', :password => node['mysql']['server_root_password']})
  password node['phpapp']['db_password']
  database_name node['phpapp']['database']
  privileges [:select,:update,:insert,:create,:delete]
  action :grant
end" > recipes/default.rb

echo "default[\"phpapp\"][\"db_username\"] = \"phpapp\"" >> attributes/default.rb

cd ../..

echo "{
  \"mysql\": {\"server_root_password\": \"808052769e2c6d909027a2905b224bad\", \"server_debian_password\": \"569d1ed2d46870cc020fa87be83af98d\", \"server_repl_password\": \"476911180ee92a2ee5a471f33340f6f4\"},
  \"phpapp\": {\"db_password\": \"212b09752d173876a84d374333ae1ffe\"},
  \"run_list\": [ \"recipe[apt]\", \"recipe[phpapp]\" ]
}" > web.json

chef-solo -c solo.rb -j web.json

# Fetching Wordpress

cd cookbooks/phpapp

echo "
wordpress_latest = Chef::Config[:file_cache_path] + '/wordpress-latest.tar.gz'

remote_file wordpress_latest do
  source 'http://wordpress.org/latest.tar.gz'
  mode 0644
end

directory node['phpapp']['path'] do
  owner 'root'
  group 'root'
  mode 0755
  action :create
  recursive true
end

execute 'untar-wordpress' do
  cwd node['phpapp']['path']
  command 'tar --strip-components 1 -xzf ' + wordpress_latest
  creates node['phpapp']['path'] + '/wp-settings.php'
end" >> recipes/default.rb

echo "default['phpapp']['path'] = '/var/www/phpapp'" >> attributes/default.rb

cd ../..
chef-solo -c solo.rb -j web.json

ls /var/www/phpapp

chef-solo -c solo.rb -j web.json

# Templates

cd cookbooks/phpapp

echo "
wp_secrets = Chef::Config[:file_cache_path] + '/wp-secrets.php'

remote_file wp_secrets do
  source 'https://api.wordpress.org/secret-key/1.1/salt/'
  action :create_if_missing
  mode 0644
end" >> recipes/default.rb

echo "<?php

define('DB_NAME', '<%= @database %>');
define('DB_USER', '<%= @user %>');
define('DB_PASSWORD', '<%= @password %>');
define('DB_HOST', 'localhost');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

<%= @wp_secrets %>

\$table_prefix  = 'wp_';

define('WPLANG', '');
define('WP_DEBUG', false);

if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');" > templates/default/wp-config.php.erb

echo "salt_data = ''

ruby_block 'fetch-salt-data' do
  block do
    salt_data = File.read(wp_secrets)
  end
  action :create
end

template node['phpapp']['path'] + '/wp-config.php' do
  source 'wp-config.php.erb'
  mode 0755
  owner 'root'
  group 'root'
  variables(
    :database        => node['phpapp']['database'],
    :user            => node['phpapp']['db_username'],
    :password        => node['phpapp']['db_password'],
    :wp_secrets      => salt_data)
end" >> recipes/default.rb

cd ../..
chef-solo -c solo.rb -j web.json

# Creating an Apache VirtualHost

cd cookbooks/phpapp

echo "# Auto generated by Chef. Changes will be overwritten.

<VirtualHost *:80>
  ServerName <%= @params[:server_name] %>
  DocumentRoot <%= @params[:docroot] %>

  <Directory <%= @params[:docroot] %>>
    Options FollowSymLinks
    AllowOverride FileInfo Options
    AllowOverride All
    Order allow,deny
    Allow from all
  </Directory>

  <Directory />
    Options FollowSymLinks
    AllowOverride None
  </Directory>

</VirtualHost>" > templates/default/site.conf.erb


echo "#
# Cookbook Name:: phpapp
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe \"apache2\"
include_recipe \"mysql::client\"
include_recipe \"mysql::server\"
include_recipe \"php\"
include_recipe \"php::module_mysql\"
include_recipe \"apache2::mod_php5\"
include_recipe \"mysql::ruby\"

apache_site \"default\" do
  enable false
end

mysql_database node['phpapp']['database'] do
  connection ({:host => 'localhost', :username => 'root', :password => node['mysql']['server_root_password']})
  action :create
end

mysql_database_user node['phpapp']['db_username'] do
  connection ({:host => 'localhost', :username => 'root', :password => node['mysql']['server_root_password']})
  password node['phpapp']['db_password']
  database_name node['phpapp']['database']
  privileges [:select,:update,:insert,:create,:delete]
  action :grant
end

wordpress_latest = Chef::Config[:file_cache_path] + '/wordpress-latest.tar.gz'

remote_file wordpress_latest do
  source 'http://wordpress.org/latest.tar.gz'
  mode 0644
end

directory node['phpapp']['path'] do
  owner 'root'
  group 'root'
  mode 0755
  action :create
  recursive true
end

execute 'untar-wordpress' do
  cwd node['phpapp']['path']
  command 'tar --strip-components 1 -xzf ' + wordpress_latest
  creates node['phpapp']['path'] + '/wp-settings.php'
end

wp_secrets = Chef::Config[:file_cache_path] + '/wp-secrets.php'

remote_file wp_secrets do
  source 'https://api.wordpress.org/secret-key/1.1/salt/'
  action :create_if_missing
  mode 0644
end

salt_data = ''

ruby_block 'fetch-salt-data' do
  block do
    salt_data = File.read(wp_secrets)
  end
  action :create
end

template node['phpapp']['path'] + '/wp-config.php' do
  source 'wp-config.php.erb'
  mode 0755
  owner 'root'
  group 'root'
  variables(
    :database        => node['phpapp']['database'],
    :user            => node['phpapp']['db_username'],
    :password        => node['phpapp']['db_password'],
    :wp_secrets      => salt_data)
end

web_app 'phpapp' do
  template 'site.conf.erb'
  docroot node['phpapp']['path']
  server_name node['phpapp']['server_name']
end" > recipes/default.rb

echo "default['phpapp']['server_name'] = 'phpapp'" >> attributes/default.rb

cd ../..

echo "{
  \"mysql\": {\"server_root_password\": \"808052769e2c6d909027a2905b224bad\", \"server_debian_password\": \"569d1ed2d46870cc020fa87be83af98d\", \"server_repl_password\": \"476911180ee92a2ee5a471f33340f6f4\"},
  \"phpapp\": {\"db_password\": \"212b09752d173876a84d374333ae1ffe\", \"server_name\": \"intro.hellofutu.re\"},
  \"run_list\": [ \"recipe[apt]\", \"recipe[phpapp]\" ]
}" > web.json

chef-solo -c solo.rb -j web.json