#!/bin/sh

# fancyss script for asuswrt/merlin based router with software center
error_=0
source_files="/koolshare/scripts/base.sh /koolshare/scripts/ss_download.sh"
for file in $source_files;do
    if [ ! -f "$file" ];then
        echo "missing file ${file##*/}"
        error=1
    else
        . "$file"
    fi
done
if [ "$error" = "1" ];then
    exit 1
fi

NEW_PATH=$(echo $PATH|tr ':' '\n'|sed '/opt/d;/mmc/d'|awk '!a[$0]++'|tr '\n' ':'|sed '$ s/:$//')
export PATH="$NEW_PATH"
LC_ALL=C
LANG=C
LOCK_FILE=/var/lock/online_update.lock
LOG_FILE=/tmp/upload/ss_log.txt
DIR="/tmp/fancyss_subs"
LOCAL_NODES_SPL="$DIR/ss_nodes_spl.txt"
LOCAL_NODES_BAK="$DIR/ss_nodes_bak.txt"
NODES_SEQ=$(dbus list ssconf_basic_name_ | sed -n 's/^.*_\([0-9]\+\)=.*/\1/p' | sort -n)
NODE_INDEX=$(echo "$NODES_SEQ" | sed 's/.*[[:space:]]//')
SUB_MODE=$(dbus get ssr_subscribe_mode)
HY2_UP_SPEED=$(dbus get ss_basic_hy2_up_speed)
HY2_DL_SPEED=$(dbus get ss_basic_hy2_dl_speed)
HY2_TFO_SWITCH=$(dbus get ss_basic_hy2_tfo_switch)
CURR_NODE=$(dbus get ssconf_basic_node)
KEY_WORDS_1=$(dbus get ss_basic_exclude | sed 's/,$//g' | sed 's/,/|/g')
KEY_WORDS_2=$(dbus get ss_basic_include | sed 's/,$//g' | sed 's/,/|/g')
alias urldecode='sed "s@+@ @g;s@%@\\\\x@g" | xargs -0 printf "%b"'

model=$(nvram get model | tr -d '\r')
fancyss=$(dbus get ss_basic_version_local | tr -d '\r')
softcenter=$(dbus get softcenter_version | tr -d '\r')

# 20230701, some vairiable should be unset
unset usb2jffs_time_hour
unset usb2jffs_week
unset usb2jffs_title
unset usb2jffs_day
unset usb2jffs_rsync
unset usb2jffs_sync
unset usb2jffs_inter_day
unset usb2jffs_inter_pre
unset usb2jffs_version
unset usb2jffs_mount_path
unset usb2jffs_inter_hour
unset usb2jffs_time_min
unset usb2jffs_inter_min
unset usb2jffs_backupfile_name
unset usb2jffs_backup_file
unset usb2jffs_mtd_jffs
unset usb2jffs_warn_2
unset ACTION
unset DEVICENAME
unset DEVNAME
unset DEVPATH
unset DEVTYPE
unset INTERFACE
unset PRODUCT
unset USBPORT
unset SUBSYSTEM
unset SEQNUM
unset MAJOR
unset MINOR
unset PERP_SVPID
unset SHLVL
unset TERM
unset PERP_BASE
unset HOME
unset PWD

