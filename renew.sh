#!/bin/bash

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
LOG_PATH="$SCRIPT_DIR/log"

echo "renew for all domain: "
certbot renew --manual --preferred-challenges=dns --manual-auth-hook "$SCRIPT_DIR/dnspod.sh | tee -a $LOG_PATH/create_txt.$(date +%Y-%m-%d).log" --manual-cleanup-hook "$SCRIPT_DIR/dnspod.sh clean | tee -a $LOG_PATH/delete_txt.$(date +%Y-%m-%d).log" --deploy-hook "$SCRIPT_DIR/replace_certs_and_reload_service.sh | tee -a $LOG_PATH/reload_service.$(date +%Y-%m-%d).log"

