#!/bin/bash

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
LOG_PATH="$SCRIPT_DIR/log"

if [ $# -eq 0 ]; then
    echo "Error: No domain specified for force renew"
    echo "Usage: $0 <domain>"
    echo "Example: $0 example.com"
    exit 1
fi

DOMAIN=$1
echo "force renew for all domain: "$DOMAIN

certbot certonly --manual --force-renewal --preferred-challenges=dns -d "*.$DOMAIN" -d "$DOMAIN" --manual-auth-hook "$SCRIPT_DIR/dnspod.sh | tee -a $LOG_PATH/create_txt.$(date +%Y-%m-%d).log" --manual-cleanup-hook "$SCRIPT_DIR/dnspod.sh clean | tee -a $LOG_PATH/delete_txt.$(date +%Y-%m-%d).log" --deploy-hook "$SCRIPT_DIR/replace_certs_and_reload_service.sh | tee -a $LOG_PATH/reload_service.$(date +%Y-%m-%d).log"

echo "Force renewal completed for $DOMAIN and *.$DOMAIN"