# 一个节点里可能有的所有信息，记录用
# ssconf_basic_name_
# ssconf_basic_server_
# ssconf_basic_mode_
# ssconf_basic_method_
# ssconf_basic_password_
# ssconf_basic_port_
# ssconf_basic_ss_obfs_
# ssconf_basic_ss_obfs_host_
# ssconf_basic_ss_v2ray_
# ssconf_basic_ss_v2ray_opts_
# ssconf_basic_rss_obfs_
# ssconf_basic_rss_obfs_param_
# ssconf_basic_rss_protocol_
# ssconf_basic_rss_protocol_param_
# ssconf_basic_koolgame_udp_
# ssconf_basic_use_kcp_
# ssconf_basic_use_lb_
# ssconf_basic_lbmode_
# ssconf_basic_weight_
# ssconf_basic_group_
# ssconf_basic_v2ray_use_json_
# ssconf_basic_v2ray_uuid_
# ssconf_basic_v2ray_alterid_
# ssconf_basic_v2ray_security_
# ssconf_basic_v2ray_network_
# ssconf_basic_v2ray_headtype_tcp_
# ssconf_basic_v2ray_headtype_kcp_
# ssconf_basic_v2ray_kcp_seed
# ssconf_basic_v2ray_headtype_quic_
# ssconf_basic_v2ray_grpc_mode_
# ssconf_basic_v2ray_network_path_
# ssconf_basic_v2ray_network_host_
# ssconf_basic_v2ray_network_security_
# ssconf_basic_v2ray_network_security_ai_
# ssconf_basic_v2ray_network_security_alpn_h2_
# ssconf_basic_v2ray_network_security_alpn_http_
# ssconf_basic_v2ray_network_security_sni_
# ssconf_basic_v2ray_mux_enable_
# ssconf_basic_v2ray_mux_concurrency_
# ssconf_basic_v2ray_json_
# ssconf_basic_xray_use_json_
# ssconf_basic_xray_uuid_
# ssconf_basic_xray_alterid_
# ssconf_basic_xray_prot_
# ssconf_basic_xray_encryption_
# ssconf_basic_xray_flow_
# ssconf_basic_xray_network_
# ssconf_basic_xray_headtype_tcp_
# ssconf_basic_xray_headtype_kcp_
# ssconf_basic_xray_kcp_seed
# ssconf_basic_xray_headtype_quic_
# ssconf_basic_xray_grpc_mode_
# ssconf_basic_xray_network_path_
# ssconf_basic_xray_network_host_
# ssconf_basic_xray_network_security_
# ssconf_basic_xray_network_security_ai_
# ssconf_basic_xray_network_security_alpn_h2_
# ssconf_basic_xray_network_security_alpn_http_
# ssconf_basic_xray_network_security_sni_
# ssconf_basic_xray_fingerprint_
# ssconf_basic_xray_show_
# ssconf_basic_xray_publickey_
# ssconf_basic_xray_shortid_
# ssconf_basic_xray_spiderx_
# ssconf_basic_xray_json_
# ssconf_basic_trojan_ai_
# ssconf_basic_trojan_uuid_
# ssconf_basic_trojan_sni_
# ssconf_basic_trojan_tfo_
# ssconf_basic_naive_prot_
# ssconf_basic_naive_server_
# ssconf_basic_naive_port_
# ssconf_basic_naive_user_
# ssconf_basic_naive_pass_
# ssconf_basic_tuic_json_
# ssconf_basic_hy2_server_
# ssconf_basic_hy2_port_
# ssconf_basic_hy2_pass_
# ssconf_basic_hy2_obfs_
# ssconf_basic_hy2_obfs_pass_
# ssconf_basic_hy2_up_
# ssconf_basic_hy2_dl_
# ssconf_basic_hy2_sni_
# ssconf_basic_hy2_tfo_
# ssconf_basic_type_

# 方案
# 设计：通过操作文件实现节点的订阅
# 1.    skipdb2json：订阅前将节点信息导出到文件，通过sed等操作将其转换为一个节点一行的压缩json格式的节点文件：fancyss_nodes_old_spl.txt，如果有有200个节点就是200行json
# 2.    nodes2files：根据节点中的link_hash信息，将节点文件拆分为多个，usr.txt (用户节点)， local_1_xxxx.txt (机场xxxx)， local_2_yyyy.txt (机场xxxx)
# 3.    nodes_stats：用拆分文件统计节点信息
# 4.    remove_null：订阅钱检测下是否有机场不再订阅（用户删除了这个机场的url）
# 5.    下载订阅
# 6.    解析订阅
# 7.    解析节点
# 8.        过滤节点
# 9.        点写入更新文件
# 10.     对比更新文件和本地节点文件
# 11.     写入/不写入节点
# 12.    

# 7. 最后改写key的顺序，写入dbus
# 8. 如果节点数量变少了，那么还需要掐尾去尾巴
# 优点：删除节点，节点排序很方便！

set_lock(){
    exec 233>"${LOCK_FILE}"
    flock -n 233 || {
        PID1=$$
        PID2=$(ps | grep -w "ss_online_update.sh" | grep -vw "grep" | grep -vw "${PID1}")
        if [ -n "${PID2}" ];then
            echo_date "订阅脚本已经在运行，请稍候再试！"
            exit 1            
        else
            rm -rf ${LOCK_FILE:?}
        fi
    }
}

unset_lock(){
    flock -u 233
    rm -rf "${LOCK_FILE}"
}

count_start(){
    # opkg install coreutils-date
    _start=$(/opt/bin/date +%s.%6N)
    _start0="${_start}"
    counter=0
    echo_date ------------------
    echo_date - 0.000000
}

count_time(){
    # opkg install coreutils-date
    _end=$(/opt/bin/date +%s.%6N)
    runtime=$(awk "BEGIN { x = ${_end}; y = ${_start}; print (x - y) }")
    counter=$((counter+1))
    echo_date + $counter $runtime
    _start=${_end}
}

