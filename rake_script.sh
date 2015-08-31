#!/bin/bash

PATH=$PATH:/usr/local/bin
. /usr/local/lib/rvm

DIR=/data/test/dLiver/current
cd $DIR
rvm use 2.1.5
rake "$1"