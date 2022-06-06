#!/bin/bash

# this script is intended to be called from .bashrc
# This is a workaround for not having something like supervisord

if [ ! -e /run/mysqld/gitpod-init.lock ]
then
    touch /run/mysqld/gitpod-init.lock

    # initialize database structures on disk, if needed
    # [ ! -d /workspace/mysql ] && mysqld --initialize-insecure

    # launch database, if not running
    [ ! -e /run/mysqld/mysqld.pid ] && mysqld --daemonize

    rm /run/mysqld/gitpod-init.lock
fi
