#!/bin/bash

PATH=$PATH:/usr/local/bin
. /usr/local/lib/rvm

DIR=/apps/dliver-server/current
cd $DIR
rvm use 2.1.5
RAILS_ENV=$2 bundle exec rake "$1"