count_total(){
    # opkg install coreutils-date
    _end=$(/opt/bin/date +%s.%6N)
    runtime=$(awk "BEGIN { x = ${_end}; y = ${_start0}; print (x - y) }")
    counter=$((counter+1))
    echo_date - $runtime
    echo_date ------------------
}

run(){
    env -i PATH=${PATH} "$@"
}

json_init(){
    #true >/tmp/node_data.txt
    NODE_DATA="{"
}

json_add_string(){
    if [ -n "$2" ];then
        NODE_DATA="${NODE_DATA}\"$1\":\"$2\","
    fi
}

json_write_object(){
    echo "$NODE_DATA" | sed '$ s/,$/}/g' >> "$1"
}

__valid_ip() {
    # 验证是否为ipv4或者ipv6地址，是则正确返回，不是返回空值
    format_4=$(echo "$1" | grep -Eo "([0-9]{1,3}[\.]){3}[0-9]{1,3}$")
    if [ -n "${format_4}" ]; then
        echo "${format_4}"
        return 0
    else
        echo ""
        return 1
    fi
}

dec64(){
    # echo -n "${link}" | sed 's/$/====/' | grep -o "...." | sed '${/====/d}' | tr -d '\n' | base64 -d
    echo -n "${1}===" | sed 's/-/+/g;s/_/\//g' | base64 -d 2>/dev/null
    return $?
}

json2skipd(){
    file_name=$1
    cat > "$DIR/${file_name}.sh" <<-EOF
        #!/bin/sh
        source /koolshare/scripts/base.sh
        #------------------------
EOF
    NODE_INDEX=$(dbus list ssconf_basic_name_ | sed -n 's/^.*_\([0-9]\+\)=.*/\1/p' | sort -rn | sed -n '1p')
    [ -z "${NODE_INDEX}" ] && NODE_INDEX="0"
    count=$((NODE_INDEX + 1))
    while read -r nodes; do
        echo ${nodes} | sed 's/\",\"/\"\n\"/g;s/^{//;s/}$//' | sed 's/^\"/dbus set ssconf_basic_/g' | sed "s/\":/_${count}=/g" >> "$DIR/${file_name}.sh"
        count=$((count+1))
    done < "$DIR/${file_name}.txt"
    #echo dbus save ssconf >>$DIR/${file_name}.sh
    chmod +x "$DIR/${file_name}.sh"
    sh "$DIR/${file_name}.sh"
    echo_date "🆗节点信息写入成功！"
    sync
}

skipdb2json(){
    if [ "${SEQ_NU}" = "0" ];then
        return
    fi
    echo_date "➡️开始整理本地节点到文件，请稍等..."
    # 将所有节点数据储存到文件，顺便清理掉空值的key
    dbus list ssconf_basic_ | grep -E "_[0-9]+=" | sed '/^ssconf_basic_.\+_[0-9]\+=$/d' | sed 's/^ssconf_basic_//' > "${DIR}/ssconf_keyval.txt"
    NODES_SEQ=$(cat ${DIR}/ssconf_keyval.txt | sed -n 's/name_\([0-9]\+\)=.*/\1/p'| sort -n)
    for nu in ${NODES_SEQ}
    do
        # cat ssconf_keyval.txt |grep _2=|sed "s/_2=/\":\"/"|sed 's/^/"/;s/$/\"/;s/$/,/g;1 s/^/{/;$ s/,$/}/'| tr -d '\n' |sed 's/$/\n/'
        cat ${DIR}/ssconf_keyval.txt | grep "_${nu}=" | sed "s/_${nu}=/\":\"/" | sed 's/^/"/;s/$/\"/;s/$/,/g;1 s/^/{/;$ s/,$/}/' | tr -d '\n' | sed 's/$/\n/' >>${LOCAL_NODES_SPL}
    done
    if [ -f "${LOCAL_NODES_SPL}" ];then
        echo_date "📁所有本地节点成功整理到文件：${LOCAL_NODES_SPL}"
        cp -rf ${LOCAL_NODES_SPL} ${LOCAL_NODES_BAK}
    else
        echo_date "⚠️节点文件处理失败！请重启路由器后重试！"
        exit 1
    fi
}

nodes2files(){
    if [ "${SEQ_NU}" = "0" ];then
        return
    fi
    rm -rf $DIR/local_*.txt
    SP_NAME
    SP_NUBS
    SP_COUN=0
    SP_STAT=$(cat ${LOCAL_NODES_SPL} | run jq -rc '.group' | awk -F "_" '{print $NF}'|uniq -c|sed 's/^[[:space:]]\+//g' | sed 's/[[:space:]]/|/g')
    for SP_LINE in ${SP_STAT}
    do
        SP_NAME=$(echo "${SP_LINE}" | awk -F"|" '{print $2}')
        SP_NUBS=$(echo "${SP_LINE}" | awk -F"|" '{print $1}')
        if [ "${SP_NAME}" = "null" ] || [ -z "${SP_NAME}" ];then
            # echo_date "📂拆分：local_0_user.txt，共计${SP_NUBS}个节点！"
            sed -n "1,${SP_NUBS}p" ${LOCAL_NODES_SPL} >>$DIR/local_0_user.txt
        else
            EXIST_FILE=$(ls -l $DIR/local_*_${SP_NAME}.txt 2>/dev/null)
            if [ -n "${EXIST_FILE}" ];then
                EXIST_NU=$(echo "$EXIST_FILE"|head -n1|awk -F "/" '{print $NF}'|awk -F "_" '{print $2}')
                # echo_date "📂拆分：local_${EXIST_NU}_${SP_NAME}.txt，共计${SP_NUBS}个节点！"
                sed -n "1,${SP_NUBS}p" ${LOCAL_NODES_SPL} >>"$DIR/local_${EXIST_NU}_${SP_NAME}.txt"
            else
                SP_COUN=$((SP_COUN+1))
                # echo_date "📂拆分：local_${SP_COUN}_${SP_NAME}.txt，共计${SP_NUBS}个节点！"
                sed -n "1,${SP_NUBS}p" ${LOCAL_NODES_SPL} >>"$DIR/local_${SP_COUN}_${SP_NAME}.txt"
            fi
        fi
        sed -i "1,${SP_NUBS}d" ${LOCAL_NODES_SPL}
    done

    if [ "$(wc -c < "${LOCAL_NODES_SPL}")" != "0" ];then
        echo_date "⚠节点文件处理失败！请重启路由器后重试！"
        exit 1
    fi
}

nodes_stats(){
    echo_date "-----------------------------------"
    GROP
    NUBS
    TTNODE=$(cat ${LOCAL_NODES_BAK} 2>/dev/null| wc -l)
    NFILES=$(find $DIR -name "local_*.txt" | sort -n)
    if [ -n "${NFILES}" ];then
        echo_date "📢当前节点统计信息：共有节点${TTNODE}个，其中："
        for file in ${NFILES}
        do
            GROP=$(cat "$file" | run jq -c '.group' | sed 's/""/null/;s/^"//;s/"$//;s/_\w\+$//' | sort -u | sed 's/$/ + /g' | sed ':a;N;$!ba;s#\n##g' | sed 's/ + $//g')
            NUBS=$(wc -l < "$file")
            if [ "${GROP}" = "null" ];then
                GROP_NAME="😛【用户自添加】节点"
            else
                GROP_NAME="🚀【${GROP}】机场节点"
            fi
            echo_date ${GROP_NAME}: ${NUBS}个
        done
    else
        echo_date "📢当前尚无任何节点...继续！"
    fi
    echo_date "-----------------------------------"
}

remove_null(){
    if [ "${SEQ_NU}" = "0" ];then
        # 没有节点，不进行检查
        return
    fi
    if [ "$(dbus list ssconf_ | grep -c _group)" = "0" ];then
        # 没有订阅节点，不进行检查
        return
    fi
    online_sub_urls=$(dbus get ss_online_links | base64 -d | sed '/^$/d' | sed '/^#/d'| sed 's/^[[:space:]]//g' | sed 's/[[:space:]]&//g' | grep -E "^http" | sed 's/[[:space:]]/%20/g')
    for online_sub_url in ${online_sub_urls}
    do
        sublink_hash=$(echo "${online_sub_url}" | sed 's/%20/ /g' | md5sum | awk '{print $1}')
        echo "${sublink_hash:0:4}" >> $DIR/sublink_hash.txt
    done

    local_hashs=$(find $DIR -name "local_*.txt" | sort -n | xargs cat | run jq -r '.group' | awk -F "_" '{print $NF}' | grep -v "null" | sort -u)
    for local_hash in $local_hashs
    do
        match_hash=$(cat $DIR/sublink_hash.txt | grep -Eo "${local_hash}")
        if [ -z "${match_hash}" ];then
            # remove node
            _local_group=$(cat $DIR/local_*_${local_hash}.txt | run jq -rc '.group' | sed 's/_.*$//' | sort -u | sed 's/$/ + /g' | sed ':a;N;$!ba;s#\n##g' | sed 's/ + $//g')
            echo_date "⚠️检测到【${_local_group}】机场已经不再订阅！尝试删除该订阅的节点！"
            rm -rf $DIR/local_*_${local_hash}.txt
        fi
    done
}

clear_nodes(){
    # 写入节点钱需要清空所有ssconf配置
    if [ "${SEQ_NU}" = "0" ];then
        return
    fi
    echo_date "⌛节点写入前准备..."
    dbus list ssconf_basic_|awk -F "=" '{print "dbus remove "$1}' >$DIR/ss_nodes_remove.sh
    chmod +x $DIR/ss_nodes_remove.sh
    sh $DIR/ss_nodes_remove.sh
    sync
    [ -n "${CURR_NODE}" ] && dbus set ssconf_basic_node=$CURR_NODE
    echo_date "🆗准备完成！"
}

# 清除已有的所有旧配置的节点
remove_all_node(){
    echo_date "删除所有节点信息！"
    confs=$(dbus list ssconf_basic_ | cut -d "=" -f1 | awk '{print $NF}')
    for conf in ${confs}
    do
        #echo_date "移除配置：${conf}"
        dbus remove "${conf}"
    done
    # remove group name
    for conf1 in $(dbus list ss_online_group|awk -F"=" '{print $1}')
    do
        dbus remove "${conf1}"
    done

    # remove group hash
    for conf2 in $(dbus list ss_online_hash|awk -F"=" '{print $1}')
    do
        dbus remove "${conf2}"
    done
    echo_date "删除成功！"
}

# 删除所有订阅节点
remove_sub_node(){
    echo_date "删除所有订阅节点信息...自添加的节点不受影响！"
    #remove_node_info
    remove_nus=$(dbus list ssconf_basic_group_ | sed -n 's/ssconf_basic_group_\([0-9]\+\)=.\+$/\1/p' | sort -n)
    if [ -z "${remove_nus}" ]; then
        echo_date "节点列表内不存在任何订阅来源节点，退出！"
        return 1
    fi

    for remove_nu in ${remove_nus}
    do
        echo_date "移除第$remove_nu节点：【$(dbus get ssconf_basic_name_${remove_nu})】"
        dbus list ssconf_basic_|grep "_${remove_nu}="|sed -n 's/\(ssconf_basic_\w\+\)=.*/\1/p' |  while read -r key
        do
            dbus remove "$key"
        done
    done

    echo_date "所有订阅节点信息已经成功删除！"
}

check_nodes(){
    if [ "${SEQ_NU}" = "0" ];then
        return
    fi
    mkdir -p ${DIR}
    BACKUP_FILE=${DIR}/ss_conf.sh
    echo_date "➡️开始节点数据检查..."
    ADJUST=0
    MAX_NU=${NODE_INDEX}
    dbus list ssconf_basic_ | grep -E "_[0-9]+=" > ${DIR}/ssconf_keyval_origin.txt
    KEY_NU=$(wc -l < ${DIR}/ssconf_keyval_origin.txt)
    VAL_NU=$(cat ${DIR}/ssconf_keyval_origin.txt | cut -d "=" -f2 | sed '/^$/d' | wc -l)
    echo_date "ℹ️最大节点序号：${MAX_NU}"
    echo_date "ℹ️共有节点数量：${SEQ_NU}"

    # 如果[节点数量 ${SEQ_NU}]不等于[最大节点序号 ${MAX_NU}]，说明节点排序是不正确的。
    if [ ${SEQ_NU} -ne ${MAX_NU} ]; then
        ADJUST=1
        echo_date "⚠️节点顺序不正确，需要调整！"
    fi

    # 如果key的数量不等于value的数量，说明有些key储存了空值，需要清理一下。
    if [ ${KEY_NU} -ne ${VAL_NU} ]; then
        echo_date "KEY_NU $KEY_NU"
        echo_date "VAL_NU $VAL_NU"
        ADJUST=1
        echo_date "⚠️节点配置有残余值，需要清理！"
    fi

    if [ ${ADJUST} = "1" ]; then
        # 提取干净的节点配置，并重新排序，现在web界面里添加/删除节点后会自动排序，所以以下基本不会运行到
        echo_date "💾备份所有节点信息并重新排序..."
        echo_date "⌛如果节点数量过多，此处可能需要等待较长时间，请耐心等待..."
        rm -rf ${BACKUP_FILE}
        cat > ${BACKUP_FILE} <<-EOF
            #!/bin/sh
            source /koolshare/scripts/base.sh
            #------------------------
            # remove all nodes first
            confs=\$(dbus list ssconf_basic_ | cut -d "=" -f 1)
            for conf in \$confs
            do
                dbus remove \$conf
            done
            usleep 300000
            #------------------------
            # rewrite all node in order
EOF

        # node to json file
        sed -i '/^ssconf_basic_.\+_[0-9]\+=$/d' ${DIR}/ssconf_keyval_origin.txt
        count="1"
        for nu in ${NODES_SEQ}
        do
            cat ${DIR}/ssconf_keyval_origin.txt | grep "_${nu}=" | sed "s/_${nu}=/_${count}=\"/g;s/^/dbus set /;s/$/\"/" >>${BACKUP_FILE}
            count=$((count+1))
        done
        echo_date "⌛备份完毕，开始调整..."
        # 2 应用提取的干净的节点配置
        chmod +x ${BACKUP_FILE}
        sh ${BACKUP_FILE}
        echo_date "ℹ️节点调整完毕！"
        
        # 重新获取节点序列
        NODES_SEQ=$(dbus list ssconf_basic_name_ | sed -n 's/^.*_\([0-9]\+\)=.*/\1/p' | sort -n)
        NODE_INDEX=$(echo ${NODES_SEQ} | sed 's/.*[[:space:]]//')
    else
        echo_date "🆗节点顺序正确，节点配置信息OK！"
    fi
}

