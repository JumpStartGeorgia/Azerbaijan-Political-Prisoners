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
set :stage, 'staging'
set :deploy_to, "/home/#{user}/#{application}"
set :full_current_path, "#{deploy_to}/#{current_path}"
set :full_shared_path, "#{deploy_to}/#{shared_path}"
set :repository, "git@github.com:JumpStartGeorgia/Azerbaijan-Political-Prisoners.git"
set :branch, 'master'
set :shared_paths, ['.env', 'log']
set :forward_agent, true

# Puma settings
set :puma_socket, "#{deploy_to}/tmp/puma/sockets/#{application}-puma.sock"
set :puma_pid, "#{deploy_to}/tmp/puma/pid"
set :puma_state, "#{deploy_to}/tmp/puma/state"
set :pumactl_socket, "#{deploy_to}/tmp/puma/sockets/#{application}-pumactl.sock"
set :puma_config, "#{full_current_path}/config/puma.rb"

# Assets settings
set :precompiled_assets_dir, 'public/assets'
set :precompiled_assets_tar, "tmp/#{stage}_assets.tar.gz"


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

  queue! %[mkdir -p "#{deploy_to}/tmp/puma/sockets"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/tmp/puma/sockets"]

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
  queue  %[echo "-----> /etc/init.d/puma (i.e. try running the command '/etc/init.d/puma status')."]
  queue  %[echo ""]
  queue  %[echo "sudo /etc/init.d/puma add #{deploy_to} #{user} #{full_current_path}/config/puma.rb #{full_shared_path}/log/puma.log"]
  queue  %[echo ""]
end

namespace :deploy do
  task :check_revision do
    unless `git rev-parse HEAD` == `git rev-parse origin/#{branch}`
      puts "WARNING: HEAD is not the same as origin/#{branch}"
      puts "Run `git push` to sync changes."
      exit
    end

    unless `git status`.include? 'nothing to commit, working directory clean'
      puts "WARNING: There are uncommitted changes to the local git repository, which"
      puts "may cause problems for locally precompiling assets."
      puts "Please clean local repository with `git stash` or `git reset`."
      exit
    end
  end

  namespace :assets do
    task :check_changed do
      set :assets_changed, false

      # Locations where assets may have changed; check Gemfile.lock to ensure that gem assets are the same
      asset_files_directories = "app/assets vendor/assets Gemfile.lock"

      current_commit = `git rev-parse HEAD`.strip()
      deployed_commit = capture(%[cat #{deploy_to}/scm/FETCH_HEAD]).split(" ")[0]

      git_diff = `git diff --name-only #{deployed_commit}..#{current_commit} #{asset_files_directories}`

      unless git_diff.length == 0
        set :assets_changed, true
      else
        system %[echo "-----> Assets did not change; skipping precompile step"]
      end
    end

    task :local_precompile do
      system %[echo "-----> Cleaning assets locally"]
      system %[bundle exec rake assets:clean RAILS_GROUPS=assets]

      system %[echo "-----> Precompiling assets locally"]
      system %[bundle exec rake assets:precompile RAILS_GROUPS=assets]

      system %[echo "-----> Tarballing assets to #{precompiled_assets_tar}"]
      system %[tar -cvzf #{precompiled_assets_tar} -C #{precompiled_assets_dir} .]

      system %[echo "-----> Moving assets tar file to #{deploy_to}/#{precompiled_assets_tar} on server"]
      system %[scp #{precompiled_assets_tar} #{user}@#{domain}:#{deploy_to}/#{precompiled_assets_tar} && rm #{precompiled_assets_tar}]
    end

    task :unzip do
      queue %[echo "-----> Unzipping assets tar file to #{full_current_path}/public/assets"]
      queue %[mkdir ./public/assets && tar -xvzf #{deploy_to}/#{precompiled_assets_tar} -C ./public/assets]

      queue %[echo "-----> Removing tar file #{deploy_to}/#{precompiled_assets_tar}"]
      queue %[rm #{deploy_to}/#{precompiled_assets_tar}]
    end
  end
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :'deploy:check_revision'
    invoke :'deploy:assets:check_changed'
    invoke :'deploy:assets:local_precompile' if assets_changed
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'deploy:assets:unzip' if assets_changed
    invoke :'deploy:cleanup'

    to :launch do
      queue "mkdir -p #{full_current_path}/tmp/"
      queue "touch #{full_current_path}/tmp/restart.txt"
    end
  end
end