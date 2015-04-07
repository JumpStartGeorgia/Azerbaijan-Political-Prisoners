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
set :branch, 'dev'
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

  queue! %[mkdir -p "#{deploy_to}/tmp/assets"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/tmp/assets"]

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
    task :decide_whether_to_precompile do
      set :precompile_assets, false
      if ENV['precompile_assets']
        set :precompile_assets, true
      else
        # Locations where assets may have changed; check Gemfile.lock to ensure that gem assets are the same
        asset_files_directories = "app/assets vendor/assets Gemfile.lock"

        current_commit = `git rev-parse HEAD`.strip()

        # Get deployed commit hash from FETCH_HEAD file
        deployed_commit = capture(%[cat #{deploy_to}/scm/FETCH_HEAD]).split(" ")[0]

        # If FETCH_HEAD file does not exist or deployed_commit doesn't look like a hash, ask user to force precompile
        if deployed_commit == nil || deployed_commit.length != 40
          system %[echo "WARNING: Cannot determine the commit hash of the previous release on the server"]
          system %[echo "If this is your first deploy (or you want to skip this error), deploy like this:"]
          system %[echo ""]
          system %[echo "mina deploy precompile_assets=true"]
          system %[echo ""]
          exit
        else
          git_diff = `git diff --name-only #{deployed_commit}..#{current_commit} #{asset_files_directories}`

          # If git diff length is 0, then the assets are unchanged.
          # If the length is not 0, then one of the following are true:
          #
          # 1) The assets changed and git diff shows those files
          # 2) Git cannot recognize the deployed commit and issues an error
          #
          # In both these situations, precompile assets.
          if git_diff.length == 0
            system %[echo "-----> Assets unchanged; skipping precompile assets"]
          else
            set :precompile_assets, true
          end
        end
      end
    end

    task :local_precompile do
      system %[echo "-----> Cleaning assets locally"]
      system %[bundle exec rake assets:clean RAILS_GROUPS=assets]

      system %[echo "-----> Precompiling assets locally"]
      system %[bundle exec rake assets:precompile RAILS_GROUPS=assets]

      system %[echo "-----> RSyncinc remote assets (tmp/assets) with local assets (#{precompiled_assets_dir})"]
      system %[rsync #{rsync_verbose} --recursive --times ./#{precompiled_assets_dir}/. #{user}@#{domain}:#{deploy_to}/tmp/assets]
    end

    task :copy do
      queue %[echo "-----> Copying assets from tmp/assets to current/#{precompiled_assets_dir}"]
      queue %[cp -a #{deploy_to}/tmp/assets/. ./#{precompiled_assets_dir}]
    end
  end
end

# Custom precompile assets method:
# 1) Determine whether to precompile the assets
#   a) If the flag 'precompile_assets=true' is set, then precompile assets
#   b) Use git to view difference in the assets files between the commit on the server
#      and the commit on the local machine. If there is a difference, precompile assets
#   c) If cannot determine the commit on the server, show error and ask user to run deploy with 'precompile_assets=true'
#   d) If git diff gives an error, precompile assets
#
# 2) If not precompiling assets, skip to step 3. Otherwise...
#   a) precompile assets locally
#   b) sync tmp/assets on server with local precompiled assets
#
# 3) During deploy, copy assets from tmp/assets to current/public/assets

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    if ENV['verbose']
      set :rsync_verbose, "--verbose"
    else
      set :bundle_options, "#{bundle_options} --quiet"
      set :rsync_verbose, ""
    end

    invoke :'deploy:check_revision'
    invoke :'deploy:assets:decide_whether_to_precompile'
    invoke :'deploy:assets:local_precompile' if precompile_assets
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'deploy:assets:copy'
    invoke :'deploy:cleanup'

    to :launch do
      queue "mkdir -p #{full_current_path}/tmp/"
      queue "touch #{full_current_path}/tmp/restart.txt"
    end
  end
end