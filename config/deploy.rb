# config valid only for current version of Capistrano
lock '3.4.0'

server 'alpha.jumpstart.ge', roles: [:web, :app, :db], primary: true
set :app_url, 'dev-prisoners.jumpstart.ge'

set :rails_env, :staging
set :user, "prisoners-staging"
set :application, "Azeri-Prisoners-Staging"
set :github_account_name, "JumpStartGeorgia"
set :github_repo_name, "Azerbaijan-Political-Prisoners"
set :repo_url, "git@github.com:#{fetch(:github_account_name)}/#{fetch(:github_repo_name)}.git"
set :branch, "master"
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
set :keep_releases, 2
after "deploy", "deploy:cleanup" # remove the old releases

## Defaults:
# set :scm,           :git
# set :format,        :pretty
# set :log_level,     :debug

## Linked Files & Directories (Default None):
set :linked_files, %w{.env}
set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets public/system}

## Configuring Nginx
# set :nginx_sudo_paths, [:nginx_log_path, :nginx_sites_enabled_dir, :nginx_sites_available_dir]
# set :nginx_sudo_tasks, ['nginx:start', 'nginx:stop', 'nginx:restart', 'nginx:reload', 'nginx:configtest', 'nginx:site:add', 'nginx:site:disable', 'nginx:site:enable', 'nginx:site:remove' ]
set :nginx_sudo_paths, []
set :nginx_sudo_tasks, []
set :nginx_config_name, fetch(:application)
set :nginx_server_name, fetch(:app_url)

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{fetch(:deploy_to)}/shared/tmp/sockets -p"
      execute "mkdir #{fetch(:deploy_to)}/shared/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :nginx do
  namespace :site do
    Rake::Task["enable"].clear_actions
    task :enable do
      on roles(:app) do
        sudo "ln -nfs #{fetch(:deploy_to)}/current/config/nginx.conf /etc/nginx/sites-enabled/#{fetch(:application)}"
      end
    end
  end
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/#{fetch(:branch)}`
        puts "WARNING: HEAD is not the same as origin/#{fetch(:branch)}"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end

  desc 'Setup symlink in nginx sites-enabled directory'
  task :setup_nginx do
    on roles(:app) do
      invoke 'nginx:site:enable'
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
  after  :finishing,    :setup_nginx
  after  :finishing,    :compile_assets
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end

# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma