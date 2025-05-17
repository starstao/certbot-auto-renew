#!/bin/bash

set -e

echo `date -d "+8 hours" "+%Y-%m-%d %H:%M:%S: "`"cp all certs"
rsync -avPL /etc/letsencrypt/live/ /opt/ssl/certs/

echo `date -d "+8 hours" "+%Y-%m-%d %H:%M:%S: "`"reload service"
cd /opt/nginx/ && docker compose stop && docker compose start
