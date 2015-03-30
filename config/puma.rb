#!/usr/bin/env puma

directory '/home/prisoners-staging/Azeri-Prisoners-Staging/current'
rackup "/home/prisoners-staging/Azeri-Prisoners-Staging/current/config.ru"
environment 'staging'

pidfile "/home/prisoners-staging/Azeri-Prisoners-Staging/tmp/puma/pid"
state_path "/home/prisoners-staging/Azeri-Prisoners-Staging/tmp/puma/state"
activate_control_app

stdout_redirect '/home/prisoners-staging/Azeri-Prisoners-Staging/shared/log/puma.error.log', '/home/prisoners-staging/Azeri-Prisoners-Staging/shared/log/puma.access.log', true



threads 4,16

bind 'unix:///home/prisoners-staging/Azeri-Prisoners-Staging/tmp/sockets/Azeri-Prisoners-Staging-puma.sock'
workers 1



preload_app!