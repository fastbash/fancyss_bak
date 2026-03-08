#!/bin/sh


download_by_fancyss(){
    if [ -z "$1" ] || [ -z "$2" ];then
        return 1
    fi
    if download_by_curl "$1" "$2";then
        return 0
    else
        if download_by_wget "$1" "$2";then
            return 0
        # else
        #     if download_by_aria2 "$1" "$2";then
        #         return 0
        #     fi
        fi
    fi
    return 1
}

dnsmasq_rule(){
    # better way todo: resolve first and add ip to ipset:router mannuly
    ACTION="$1"
    DOMAIN="$2"
    if [ -z "$1" ] || [ -z "$2" ];then return 1;fi
    DNSF_PORT=7913
    DOMAIN_FILE=/jffs/configs/dnsmasq.d/ss_domain.conf
    if [ "${ACTION}" = "add" ];then
        if [ ! -f ${DOMAIN_FILE} ] || [ "$(grep -c "${DOMAIN}" ${DOMAIN_FILE})" != "2" ];then
            echo_date "ℹ️添加域名：${DOMAIN} 到本机走代理名单..."
            sed -i "/\/${DOMAIN}\//d" ${DOMAIN_FILE}
            echo "server=/${DOMAIN}/127.0.0.1#$DNSF_PORT" >> ${DOMAIN_FILE}
            echo "ipset=/${DOMAIN}/router" >> ${DOMAIN_FILE}
            sync
            service restart_dnsmasq >/dev/null 2>&1
        fi
    elif [ "${ACTION}" = "remove" ];then
        if [ -f ${DOMAIN_FILE} ];then
            sed -i "/\/${DOMAIN}\//d" ${DOMAIN_FILE}
            sync
            service restart_dnsmasq >/dev/null 2>&1
        fi
    fi
}

download_by_curl(){
    _url="$1"
    _url_file_tmp="$2"

    if [ -f "${_url_file_tmp:?}" ];then
        cd . > "${_url_file_tmp:?}" 2>/dev/null
    fi
    if [ ! -d "${_url_file_tmp%/*}" ];then
        echo_date "⚠️临时文件【${_url_file_tmp}】所在文件夹【${_url_file_tmp%/*}】异常！"
        return 1
    fi
    if ! touch "${_url_file_tmp:?}";then
        echo_date "⚠️临时文件【${_url_file_tmp}】创建失败！"
        return 1
    fi

    CURL_BIN="$(which curl-fancyss)"
    CURL_BIN="curl-fancyss"
    BIN_VER="$CURL_BIN/$($CURL_BIN --version | head -n1 | awk '{print $2}')"
    UA_STRING="${BIN_VER} ${fancyss_agent}"
    _curl_arg="-4sSkL"

    echo_date "ℹ️使用 $BIN_VER"
    echo_date "下载地址： ${_url}"
    echo_date "目标文件： ${_url_file_tmp}"

    _url_encode="$(echo "$_url" | sed 's/[[:space:]]/%20/g')"

    _url_domain="$(echo "$_url" | sed -E 's#^[a-zA-Z]+://([^/:]+).*#\1#')"

    if netstat -nlp 2>/dev/null|grep -w "23456"|grep -Eoq "ss-local|sslocal|v2ray|xray|naive|tuic|clash";then

        echo_date "⬇️尝试通过✈️代理下载..."
        dnsmasq_rule add "${_url_domain}"

        echo_date "1️⃣第一次尝试下载..."
        if run $CURL_BIN ${_curl_arg} -A "$UA_STRING" ${EXT_ARG} -x socks5://127.0.0.1:23456 --connect-timeout 6 "${_url_encode}" 2>/dev/null > "${_url_file_tmp}";then
            if [ "$(wc -c < "${_url_file_tmp}")" -gt 0 ];then
                return 0
            fi
        fi

        echo_date "2️⃣第二次尝试下载..."
        if run $CURL_BIN ${_curl_arg} -A "$UA_STRING" ${EXT_ARG}  -x socks5://127.0.0.1:23456 --connect-timeout 10 "${_url_encode}" 2>/dev/null > "${_url_file_tmp}";then
            if [ "$(wc -c < "${_url_file_tmp}")" -gt 0 ];then
                return 0
            fi
        fi
        echo_date "⚠️下载失败！"
    fi

    echo_date "⬇️使用常规网络下载..."
    dnsmasq_rule remove "${_url_domain}"
    
    echo_date "1️⃣第一次尝试下载..."
    if run $CURL_BIN ${_curl_arg} -A "$UA_STRING" --connect-timeout 6 "${_url_encode}" 2>/dev/null > "${_url_file_tmp}";then
        if [ "$(wc -c < "${_url_file_tmp}")" -gt 0 ];then
            return 0
        fi
    fi
    
    echo_date "2️⃣第二次尝试下载..."
    if run $CURL_BIN ${_curl_arg} -A "$UA_STRING" --connect-timeout 10 "${_url_encode}" 2>/dev/null > "${_url_file_tmp}";then
        if [ "$(wc -c < "${_url_file_tmp}")" -gt 0 ];then
            return 0
        fi
    fi

    echo_date "⚠️下载失败！"
    return 1
}