filter_nodes(){
    # ------------------------------- 关键词匹配逻辑 -------------------------------
    # 用[排除]和[包括]关键词去匹配，剔除掉用户不需要的节点，剩下的需要的节点：UPDATE_FLAG=0，
    # UPDATE_FLAG=0,需要的节点；1.判断本地是否有此节点，2.如果有就添加，没有就判断是否需要更新
    # UPDATE_FLAG=2,不需要的节点；1. 判断本地是否有此节点，2.如果有就删除，没有就不管
    if [ -z "${KEY_WORDS_1}" ] && [ -z "${KEY_WORDS_2}" ];then
        return 0
    fi
    _type=$1
    remarks=$2
    server=$3
    [ -n "${KEY_WORDS_1}" ] && KEY_MATCH_1=$(echo ${remarks} ${server} | grep -Eo "${KEY_WORDS_1}")
    [ -n "${KEY_WORDS_2}" ] && KEY_MATCH_2=$(echo ${remarks} ${server} | grep -Eo "${KEY_WORDS_2}")
    if [ -n "${KEY_WORDS_1}" ] && [ -z "${KEY_WORDS_2}" ]; then
        # 排除节点：yes，包括节点：no
        if [ -n "${KEY_MATCH_1}" ]; then
            echo_date "⚪${_type}节点：【${remarks}】，不添加，因为匹配了[排除]关键词"
            exclude=$((exclude+1))
            return 1
        else
            return 0
        fi
    elif [ -z "${KEY_WORDS_1}" ] && [ -n "${KEY_WORDS_2}" ]; then
        # 排除节点：no，包括节点：yes
        if [ -z "${KEY_MATCH_2}" ]; then
            echo_date "⚪${_type}节点：【${remarks}】，不添加，因为不匹配[包括]关键词"
            exclude=$((exclude+1))
            return 1
        else
            return 0
        fi
    elif [ -n "${KEY_WORDS_1}" ] && [ -n "${KEY_WORDS_2}" ]; then
        # 排除节点：yes，包括节点：yes
        if [ -n "${KEY_MATCH_1}" ] && [ -z "${KEY_MATCH_2}" ]; then
            echo_date "⚪${_type}节点：【${remarks}】，不添加，因为匹配了[排除+包括]关键词"
            exclude=$((exclude+1))
            return 1
        elif [ -n "${KEY_MATCH_1}" ] && [ -n "${KEY_MATCH_2}" ]; then
            echo_date "⚪${_type}节点：【${remarks}】，不添加，因为匹配了[排除]关键词"
            exclude=$((exclude+1))
            return 1
        elif  [ -z "${KEY_MATCH_1}" ] && [ -z "${KEY_MATCH_2}" ]; then
            echo_date "⚪${_type}节点：【${remarks}】，不添加，因为不匹配[包括]关键词"
            exclude=$((exclude+1))
            return 1
        else
            return 0
        fi
    else
        return 0
    fi
}

json_query(){
    echo "${2}" | sed 's/^{//;s/}$//;s/,"/,\n"/g;s/":"/":/g' | sed 's/,$//g;s/"$//g' | sed -n "s/^\"${1}\":\(.\+\)\$/\1/p"
}

