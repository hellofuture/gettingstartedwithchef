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
knife cookbook site download git
tar zxf git-*.tar.gz
knife cookbook site download windows
tar zxf windows-*.tar.gz
knife cookbook site download dmg
tar zxf dmg-*.tar.gz
knife cookbook site download runit
tar zxf runit-*.tar.gz
knife cookbook site download chef_handler
tar zxf chef_handler-*.tar.gz
knife cookbook site download yum
tar zxf yum-*.tar.gz
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

echo "depends \"git\"
depends \"database\"" >> metadata.rb

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
dT9LLecu9Bwi
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
include_recipe \"git\"

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
end

directory node['phpapp']['path']  do
  owner \"www-data\"
  group \"www-data\" 
  mode \"0775\"
  recursive true
  action :create
end

git node['phpapp']['path'] do
  repository \"git://github.com/hellofuture/exampleapp.git\"
  reference \"master\"
  action :sync
end" > recipes/default.rb

echo "default[\"phpapp\"][\"path\"] = \"/var/www/croogo\"" >> attributes/default.rb

cd ../..
chef-solo -c solo.rb -j web.json

cd cookbooks/phpapp

echo "
execute 'import croogo structure' do
  command 'mysql -u root --password=' + 
          node['mysql']['server_root_password'] + ' ' +
          node['phpapp']['database'] + ' < ' +
          node['phpapp']['path'] + '/app/Config/Schema/sql/croogo.sql'
  not_if do
    require 'mysql'
    m = Mysql.new('localhost',
                  'root', 
                  node['mysql']['server_root_password'], 
                  node['phpapp']['database'])     
    m.list_tables.include?('acos')
  end
end" >> recipes/default.rb

cd ../..
chef-solo -c solo.rb -j web.json

chef-solo -c solo.rb -j web.json

cd cookbooks/phpapp

echo "
execute 'import croogo static data' do
  command 'mysql -u root --password=' + 
          node['mysql']['server_root_password'] + ' ' +
          node['phpapp']['database'] + ' < ' +
          node['phpapp']['path'] + '/app/Config/Schema/sql/croogo_data.sql'
  not_if do
    require 'mysql'
    m = Mysql.new('localhost',
                  'root', 
                  node['mysql']['server_root_password'], 
                  node['phpapp']['database'])     
    begin
      m.query(\"select count(*) from acos\").fetch_row.first.to_i > 0
    ensure
      m.close
    end
  end
end"  >> recipes/default.rb

cd ../..
chef-solo -c solo.rb -j web.json

chef-solo -c solo.rb -j web.json

cd cookbooks/php

echo "<?php
class DATABASE_CONFIG {

    public \$default = array(
        'datasource' => 'Database/Mysql',
        'persistent' => false,
        'host' => 'localhost',
        'login' => '<%= @user %>',
        'password' => '<%= @password %>',
        'database' => '<%= @database %>',
        'prefix' => '',
        'encoding' => 'UTF8'
    );

    public \$test = array(
        'datasource' => 'Database/Mysql',
        'persistent' => false,
        'host' => 'localhost',
        'login' => 'user',
        'password' => 'password',
        'database' => 'test_database_name',
        'prefix' => '',
        'encoding' => 'UTF8',
    );
}" > templates/default/database.php.erb

echo "
template node['phpapp']['path'] + '/app/Config/database.php' do
  source \"database.php.erb\"
  mode 0755
  owner \"root\"
  group \"root\"
  variables(
    :database        => node['phpapp']['database'],
    :user            => node['phpapp']['db_username'],
    :password        => node['phpapp']['db_username'])
end" >> recipes/default.rb

cd ../..
chef-solo -c solo.rb -j web.json

cd cookbooks/phpapp
cp /var/www/croogo/app/Config/croogo.php.install templates/default/croogo.php.erb

echo "
template node['phpapp']['path'] + '/app/Config/croogo.php' do
  source \"croogo.php.erb\"
  mode 0755
  owner \"root\"
  group \"root\"
end" >> recipes/default.rb

cd ../..
chef-solo -c solo.rb -j web.json

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

  LogLevel info
  ErrorLog <%= @params[:docroot] %>/error.log
  CustomLog <%= @params[:docroot] %>/access.log combined
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
include_recipe \"git\"

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

directory node['phpapp']['path']  do
  owner \"www-data\"
  group \"www-data\" 
  mode \"0775\"
  recursive true
  action :create
end

git node['phpapp']['path'] do
  repository \"git://github.com/hellofuture/exampleapp.git\"
  reference \"master\"
  action :sync
end

execute 'import croogo structure' do
  command 'mysql -u root --password=' + 
          node['mysql']['server_root_password'] + ' ' +
          node['phpapp']['database'] + ' < ' +
          node['phpapp']['path'] + '/app/Config/Schema/sql/croogo.sql'
  not_if do
    require 'mysql'
    m = Mysql.new('localhost',
                  'root', 
                  node['mysql']['server_root_password'], 
                  node['phpapp']['database'])     
    m.list_tables.include?('acos')
  end
end

execute 'import croogo static data' do
  command 'mysql -u root --password=' + 
          node['mysql']['server_root_password'] + ' ' +
          node['phpapp']['database'] + ' < ' +
          node['phpapp']['path'] + '/app/Config/Schema/sql/croogo_data.sql'
  not_if do
    require 'mysql'
    m = Mysql.new('localhost',
                  'root', 
                  node['mysql']['server_root_password'], 
                  node['phpapp']['database'])     
    begin
      m.query(\"select count(*) from acos\").fetch_row.first.to_i > 0
    ensure
      m.close
    end
  end
end

template node['phpapp']['path'] + '/app/Config/database.php' do
  source \"database.php.erb\"
  mode 0755
  owner \"root\"
  group \"root\"
  variables(
    :database        => node['phpapp']['database'],
    :user            => node['phpapp']['db_username'],
    :password        => node['phpapp']['db_username'])
end

template node['phpapp']['path'] + '/app/Config/croogo.php' do
  source \"croogo.php.erb\"
  mode 0755
  owner \"root\"
  group \"root\"
end

web_app \"phpapp\" do
  template \"site.conf.erb\"
  docroot node['phpapp']['path'] + '/app/webroot'
  server_name node['phpapp']['server_name']
end" > recipes/default.rb

echo "default['phpapp']['server_name'] = \"phpapp\"" >> attributes/default.rb

cd ../..

echo "{
  \"mysql\": {\"server_root_password\": \"808052769e2c6d909027a2905b224bad\", \"server_debian_password\": \"569d1ed2d46870cc020fa87be83af98d\", \"server_repl_password\": \"476911180ee92a2ee5a471f33340f6f4\"},
  \"phpapp\": {\"db_password\": \"212b09752d173876a84d374333ae1ffe\", \"server_name\": \"intro.hellofutu.re\"},
  \"run_list\": [ \"recipe[apt]\", \"recipe[phpapp]\" ]
}" > web.json

chef-solo -c solo.rb -j web.json