download_by_wget(){
    _url="$1"
    _url_file_tmp="$2"
    
    if [ -f "${_url_file_tmp:?}" ];then
        cd . > "${_url_file_tmp:?}" 2>/dev/null
    fi
    if [ ! -d "${_url_file_tmp%/*}" ];then
        echo_date "⚠️临时文件【${_url_file_tmp}】所在文件夹【${_url_file_tmp%/*}】异常！"
        return 1
    fi
    if ! touch "${_url_file_tmp:?}";then
        echo_date "⚠️临时文件【${_url_file_tmp}】创建失败！"
        return 1
    fi

    WGET_BIN="$(which wget)"
    WGET_BIN="wget"
    BIN_VER="$WGET_BIN/$($WGET_BIN --version | head -n1 | awk '{print $3}')"
    UA_STRING="${BIN_VER} ${fancyss_agent}"

    echo_date "ℹ️使用 $BIN_VER"
    echo_date "下载地址： ${_url}"
    echo_date "目标文件： ${_url_file_tmp}"
    
    if echo "$1" | grep -qE "^https"; then
        EXT_OPT="--no-check-certificate"
    else
        EXT_OPT=""
    fi
    
    _url_encode=$(echo "$1" | sed 's/[[:space:]]/%20/g')
    
    _url_domain="$(echo "$_url" | sed -E 's#^[a-zA-Z]+://([^/:]+).*#\1#')"

    if netstat -nlp 2>/dev/null|grep -w "3333"|grep -Eoq "ss-local|sslocal|v2ray|xray|naive|tuic|clash";then

        echo_date "⬇️尝试通过✈️代理下载..."
        dnsmasq_rule add "${_url_domain}"

        echo_date "1️⃣第一次尝试下载..."
        if wget -4 -t 1 -T 10 --dns-timeout=5 -q ${EXT_OPT} -e http_proxy=127.0.0.1:3333 -U "$UA_STRING" "${_url_encode}" -O  "${_url_file_tmp}"; then
            if [ "$(wc -c < "${_url_file_tmp}")" -gt 0 ];then
                return 0
            fi
        fi

        echo_date "2️⃣第二次尝试下载..."
        if wget -4 -t 1 -T 15 --dns-timeout=10 -q ${EXT_OPT} -e http_proxy=127.0.0.1:3333 -U "$UA_STRING" "${_url_encode}" -O  "${_url_file_tmp}"; then
            if [ "$(wc -c < "${_url_file_tmp}")" -gt 0 ];then
                return 0
            fi
        fi
    fi

    echo_date "⬇️使用常规网络下载..."
    dnsmasq_rule remove "${_url_domain}"
    
    echo_date "1️⃣第一次尝试下载..."
    if wget -4 -t 1 -T 10 --dns-timeout=5 -q ${EXT_OPT} -U "$UA_STRING" "${_url_encode}" -O  "${_url_file_tmp}"; then
        if [ "$(wc -c < "${_url_file_tmp}")" -gt 0 ];then
            return 0
        fi
    fi

    echo_date "2️⃣第二次尝试下载..."
    if wget -4 -t 1 -T 15 --dns-timeout=10 -q ${EXT_OPT} -U "$UA_STRING" "${_url_encode}" -O  "${_url_file_tmp}"; then
        if [ "$(wc -c < "${_url_file_tmp}")" -gt 0 ];then
            return 0
        fi
    fi    

    echo_date "⚠️下载失败！"
    return 1
}

download_by_aria2(){
    _url="$1"
    _url_file_tmp="$2"
    aria2_bin=/koolshare/aria2/aria2c
    if [ ! -f $aria2_bin ];then return 1;fi
    
    if [ -f "${_url_file_tmp:?}" ];then
        cd . > "${_url_file_tmp:?}"
    fi
    if [ ! -d "${_url_file_tmp%/*}" ];then
        echo_date "⚠️临时文件【${_url_file_tmp}】所在文件夹【${_url_file_tmp%/*}】异常！"
        return 1
    fi

    echo_date "ℹ️使用 aria2c 下载【${_url}】"

    _url_domain="$(echo "$_url" | sed -E 's#^[a-zA-Z]+://([^/:]+).*#\1#')"

    echo_date "⬇️尝试通过✈️代理下载..."
    dnsmasq_rule add "${_url_domain}"
    if $aria2_bin --check-certificate=false --quiet=true -d "${_url_file_tmp%/*}" -o "${_url_file_tmp##*/}" "$1";then
        if [ "$(wc -c < "${_url_file_tmp}")" -gt 0 ];then
            return 0
        fi
    fi

    echo_date "⬇️使用常规网络下载..."
    dnsmasq_rule remove "${_url_domain}"
    if $aria2_bin --check-certificate=false --quiet=true -d "${_url_file_tmp%/*}" -o "${_url_file_tmp##*/}" "$1";then
        if [ "$(wc -c < "${_url_file_tmp}")" -gt 0 ];then
            return 0
        fi
    fi

    echo_date "⚠️下载失败！"
    return 1
}