get_fancyss_running_status(){
    STATUS_1=$(dbus get ss_basic_enable 2>/dev/null)
    STATUS_2=$(iptables --t nat -S|grep SHADOWSOCKS|grep -w "3333" 2>/dev/null)
    STATUS_3=$(netstat -nlp 2>/dev/null|grep -w "3333"|grep -E "ss-redir|sslocal|v2ray|koolgame|xray|ipt2socks|clash-fancyss")
    STATUS_4=$(netstat -nlp 2>/dev/null|grep -w "7913")
    # 当插件状态为开启，iptables状态正常，透明端口进程正常，DNS端口正常，DNS配置文件正常
    if [ "${STATUS_1}" = "1" ] && [ -n "${STATUS_2}" ] && [ -n "${STATUS_3}" ] && [ -n "${STATUS_4}" ] && [ -f "/jffs/configs/dnsmasq.d/wblist.conf" ];then
        echo 1
    fi
}


get_online_rule_now(){
    # 0. variable define
    online_url="$1"

    # 1. get domain name of node subscribe link
    if [ -z "$(echo "$online_url" | sed -e 's|^[^/]*//||' -e 's|/.*$||' | awk -F ":" '{print $1}')" ];then
        echo_date "⚠️订阅链接【${online_url}】异常！请检查！"
        return 1
    fi

    online_url_file_tmp=/koolshare/ss/online_url_file.tmp
    
    # 7. download sublink
    echo_date "📁准备下载订阅链接到本地临时文件，请稍等..."
    
    if ! download_by_curl "$online_url" "$online_url_file_tmp"; then
        echo_date "⚠️使用curl下载订阅失败，尝试更换wget进行下载..."
        if ! download_by_wget "$online_url" "$online_url_file_tmp";then
            download_by_aria2 "$online_url" "$online_url_file_tmp"
        fi
    fi

    echo_date "🆗下载成功，继续检测下载内容..."
    if [ "$(wc -c < "$online_url_file_tmp")" = "0" ] || ! grep -qw ^proxies "$online_url_file_tmp" || ! grep -qw ^proxy-groups "$online_url_file_tmp";then
        echo_date "⚠️下载内容校验不通过！"
        return 1
    fi
    
    echo_date "🆗下载内容检测完成！"

    cat /koolshare/ss/config.yaml > /koolshare/ss/config.yaml.old
    cat "${online_url_file_tmp}" > /koolshare/ss/config.yaml
    
}

exit_sub(){
    echo_date "==================================================================="
    exit 1
}

start_online_update(){
    echo_date "==================================================================="
    echo_date "                服务器订阅程序(Shell by stones & sadog)"
    echo_date "==================================================================="

    # run some test before anything start
    # echo_date "⚙️test: 脚本环境变量：$(env | wc -l)个"
    
    # 0. var define
    NODES_SEQ=$(dbus list ssconf_basic_name_ | grep -E "_[0-9]+=" | sed -n 's/^.*_\([0-9]\+\)=.*/\1/p' | sort -n)
    SEQ_NU=$(echo "$NODES_SEQ" | tr ' ' '\n' | sed '/^$/d' | wc -l)

    # 1. 如果本地没有订阅的节点，同时没有订阅链接，则退出订阅
    online_url="$(dbus get ss_online_links | base64 -d | sed 's/$/\n/' | sed '/^$/d' | sed '/^#/d' | sed 's/^[[:space:]]//g' | sed 's/[[:space:]]&//g')"
    if ! echo "$online_url" | grep -q "^http";then
        echo_date "🈳未发现任何有效的订阅地址，请检查你的订阅链接！"
        exit_sub
    fi

    # 3.订阅前检查节点是否储存正常，不需要了
    # check_nodes

    # # 4. skipd节点数据储存到文件
    # skipdb2json

    # # 4. 储存的节点文件，按照不通机场拆分
    # nodes2files
    
    # # 5. 用拆分文件统计节点
    # nodes_stats

    # # 6. 移除没有订阅的节点
    # remove_null
    
    # 7. 下载/解析订阅节点
        # [ -z "${url}" ] && continue
    echo_date "➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖"
    echo_date "📢开始订阅！订阅链接如下："
    echo_date "🌎 ${online_url}"
    get_online_rule_now "${online_url}"
    echo_date "➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖➖"

    # 5. 写入所有节点

    # ISNEW=$(find $DIR -name "local_*_*.txt")
    # if [ -n "${ISNEW}" ];then
    #     find $DIR -name "local_*.txt" | sort -n | xargs cat >$DIR/ss_nodes_new.txt
    #     md5sum_old=$(md5sum ${LOCAL_NODES_BAK} 2>/dev/null | awk '{print $1}')
    #     md5sum_new=$(md5sum $DIR/ss_nodes_new.txt 2>/dev/null | awk '{print $1}')
    #     if [ "${md5sum_new}" != "${md5sum_old}" ];then
    #         clear_nodes
    #         echo_date "ℹ️开始写入节点..."
    #         json2skipd "ss_nodes_new"
    #     else
    #         echo_date "ℹ️本次订阅没有任何节点发生变化，不进行写入，继续！"
    #     fi
    #     # 订阅完成，再次统计
    #     SEQ_NU=$(dbus list ssconf_basic_name_|wc -l)
    #     skipdb2json
    #     nodes2files
    #     nodes_stats
    #     echo_date "🧹一点点清理工作..."
    #     echo_date "🎉所有订阅任务完成，请等待6秒，或者手动关闭本窗口！"
    # else
    #     echo_date "⚠️出错！未找到节点写入文件！"
    #     echo_date "⚠️退出订阅！"
    # fi
    echo_date "==================================================================="
}

