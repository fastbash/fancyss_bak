#!/bin/sh

# fancyss script for asuswrt/merlin based router with software center

source /koolshare/scripts/base.sh
alias echo_date='echo 【$(TZ=UTC-8 date -R +%Y年%m月%d日\ %X)】:'
LOG_FILE=/tmp/upload/ss_log.txt

backup_conf(){
	rm -rf /tmp/files
	rm -rf /koolshare/webs/files
	mkdir -p /tmp/files
	ln -sf /tmp/files /koolshare/webs/files
	dbus list ss | grep -v "ss_basic_enable" | grep -v "ssid_" | sed 's/=/=\"/' | sed 's/$/\"/g'|sed 's/^/dbus set /' | sed '1 isource /koolshare/scripts/base.sh' |sed '1 i#!/bin/sh' > /koolshare/webs/files/ssconf_backup.sh
}

backup_tar(){
	rm -rf /tmp/files
	rm -rf /koolshare/webs/files
	mkdir -p /tmp/files
	ln -sf /tmp/files /koolshare/webs/files
	echo_date "开始打包..."
	cd /tmp
	mkdir shadowsocks
	mkdir shadowsocks/bin
	mkdir shadowsocks/scripts
	mkdir shadowsocks/webs
	mkdir shadowsocks/res
	echo_date "请等待一会儿..."
	local pkg_name=$(cat /koolshare/webs/Module_shadowsocks.asp | tr -d '\r' | grep -Eo "PKG_NAME=.+"|awk -F "=" '{print $2}'|sed 's/"//g')
	local pkg_arch=$(cat /koolshare/webs/Module_shadowsocks.asp | tr -d '\r' | grep -Eo "PKG_ARCH=.+"|awk -F "=" '{print $2}'|sed 's/"//g')
	local pkg_type=$(cat /koolshare/webs/Module_shadowsocks.asp | tr -d '\r' | grep -Eo "PKG_TYPE=.+"|awk -F "=" '{print $2}'|sed 's/"//g')
	local pkg_exta=$(cat /koolshare/webs/Module_shadowsocks.asp | tr -d '\r' | grep -Eo "PKG_EXTA=.+"|awk -F "=" '{print $2}'|sed 's/"//g')
	local pkg_vers=$(dbus get ss_basic_version_local)
	local _pkg_name=${pkg_name}_${pkg_arch}_${pkg_type}${pkg_exta}
	TARGET_FOLDER=/tmp/shadowsocks
	cp /koolshare/scripts/ss_install.sh ${TARGET_FOLDER}/install.sh
	cp /koolshare/scripts/uninstall_shadowsocks.sh ${TARGET_FOLDER}/uninstall.sh
	cp /koolshare/scripts/ss_* ${TARGET_FOLDER}/scripts/
	# binary
	cp /koolshare/bin/isutf8 ${TARGET_FOLDER}/bin/
	cp /koolshare/bin/obfs-local ${TARGET_FOLDER}/bin/
	cp /koolshare/bin/rss-local ${TARGET_FOLDER}/bin/
	cp /koolshare/bin/rss-redir ${TARGET_FOLDER}/bin/
	cp /koolshare/bin/dns2socks ${TARGET_FOLDER}/bin/
	cp /koolshare/bin/chinadns-ng ${TARGET_FOLDER}/bin/
	cp /koolshare/bin/sponge ${TARGET_FOLDER}/bin/
	cp /koolshare/bin/jq ${TARGET_FOLDER}/bin/
	cp /koolshare/bin/xray ${TARGET_FOLDER}/bin/
	cp /koolshare/bin/curl-fancyss ${TARGET_FOLDER}/bin/
	cp /koolshare/bin/dnsclient ${TARGET_FOLDER}/bin/
	if [ -x "/koolshare/bin/sslocal" ];then
		cp /koolshare/bin/sslocal ${TARGET_FOLDER}/bin/
	fi
	cp /koolshare/bin/dns2tcp ${TARGET_FOLDER}/bin/
	cp /koolshare/bin/dns-ecs-forcer ${TARGET_FOLDER}/bin/
	if [ -x "/koolshare/bin/uredir" ];then
		cp /koolshare/bin/uredir ${TARGET_FOLDER}/bin/
	fi
	if [ -x "/koolshare/bin/websocketd" ];then
		cp /koolshare/bin/websocketd ${TARGET_FOLDER}/bin/
	fi
	if [ "${pkg_type}" != "lite" ];then
		cp /koolshare/bin/dohclient ${TARGET_FOLDER}/bin/
		cp /koolshare/bin/dohclient-cache ${TARGET_FOLDER}/bin/
		cp /koolshare/bin/smartdns ${TARGET_FOLDER}/bin/
		cp /koolshare/bin/haproxy ${TARGET_FOLDER}/bin/
		cp /koolshare/bin/kcptun ${TARGET_FOLDER}/bin/
		cp /koolshare/bin/speeder* ${TARGET_FOLDER}/bin/
		cp /koolshare/bin/udp2raw ${TARGET_FOLDER}/bin/
		cp /koolshare/bin/trojan ${TARGET_FOLDER}/bin/
		cp /koolshare/bin/v2ray ${TARGET_FOLDER}/bin/
		cp /koolshare/bin/v2ray-plugin ${TARGET_FOLDER}/bin/
		cp /koolshare/bin/haveged ${TARGET_FOLDER}/bin/
		cp /koolshare/bin/ipt2socks ${TARGET_FOLDER}/bin/
		cp /koolshare/bin/naive ${TARGET_FOLDER}/bin/
		cp /koolshare/bin/tuic-client ${TARGET_FOLDER}/bin/
		cp /koolshare/bin/hysteria2 ${TARGET_FOLDER}/bin/
	fi
	cp /koolshare/webs/Module_shadowsocks*.asp ${TARGET_FOLDER}/webs/
	# others
	cp /koolshare/res/arrow-down.gif ${TARGET_FOLDER}/res/
	cp /koolshare/res/arrow-up.gif ${TARGET_FOLDER}/res/
	cp /koolshare/res/accountadd.png ${TARGET_FOLDER}/res/
	cp /koolshare/res/accountdelete.png ${TARGET_FOLDER}/res/
	cp /koolshare/res/accountedit.png ${TARGET_FOLDER}/res/
	cp /koolshare/res/icon-shadowsocks.png ${TARGET_FOLDER}/res/
	cp /koolshare/res/ss-menu.js ${TARGET_FOLDER}/res/
	cp /koolshare/res/tablednd.js ${TARGET_FOLDER}/res/
	cp /koolshare/res/qrcode.js ${TARGET_FOLDER}/res/
	cp /koolshare/res/fancyss.css ${TARGET_FOLDER}/res/
	cp -r /koolshare/ss ${TARGET_FOLDER}/
	rm -rf ${TARGET_FOLDER}/ss/*.json
	# arch
	echo ${pkg_arch} > ${TARGET_FOLDER}/.valid
	tar -czv -f /tmp/shadowsocks.tar.gz shadowsocks/
	rm -rf ${TARGET_FOLDER}
	mv /tmp/shadowsocks.tar.gz /tmp/files

	if [ -n "${_pkg_name}" -a -n "${pkg_vers}" ];then
		echo_date "打包文件名：${_pkg_name}_${pkg_vers}.tar.gz"
		ln -sf /tmp/files/shadowsocks.tar.gz /tmp/files/${_pkg_name}_${pkg_vers}.tar.gz
	fi
	echo_date "打包完毕！"
}

remove_now(){
	# 1. 关闭插件
	echo_date "尝试关闭科学上网..."
	dbus set ss_basic_enable="0"
	sh /koolshare/ss/ssconfig.sh stop

	# 2. 清空配置
	echo_date "开始清理科学上网配置..."
	confs=$(dbus list ss | cut -d "=" -f 1 | grep -v "version" | grep -v "ssserver_" | grep -v "ssid_" |grep -v "ss_basic_state_china" | grep -v "ss_basic_state_foreign")
	for conf in $confs
	do
		echo_date "移除$conf"
		dbus remove $conf
	done
	
	# 2. 设置默认值
	echo_date "设置一些默认参数..."

	# default values
	eval $(dbus export ss)
	local PKG_TYPE=$(cat /koolshare/webs/Module_shadowsocks.asp | tr -d '\r' | grep -Eo "PKG_TYPE=.+"|awk -F "=" '{print $2}'|sed 's/"//g')
	# 3.0.4：国内DNS默认使用运营商DNS
	[ -z "${ss_china_dns}" ] && dbus set ss_china_dns="1"
	# 3.0.4 从老版本升级到3.0.4，原部分方案需要切换到进阶方案，因为这些方案已经不存在
	if [ -z "${ss_basic_advdns}" -a -z "${ss_basic_olddns}" ];then
		# 全新安装的 3.0.4+，或者从3.0.3及其以下版本升级而来
		if [ -z "${ss_foreign_dns}" ];then
			# 全新安装的 3.0.4
			dbus set ss_basic_advdns="1"
			dbus set ss_basic_olddns="0"
		else
			# 从3.0.3及其以下版本升级而来
			# 因为一些dns选项已经不存在，所以更改一下
			if [ "${ss_foreign_dns}" == "2" -o "${ss_foreign_dns}" == "5" -o "${ss_foreign_dns}" == "10" -o "${ss_foreign_dns}" == "1" -o "${ss_foreign_dns}" == "6" ];then
				# 原chinands2、chinadns1、chinadns-ng、cdns、https_dns_proxy已经不存在, 更改为进阶DNS设定：chinadns-ng
				dbus set ss_basic_advdns="1"
				dbus set ss_basic_olddns="0"
			elif [ "${ss_foreign_dns}" == "4" -o "${ss_foreign_dns}" == "9" ];then
				if [ "${PKG_TYPE}" == "lite" ];then
					# ss-tunnel、SmartDNS方案在lite版本中不存在
					dbus set ss_basic_advdns="1"
					dbus set ss_basic_olddns="0"
				else
					# ss-tunnel、SmartDNS方案在full版本中存在
					dbus set ss_basic_advdns="0"
					dbus set ss_basic_olddns="1"
				fi
			else
				# dns2socks, v2ray/xray_dns, 直连这些在full和lite版中都在
				dbus set ss_basic_advdns="0"
				dbus set ss_basic_olddns="1"
			fi
		fi
	elif [ -z "${ss_basic_advdns}" -a -n "${ss_basic_olddns}" ];then
		# 不正确，ss_basic_advdns和ss_basic_olddns必须值相反
		[ "${ss_basic_olddns}" == "0" ] && dbus set ss_basic_advdns="1"
		[ "${ss_basic_olddns}" == "1" ] && dbus set ss_basic_advdns="0"
	elif [ -n "${ss_basic_advdns}" -a -z "${ss_basic_olddns}" ];then
		# 不正确，ss_basic_advdns和ss_basic_olddns必须值相反
		[ "${ss_basic_advdns}" == "0" ] && dbus set ss_basic_olddns="1"
		[ "${ss_basic_advdns}" == "1" ] && dbus set ss_basic_olddns="0"
	elif [ -n "${ss_basic_advdns}" -a -n "${ss_basic_olddns}" ];then
		if [ "${ss_basic_advdns}" == "${ss_basic_olddns}" ];then
			[ "${ss_basic_olddns}" == "0" ] && dbus set ss_basic_advdns="1"
			[ "${ss_basic_olddns}" == "1" ] && dbus set ss_basic_advdns="0"
		fi
	fi

	[ -z "${ss_basic_proxy_newb}" ] && dbus set ss_basic_proxy_newb=1
	[ -z "${ss_basic_udpoff}" ] && dbus set ss_basic_udpoff=0
	[ -z "${ss_basic_udpall}" ] && dbus set ss_basic_udpall=0
	[ -z "${ss_basic_udpgpt}" ] && dbus set ss_basic_udpgpt=1
	[ -z "${ss_basic_nonetcheck}" ] && dbus set ss_basic_nonetcheck=1
	[ -z "${ss_basic_notimecheck}" ] && dbus set ss_basic_notimecheck=1
	[ -z "${ss_basic_nocdnscheck}" ] && dbus set ss_basic_nocdnscheck=1
	[ -z "${ss_basic_nofdnscheck}" ] && dbus set ss_basic_nofdnscheck=1
	
	[ "${ss_disable_aaaa}" != "1" ] && dbus set ss_basic_chng_no_ipv6=1
	[ -z "${ss_basic_chng_xact}" ] && dbus set ss_basic_chng_xact=0
	[ -z "${ss_basic_chng_xgt}" ] && dbus set ss_basic_chng_xgt=1
	[ -z "${ss_basic_chng_xmc}" ] && dbus set ss_basic_chng_xmc=0
	
	# others
	[ -z "$(dbus get ss_acl_default_mode)" ] && dbus set ss_acl_default_mode=1
	[ -z "$(dbus get ss_acl_default_port)" ] && dbus set ss_acl_default_port=all
	[ -z "$(dbus get ss_basic_interval)" ] && dbus set ss_basic_interval=2
	[ -z "$(dbus get ss_basic_wt_furl)" ] && dbus set ss_basic_wt_furl="http://www.google.com.tw"
	[ -z "$(dbus get ss_basic_wt_curl)" ] && dbus set ss_basic_wt_curl="http://www.baidu.com"

	# fancyss_arm 默认关闭延迟测试
	PKG_ARCH=$(cat /koolshare/webs/Module_shadowsocks.asp | tr -d '\r' | grep -Eo "PKG_ARCH=.+" | awk -F"=" '{print $2}' | sed 's/"//g')
	if [ "${PKG_ARCH}" == "arm" ];then
		[ -z "${ss_basic_latency_opt}" ] && dbus set ss_basic_latency_opt="0"
	else
		[ -z "${ss_basic_latency_opt}" ] && dbus set ss_basic_latency_opt="2"
	fi
	
	# lite
	if [ ! -x "/koolshare/bin/v2ray" ];then
		dbus set ss_basic_vcore=1
	else
		dbus set ss_basic_vcore=0
	fi
	
	if [ ! -x "/koolshare/bin/trojan" ];then
		dbus set ss_basic_tcore=1
	else
		dbus set ss_basic_tcore=0
	fi

	echo_date "设置完毕"
}

remove_silent(){
	echo_date 先清除已有的参数...
	confs=$(dbus list ss | cut -d "=" -f 1 | grep -v "version" | grep -v "ssserver_" | grep -v "ssid_" |grep -v "ss_basic_state_china" | grep -v "ss_basic_state_foreign")
	for conf in $confs
	do
		echo_date 移除$conf
		dbus remove $conf
	done
	echo_date 设置一些默认参数...
	dbus set ss_basic_version_local=$(cat /koolshare/ss/version) 
	echo_date "--------------------"
}

restore_sh(){
	echo_date 检测到科学上网备份文件...
	echo_date 开始恢复配置...
	chmod +x /tmp/upload/ssconf_backup.sh
	sh /tmp/upload/ssconf_backup.sh
	dbus set ss_basic_enable="0"
	dbus set ss_basic_version_local=$(cat /koolshare/ss/version) 
	echo_date 配置恢复成功！
}

restore_json(){
	echo_date 检测到ss json配置文件...
	ss_format=$(echo $confs|grep "obfs")
	cat /tmp/ssconf_backup.json | jq --tab . > /tmp/ssconf_backup_formated.json
	if [ -z "$ss_format" ];then
		# SS json
		echo_date 检测到shadowsocks json配置文件...
		servers=$(cat /tmp/ssconf_backup_formated.json |grep -w server|sed 's/"//g'|sed 's/,//g'|sed 's/\s//g'|cut -d ":" -f 2)
		ports=$(cat /tmp/ssconf_backup_formated.json |grep -w server_port|sed 's/"//g'|sed 's/,//g'|sed 's/\s//g'|cut -d ":" -f 2)
		passwords=$(cat /tmp/ssconf_backup_formated.json |grep -w password|sed 's/"//g'|sed 's/,//g'|sed 's/\s//g'|cut -d ":" -f 2)
		methods=$(cat /tmp/ssconf_backup_formated.json |grep -w method|sed 's/"//g'|sed 's/,//g'|sed 's/\s//g'|cut -d ":" -f 2)
		remarks=$(cat /tmp/ssconf_backup_formated.json |grep -w remarks|sed 's/"//g'|sed 's/,//g'|sed 's/\s//g'|cut -d ":" -f 2)
		
		echo_date 开始导入配置...导入json配置不会覆盖原有配置.
		last_node=$(dbus list ssconf_basic_server|cut -d "=" -f 1| cut -d "_" -f 4| sort -nr|head -n 1)
		if [ ! -z "$last_node" ];then
			k=$(expr $last_node + 1)
		else
			k=1
		fi
		min=1
		max=$(cat /tmp/ssconf_backup_formated.json |grep -wc server)
		while [ $min -le $max ]
		do
		    echo_date "==============="
		    echo_date import node $min
		    echo_date $k
		    
		    server=$(echo $servers | awk "{print $"$min"}")
			port=$(echo $ports | awk "{print $"$min"}")
			password=$(echo $passwords | awk "{print $"$min"}")
			method=$(echo $methods | awk "{print $"$min"}")
			remark=$(echo $remarks | awk "{print $"$min"}")
			
			echo_date $server
			echo_date $port
			echo_date $password
			echo_date $method
			echo_date $remark
			
			dbus set ssconf_basic_server_"$k"="$server"
			dbus set ssconf_basic_port_"$k"="$port"
			dbus set ssconf_basic_password_"$k"=$(echo "$password" | base64_encode)
			dbus set ssconf_basic_method_"$k"="$method"
			dbus set ssconf_basic_name_"$k"="$remark"
			dbus set ssconf_basic_use_rss_"$k"=0
			dbus set ssconf_basic_mode_"$k"=2
		    min=$(expr $min + 1)
		    k=$(expr $k + 1)
		done
		echo_date 导入配置成功！
	else
		# SSR json
		echo_date 检测到ssr json配置文件...
		servers=$(cat /tmp/ssconf_backup_formated.json |grep -w server|sed 's/"//g'|sed 's/,//g'|sed 's/\s//g'|cut -d ":" -f 2)
		ports=$(cat /tmp/ssconf_backup_formated.json |grep -w server_port|sed 's/"//g'|sed 's/,//g'|sed 's/\s//g'|cut -d ":" -f 2)
		passwords=$(cat /tmp/ssconf_backup_formated.json |grep -w password|sed 's/"//g'|sed 's/,//g'|sed 's/\s//g'|cut -d ":" -f 2)
		methods=$(cat /tmp/ssconf_backup_formated.json |grep -w method|sed 's/"//g'|sed 's/,//g'|sed 's/\s//g'|cut -d ":" -f 2)
		remarks=$(cat /tmp/ssconf_backup_formated.json |grep -w remarks|sed 's/"//g'|sed 's/,//g'|sed 's/\s//g'|cut -d ":" -f 2)
		obfs=$(cat /tmp/ssconf_backup_formated.json |grep -w obfs|sed 's/"//g'|sed 's/,//g'|sed 's/\s//g'|cut -d ":" -f 2)
		obfsparam=$(cat /tmp/ssconf_backup_formated.json |grep -w obfsparam|sed 's/"//g'|sed 's/,//g'|sed 's/\s//g'|cut -d ":" -f 2)
		protocol=$(cat /tmp/ssconf_backup_formated.json |grep -w protocol|sed 's/"//g'|sed 's/,//g'|sed 's/\s//g'|cut -d ":" -f 2)
		protocolparam=$(cat /tmp/ssconf_backup_formated.json |grep -w protocolparam|sed 's/"//g'|sed 's/,//g'|sed 's/\s//g'|sed 's/protocolparam://g')
		
		echo_date 开始导入配置...导入json配置不会覆盖原有配置.
		last_node=$(dbus list ssconf_basic_server|cut -d "=" -f 1| cut -d "_" -f 4| sort -nr|head -n 1)
		if [ ! -z "$last_node" ];then
			k=$(expr $last_node + 1)
		else
			k=1
		fi
		min=1
		max=$(cat /tmp/ssconf_backup_formated.json |grep -wc server)
		while [ $min -le $max ]
		do
		    echo_date "==============="
		    echo_date import node $min
		    echo_date $k
		    
		    server=$(echo $servers | awk "{print $"$min"}")
			port=$(echo $ports | awk "{print $"$min"}")
			password=$(echo $passwords | awk "{print $"$min"}")
			method=$(echo $methods | awk "{print $"$min"}")
			remark=$(echo $remarks | awk "{print $"$min"}")
			obf=$(echo $obfs | awk "{print $"$min"}")
			obfspara=$(echo $obfsparam | awk "{print $"$min"}")
			protoco=$(echo $protocol | awk "{print $"$min"}")
			protocolpara=$(echo $protocolparam | awk "{print $"$min"}")
			
			echo_date $server
			echo_date $port
			echo_date $password
			echo_date $method
			echo_date $remark
			echo_date $obf
			echo_date $obfspara
			echo_date $protoco
			echo_date $protocolpara
			
			dbus set ssconf_basic_server_"$k"="$server"
			dbus set ssconf_basic_port_"$k"="$port"
			dbus set ssconf_basic_password_"$k"=$(echo "$password" | base64_encode)
			dbus set ssconf_basic_method_"$k"="$method"
			dbus set ssconf_basic_name_"$k"="$remark"
			dbus set ssconf_basic_rss_obfs_"$k"="$obf"
			dbus set ssconf_basic_rss_obfs_param_"$k"="$obfspara"
			dbus set ssconf_basic_rss_protocol_"$k"="$protoco"
			dbus set ssconf_basic_rss_protocol_para_"$k"="$protocolpara"
			dbus set ssconf_basic_use_rss_"$k"=1
			dbus set ssconf_basic_mode_"$k"=2
		    min=$(expr $min + 1)
		    k=$(expr $k + 1)
		done
		echo_date 导入配置成功！
	fi
}

restore_now(){
	[ -f "/tmp/upload/ssconf_backup.sh" ] && restore_sh
	[ -f "/tmp/upload/ssconf_backup.json" ] && restore_json
	echo_date 一点点清理工作...
	rm -rf /tmp/ss_conf_*
	echo_date 完成！
}

reomve_ping(){
	# flush previous ping value in the table
	pings=$(dbus list ssconf_basic_ping | sort -n -t "_" -k 4|cut -d "=" -f 1)
	if [ -n "$pings" ];then
		for ping in $pings
		do
			echo "remove $ping"
			dbus remove "$ping"
		done
	fi
}

download_ssf(){
	rm -rf /tmp/files
	rm -rf /koolshare/webs/files
	mkdir -p /tmp/files
	ln -sf /tmp/files /koolshare/webs/files
	if [ -f "/tmp/upload/ssf_status.txt" ];then
		cp -rf /tmp/upload/ssf_status.txt /tmp/files/ssf_status.txt
	else
		echo "日志为空" > /tmp/files/ssf_status.txt
	fi
}

download_ssc(){
	rm -rf /tmp/files
	rm -rf /koolshare/webs/files
	mkdir -p /tmp/files
	ln -sf /tmp/files /koolshare/webs/files
	if [ -f "/tmp/upload/ssc_status.txt" ];then
		cp -rf /tmp/upload/ssc_status.txt /tmp/files/ssc_status.txt
	else
		echo "日志为空" > /tmp/files/ssc_status.txt
	fi
}

restart_dnsmasq(){
	echo_date "重启dnsmasq..."
	local OLD_PID=$(pidof dnsmasq)
	if [ -n "${OLD_PID}" ];then
		echo_date "当前dnsmasq正常运行中，pid: ${OLD_PID}，准备重启！"
	else
		echo_date "当前dnsmasq未运行，尝试重启！"
	fi
	
	service restart_dnsmasq >/dev/null 2>&1

	local DPID
	local i=50
	until [ -n "${DPID}" ]; do
		i=$(($i - 1))
		DPID=$(pidof dnsmasq)
		if [ "$i" -lt 1 ]; then
			echo_date "dnsmasq重启失败，请检查你的dnsmasq配置！"
		fi
		usleep 250000
	done
	echo_date "dnsmasq重启成功，pid: ${DPID}"
}

download_resv_log(){
	rm -rf /tmp/files
	rm -rf /koolshare/webs/files
	mkdir -p /tmp/files
	ln -sf /tmp/files /koolshare/webs/files
	local FILE_NAME=$(dbus get ss_basic_logname)
	local TIME_NOW=$(date -R +%Y%m%d_%H%M%S)
	cp -rf /tmp/upload/${FILE_NAME}.txt /tmp/files/${FILE_NAME}.txt
}

download_dig_log(){
	rm -rf /tmp/files
	rm -rf /koolshare/webs/files
	mkdir -p /tmp/files
	ln -sf /tmp/files /koolshare/webs/files
	cp -rf /tmp/upload/dns_dig_result.txt /tmp/files/dns_dig_result.txt
	sed -i '/XU6J03M6/d' /tmp/files/dns_dig_result.txt
}

case $2 in
1)
	true > ${LOG_FILE}
	backup_conf
	http_response "$1"
	;;
2)
	true > ${LOG_FILE}
	backup_tar >> ${LOG_FILE}
	sleep 1
	http_response "$1"
	sleep 2	
	echo XU6J03M6 >> ${LOG_FILE}
	;;
3)
	true > ${LOG_FILE}
	http_response "$1"
	remove_now >> ${LOG_FILE}
	echo XU6J03M6 >> ${LOG_FILE}
	;;
4)
	true > ${LOG_FILE}
	http_response "$1"
	remove_silent >> ${LOG_FILE}
	restore_now >> ${LOG_FILE}
	echo XU6J03M6 >> ${LOG_FILE}
	;;
5)
	reomve_ping
	;;
6)
	true > ${LOG_FILE}
	download_ssf
	http_response "$1"
	;;
7)
	true > ${LOG_FILE}
	download_ssc
	http_response "$1"
	;;
8)
	true > ${LOG_FILE}
	http_response "$1"
	restart_dnsmasq >> ${LOG_FILE}
	echo XU6J03M6 >> ${LOG_FILE}
	;;
10)
	true > ${LOG_FILE}
	download_resv_log
	http_response "$1"
	;;
11)
	true > ${LOG_FILE}
	download_dig_log
	http_response "$1"
	;;
esac
