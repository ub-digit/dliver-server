#!/bin/bash

PATH=$PATH:/usr/local/bin
. /usr/local/lib/rvm

DIR=/data/$2/dLiver/current
cd $DIR
rvm use 2.1.5
RAILS_ENV=$3 rake "$1"
