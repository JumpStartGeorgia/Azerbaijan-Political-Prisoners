#require 'mina/multistage'
#require 'mina/nginx'
require 'mina/puma'
require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'

set :rails_env, 'staging'
set :domain, 'alpha.jumpstart.ge'
set :user, 'prisoners-staging'
set :application, 'Azeri-Prisoners-Staging'
set :deploy_to, "/home/#{user}/#{application}"
set :full_current_path, "#{deploy_to}/#{current_path}"
set :full_shared_path, "#{deploy_to}/#{shared_path}"
set :repository, "git@github.com:JumpStartGeorgia/Azerbaijan-Political-Prisoners.git"
set :branch, 'dev'
set :shared_paths, ['.env', 'log']
set :forward_agent, true

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :environment do
  invoke :'rbenv:load'
end

# Put any custom mkdir's in here for   when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :environment do
  queue! %[mkdir -p "#{full_shared_path}/log"]
  queue! %[chmod g+rx,u+rwx "#{full_shared_path}/log"]

  queue! %[mkdir -p "#{deploy_to}/tmp/pids"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/tmp/pids"]

  queue! %[mkdir -p "#{deploy_to}/tmp/sockets"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/tmp/sockets"]

  queue! %[mkdir -p "#{deploy_to}/tmp/puma"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/tmp/puma"]

  invoke :setup_nginx_reminder
  invoke :add_to_puma_jungle_reminder
end

task :setup_nginx_reminder do
  queue  %[echo ""]
  queue  %[echo "-----> Run the following command on your server to create the symlink from the "]
  queue  %[echo "-----> nginx sites-enabled directory to the app's nginx.conf file:"]
  queue  %[echo ""]
  queue  %[echo "sudo ln -nfs #{full_current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"]
  queue  %[echo ""]
end

task :add_to_puma_jungle_reminder do
  queue  %[echo ""]
  queue  %[echo "-----> Run the following command on your server to add your app to the list of puma apps in "]
  queue  %[echo "-----> the file /etc/puma.conf. All apps in this file are automatically started"]
  queue  %[echo "-----> whenever the server is booted up. They can also be controlled with the script "]
  queue  %[echo "-----> /etc/init.d/puma (i.e. try running the command '/etc/init.d/puma status'."]
  queue  %[echo ""]
  queue  %[echo "sudo /etc/init.d/puma add #{deploy_to} #{user} #{full_current_path}/config/puma.rb #{full_shared_path}/log/puma.log"]
  queue  %[echo ""]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'
    invoke :'deploy:cleanup'

    to :launch do
      queue "mkdir -p #{full_current_path}/tmp/"
      queue "touch #{full_current_path}/tmp/restart.txt"
    end
  end
end