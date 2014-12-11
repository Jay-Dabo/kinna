#!/bin/bash -x
db_name=$1

if [ "$db_name" == "" ]; then
  db_name='kinna_development'
fi
be='bundle exec'
#be='foreman run'
sudo -u postgres dropdb $db_name && sudo -u postgres createdb $db_name && $be rake db:create && $be rake db:migrate && $be rake db:seed && rm public/system/documents
