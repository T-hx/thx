#!/bin/sh

if [ -f ./tmp/pids/server.pid ]; then
    rm ./tmp/pids/server.pid
fi

bundle exec whenever --update-crontab
/etc/init.d/cron start
bundle exec rails s -p 3000 -b 0.0.0.0
