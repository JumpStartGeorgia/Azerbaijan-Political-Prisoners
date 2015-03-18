# config valid only for current version of Capistrano
lock '3.4.0'
#
#set :stage, :staging
#
#
#set :application, "Azeri-Prisoners-Staging"
##set :stages, %w(production staging)
#
#
#server "alpha.jumpstart.ge ", roles: %w{app web}
#set :user, "prisoners-staging"
#
#set :github_account_name, "JumpStartGeorgia"
#set :github_repo_name, "Azerbaijan-Political-Prisoners"
#set :repo_url, "git@github.com:#{fetch(:github_account_name)}/#{fetch(:github_repo_name)}.git"
#set :scm, "git"
#set :branch, "master"
#
#set :deploy_to, "/home/#{fetch(:user)}/#{fetch(:application)}"
#
#set :pty, true
#set :format, :pretty
#set :log_level, :debug
#
#set :keep_releases, 2
#after "deploy", "deploy:cleanup" # remove the old releases
#
## Default value for :linked_files is []
## set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')
#
## Default value for linked_dirs is []
## set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
#
## Default value for default_env is {}
## set :default_env, { path: "/opt/ruby/bin:$PATH" }
#
#namespace :deploy do
#
#  after :restart, :clear_cache do
#    on roles(:web), in: :groups, limit: 3, wait: 10 do
#      # Here we can do anything such as:
#      # within release_path do
#      #   execute :rake, 'cache:clear'
#      # end
#    end
#  end
#
#end
#
#
#### FROM BOOTSTRAP STARTER PROJECT
##require "bundler/capistrano" # Load Bundler's capistrano plugin.
##set :deploy_via, :remote_cache
##set :use_sudo, false
#

server 'alpha.jumpstart.ge ', roles: [:web, :app, :db], primary: true

set :github_account_name, "JumpStartGeorgia"
set :github_repo_name, "Azerbaijan-Political-Prisoners"
set :repo_url, "git@github.com:#{fetch(:github_account_name)}/#{fetch(:github_repo_name)}.git"
set :branch, "dev"
set :application, "Azeri-Prisoners-Staging"
set :user, "prisoners-staging"
set :puma_threads,    [4, 16]
set :puma_workers,    0

# rbenv
set :rbenv_type, :user
set :rbenv_ruby, File.read('.ruby-version').strip

# Don't change these unless you know what you're doing
set :pty,             true
set :use_sudo,        false
set :stage,           :staging
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, false  # Change to true if using ActiveRecord

## Defaults:
# set :scm,           :git
# set :branch,        :master
# set :format,        :pretty
# set :log_level,     :debug
# set :keep_releases, 5

## Linked Files & Directories (Default None):
# set :linked_files, %w{config/database.yml}
# set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  before :starting,     :check_revision
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end

# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma