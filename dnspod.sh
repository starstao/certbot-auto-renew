#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# 凭据
SEC_FILE="$SCRIPT_DIR/dnspod.env"
if [ -f "${SEC_FILE}" ]; then
    source "${SEC_FILE}"
else
    echo "ERROR: Missing credential file ${SEC_FILE}" >&2
    exit 1
fi


# 临时文件路径，用于存储 RecordId
RECORD_FILE="/tmp/_acme-challenge.${CERTBOT_DOMAIN}_${CERTBOT_VALIDATION}.record"

# 检查必要的环境变量
if [ -z "${secretId}" ] || [ -z "${secretKey}" ]; then
    echo "Error: secretId and secretKey environment variables are required!" 1>&2
    exit 1
fi

if [ -z "${CERTBOT_DOMAIN}" ] || [ -z "${CERTBOT_VALIDATION}" ]; then
    echo "Error: CERTBOT_DOMAIN and CERTBOT_VALIDATION environment variables are required!" 1>&2
    exit 1
fi

if [ "$1" = "clean" ]; then
    echo `date -d "+8 hours" "+%Y-%m-%d %H:%M:%S: "`"start delete TXT for domain "${CERTBOT_DOMAIN}
    # 清理模式 - 删除 DNS 记录
    if [ -f "${RECORD_FILE}" ]; then
        RECORD_ID=$(cat "${RECORD_FILE}")
        if [ -n "${RECORD_ID}" ]; then
            docker run --rm tencentcom/tencentcloud-cli dnspod DeleteRecord \
                --cli-unfold-argument \
                --secretId "${secretId}" \
                --secretKey "${secretKey}" \
                --Domain "${CERTBOT_DOMAIN}" \
                --RecordId "${RECORD_ID}"
        fi
        rm -f "${RECORD_FILE}"
    fi
else
    echo `date -d "+8 hours" "+%Y-%m-%d %H:%M:%S: "`"start create TXT for domain "${CERTBOT_DOMAIN}
    # 创建模式 - 添加 TXT 记录
    RESPONSE=$(docker run --rm tencentcom/tencentcloud-cli dnspod CreateTXTRecord \
        --cli-unfold-argument \
        --secretId "${secretId}" \
        --secretKey "${secretKey}" \
        --Domain "${CERTBOT_DOMAIN}" \
        --SubDomain "_acme-challenge" \
        --Value "${CERTBOT_VALIDATION}" \
        --RecordLine "默认")

    # 提取 RecordId 并保存到文件
    RECORD_ID=$(echo "${RESPONSE}" | grep -o '"RecordId":[[:space:]]*[0-9]*' | grep -o '[0-9]*')
    if [ -n "${RECORD_ID}" ]; then
        echo "${RECORD_ID}" > "${RECORD_FILE}"
    else
        echo "Error: Failed to create DNS record" 1>&2
        echo "${RESPONSE}" 1>&2
        exit 1
    fi

    echo `date -d "+8 hours" "+%Y-%m-%d %H:%M:%S: "`"wait 30 second..."
    # 等待 DNS 记录传播
    sleep 30
fi

