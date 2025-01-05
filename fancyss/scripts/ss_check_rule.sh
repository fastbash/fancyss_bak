#!/bin/sh

# fancyss script for asuswrt/merlin based router with software center

. /koolshare/scripts/ss_base.sh
eval "$(dbus export ss_)"



check_rule(){
    if [ ! -f /jffs/.koolshare/scripts/ss_base.sh ];then echo_date 'ssr plugin is not exsit!';return 1;fi
    domain="$1"
    echo_date "domain: $domain"
    dnsPort=$(find /jffs/configs/dnsmasq.d/ -name "*" -exec grep -w "$domain" {} \; 2>/dev/null | grep -w 'server=' | awk -F'#' '{print $2}' | head -n1)
    if [ "$ss_basic_mode" = 1 ];then #gfwlist
        echo_date "当前模式: gfwlist"
        if [ "$dnsPort" = "" ];then
            echo_date "该域名不在gfwlist文件中"
            dnsPort=53
        elif [ "$dnsPort" = "7913" ];then
            echo_date "该域名存在gfwlist文件中"
        fi
    elif [ "$ss_basic_mode" = 2 ];then #whitelist
        echo_date "当前模式: 白名单"
        if [ "$dnsPort" = "53" ];then #in cdnlist
            echo_date "该域名存在白名单文件中"
        elif [ "$dnsPort" = "" ];then #not in cdnlist
            dnsPort=7913
            echo_date "该域名不在白名单文件中"
        fi
    else
        echo_date "该域名直连不使用代理"
    fi
    # check chnroute, get domain ip
    if [ "$dnsPort" != "" ];then
        tmp_ip=$(nslookup "$domain" "127.0.0.1:$dnsPort" | grep 'Address 1:' | tail -n1 | awk '{print $3}')
        if echo "$tmp_ip" | grep -qE '^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$';then #is a ip address
            if ipset list | grep -q chnroute;then #confirm ipset chnroute is exsit
                if ipset test chnroute "$tmp_ip";then # direct
                    echo_date "域名解析地址直连不使用代理"
                else # proxy
                    echo_date "域名解析地址使用代理"
                fi 
            else
                echo_date "ip名单文件不存在！"
            fi
        else
            echo_date "解析域名 $domain 失败！"
        fi
    fi
}
true > /tmp/upload/ss_log.txt
http_response "$1"
{ echo_date "==================================================================="
echo_date "rule check"
echo_date "==================================================================="
#echo $* >> /tmp/upload/ss_log.txt
check_rule "$2" >> /tmp/upload/ss_log.txt
echo XU6J03M6 >> /tmp/upload/ss_log.txt
} >> /tmp/upload/ss_log.txt

#if [ "$1" != "" ];then check_rule "$1";fi