if [ -z "$2" ] && [ -n "$1" ];then
    SH_ARG=$1
    WEB_ACTION=0
elif [ -n "$2" ] && [ -n "$1" ];then
    SH_ARG=$2
    WEB_ACTION=1
fi

case $SH_ARG in
0)
    # 删除所有节点
    set_lock
    true > $LOG_FILE
    [ "${WEB_ACTION}" = "1" ] && http_response "$1"
    remove_all_node | tee -a $LOG_FILE
    echo XU6J03M6 | tee -a $LOG_FILE
    unset_lock
    ;;
1)
    # 删除所有订阅节点
    set_lock
    true > $LOG_FILE
    [ "${WEB_ACTION}" = "1" ] && http_response "$1"
    remove_sub_node | tee -a $LOG_FILE
    echo XU6J03M6 | tee -a $LOG_FILE
    unset_lock
    ;;
2)
    # 保存订阅设置但是不订阅
    set_lock
    true > $LOG_FILE
    [ "${WEB_ACTION}" = "1" ] && http_response "$1"
    local_groups=$(dbus list ssconf_basic_group_ | cut -d "=" -f2 | sort -u | wc -l)
    online_group=$(dbus get ss_online_links | base64 -d | awk '{print $1}' | sed '/^$/d' | sed '/^#/d' | sed 's/^[[:space:]]//g' | sed 's/[[:space:]]&//g' | grep -Ec "^http")
    echo_date "保存订阅节点成功！" | tee -a $LOG_FILE
    echo_date "现共有 $online_group 组订阅来源" | tee -a $LOG_FILE
    echo_date "当前节点列表内已经订阅了 $local_groups 组..." | tee -a $LOG_FILE
    sed -i '/ssnodeupdate/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
    if [ "$(dbus get ss_basic_node_update)" = "1" ]; then
        _msg="设置自动更新订阅服务在"
        ss_basic_node_update_day="$(dbus get ss_basic_node_update_day)"
        if [ "$ss_basic_node_update_day" = "0" ]; then
            ss_basic_node_update_day='*'
            _msg="${_msg} 每天"
        else
            _msg="${_msg} 周${ss_basic_node_update_day} 的"
        fi
        ss_basic_node_update_hr="$(dbus get ss_basic_node_update_hr)"
        if [ "$ss_basic_node_update_hr" = "25" ];then
            ss_basic_node_update_hr='*'
            _msg="${_msg} 每小时。"
        else
            _msg="${_msg} $ss_basic_node_update_hr 点。"
        fi
        cru a ssnodeupdate "0 $ss_basic_node_update_hr * * $ss_basic_node_update_day /koolshare/scripts/ss_online_update.sh fancyss 3"
        echo_date "$_msg" | tee -a $LOG_FILE
    else
        echo_date "关闭自动更新订阅服务！" | tee -a $LOG_FILE
        sed -i '/ssnodeupdate/d' /var/spool/cron/crontabs/* >/dev/null 2>&1
    fi
    echo XU6J03M6 | tee -a $LOG_FILE
    unset_lock
    ;;
3)
    # 使用订阅链接订阅ss/ssr/V2ray节点
    set_lock
    true > $LOG_FILE
    [ "${WEB_ACTION}" = "1" ] && http_response "$1"
    start_online_update | tee -a $LOG_FILE
    echo XU6J03M6 | tee -a $LOG_FILE
    unset_lock
    ;;
esac
