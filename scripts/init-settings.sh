#!/bin/bash
#=================================================
# File name: init-settings.sh
# Description: This script will be executed during the first boot
# Author: GilaGajet
# Blog: https://mlapp.cn
#=================================================

# Check file system during boot
uci set fstab.@global[0].check_fs=1
uci commit

# Disable opkg signature check
sed -i 's/option check_signature/# option check_signature/g' /etc/opkg.conf

#-----------------------------------------------------------------------------

# Set hostname to OpenWRT
uci set system.@system[0].hostname='OpenWRT'

# Set Timezone to Asia/KL
uci set system.@system[0].timezone='MYT-8'
uci set system.@system[0].zonename='Asia/Kuala Lumpur'
uci commit system

#-----------------------------------------------------------------------------

# Add IP Address Info Checker
# run "myip" using terminal for use
chmod +x /bin/myip

#-----------------------------------------------------------------------------

# Set Custom TTL (cat /proc/sys/net/ipv4/ip_default_ttl)
cat << 'EOF' >> /etc/firewall.user
iptables -t mangle -A POSTROUTING -j TTL --ttl-set 65
EOF
/etc/config/firewall restart
echo | tee -a /etc/sysctl.conf
echo '# TTL' | tee -a /etc/sysctl.conf
echo "net.ipv4.ip_default_ttl=65" >> /etc/sysctl.conf 
#echo "net.ipv6.ip_default_ttl=65" >> /etc/sysctl.conf 

#-----------------------------------------------------------------------------

# LuCI -> System -> Terminal (a.k.a) luci-app-ttyd without login
if ! grep -q "/bin/login -f root" /etc/config/ttyd; then
	cat << "EOF" > /etc/config/ttyd
config ttyd
	option interface '@lan'
	option command '/bin/login -f root'
EOF
	logger "  log : Terminal ttyd patched..."
	echo -e "  log : Terminal ttyd patched..."
fi
#-----------------------------------------------------------------------------

# Tweak1
chmod 755 /etc/crontabs/root
echo '# Clear PageCache' | tee -a /etc/crontabs/root
echo '0 */3 * * * sync; echo 1 > /proc/sys/vm/drop_caches' | tee -a /etc/crontabs/root
echo | tee -a /etc/crontabs/root
echo '# Ping Loop' | tee -a /etc/crontabs/root
echo '* * * * * ping 8.8.8.8' | tee -a /etc/crontabs/root
echo | tee -a /etc/crontabs/root
echo '# Stop Flooding Ping' | tee -a /etc/crontabs/root
echo "* * * * * pgrep ping | awk 'NR >= 3' | xargs -n1 kill" | tee -a /etc/crontabs/root
echo | tee -a /etc/crontabs/root
#echo '# Clear Log' | tee -a /etc/crontabs/root
#echo "*/15 * * * * /etc/init.d/log restart >/dev/null 2>&1" | tee -a /etc/crontabs/root

# Tweak2
echo | tee -a /etc/sysctl.conf
echo '# increase Linux autotuning TCP buffer limit to 32MB' | tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_rmem=4096 87380 33554432' | tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_wmem=4096 65536 33554432' | tee -a /etc/sysctl.conf
echo | tee -a /etc/sysctl.conf
echo '# recommended default congestion control is htcp' | tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_congestion_control=bbr' | tee -a /etc/sysctl.conf
echo | tee -a /etc/sysctl.conf
echo '# recommended for hosts with jumbo frames enabled' | tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_mtu_probing=1' | tee -a /etc/sysctl.conf
echo | tee -a /etc/sysctl.conf
echo '# Others' | tee -a /etc/sysctl.conf
echo 'fs.file-max=1000000' | tee -a /etc/sysctl.conf
echo 'fs.inotify.max_user_instances=8192' | tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_tw_reuse=1' | tee -a /etc/sysctl.conf
echo 'net.ipv4.ip_local_port_range=1024 65000' | tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_max_syn_backlog=1024' | tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_fin_timeout=15' | tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_keepalive_intvl=30' | tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_keepalive_probes=5' | tee -a /etc/sysctl.conf
echo 'net.netfilter.nf_conntrack_tcp_timeout_time_wait=30' | tee -a /etc/sysctl.conf
echo 'net.netfilter.nf_conntrack_tcp_timeout_fin_wait=30' | tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_synack_retries=3' | tee -a /etc/sysctl.conf

#-----------------------------------------------------------------------------

#Update System Info
#rm -r /www/luci-static/resources/view/status/include/10_system.js
mv /www/luci-static/resources/view/status/include/10_system.js 10_system.js.bak

cat << 'EOF' >> /www/luci-static/resources/view/status/include/10_system.js
'use strict';
'require baseclass';
'require fs';
'require rpc';
var callSystemBoard = rpc.declare({
	object: 'system',
	method: 'board'
});
var callSystemInfo = rpc.declare({
	object: 'system',
	method: 'info'
});
var callCPUBench=rpc.declare({
	object:'luci',
	method:'getCPUBench'
});
var callCPUInfo=rpc.declare({
	object:'luci',
	method:'getCPUInfo'
});
var callCPUUsage=rpc.declare({
	object:'luci',
	method:'getCPUUsage'
});	
var callTempInfo=rpc.declare({
	object:'luci',
	method:'getTempInfo'
});

return baseclass.extend({
	title: _('System'),
	load: function() {
		return Promise.all([
			L.resolveDefault(callSystemBoard(), {}),
			L.resolveDefault(callSystemInfo(), {}),
			L.resolveDefault(callCPUBench(),{}),
			L.resolveDefault(callCPUInfo(),{}),
			L.resolveDefault(callCPUUsage(),{}),
			L.resolveDefault(callTempInfo(),{}),
			fs.lines('/usr/lib/lua/luci/version.lua')
		]);
	},
	render: function(data) {
		var boardinfo   = data[0],
		    systeminfo  = data[1],
		    cpubench=data[2],
		    cpuinfo=data[3],
		    cpuusage=data[4],
		    tempinfo=data[5],
		    luciversion=data[6];luciversion=luciversion.filter(function(l) {
			return l.match(/^\s*(luciname|luciversion)\s*=/);
		}).map(function(l) {
			return l.replace(/^\s*\w+\s*=\s*['"]([^'"]+)['"].*$/, '$1');
		}).join(' ');
		var datestr = null;
		if (systeminfo.localtime) {
			var date = new Date(systeminfo.localtime * 1000);
			datestr = '%04d-%02d-%02d %02d:%02d:%02d'.format(
				date.getUTCFullYear(),
				date.getUTCMonth() + 1,
				date.getUTCDate(),
				date.getUTCHours(),
				date.getUTCMinutes(),
				date.getUTCSeconds()
			);
		}
		
		// Source-Link Start
		var projectlink = document.createElement('a');
		projectlink.append(boardinfo.release.description);
		projectlink.href = 'https://t.me/openwrtuser0';
		projectlink.target = '_blank';
		var corelink = document.createElement('a');
		corelink.append('Shopee');
		corelink.href = 'http://shp.ee/n8yf7jf';
		corelink.target = '_blank';
		var sourcelink = document.createElement('placeholder');
		sourcelink.append(projectlink);
		sourcelink.append(' | ');
		sourcelink.append(corelink);
		// Source-Link End
		
		var fields = [
			_('Hostname'),         boardinfo.hostname,
			_('Model'),            boardinfo.model+cpubench.cpubench,
			_('Architecture'),     cpuinfo.cpuinfo||boardinfo.system,
			_('Target Platform'),  (L.isObject(boardinfo.release) ? boardinfo.release.target : ''),
			_('Firmware Version'), sourcelink,
			_('Kernel Version'),   boardinfo.kernel,
			_('Local Time'),       datestr,
			_('Uptime'),           systeminfo.uptime ? '%t'.format(systeminfo.uptime) : null,
			_('Load Average'),     Array.isArray(systeminfo.load) ? '%.2f, %.2f, %.2f'.format(
				systeminfo.load[0] / 65535.0,
				systeminfo.load[1] / 65535.0,
				systeminfo.load[2] / 65535.0
			) : null,
			_('CPU usage (%)'),    cpuusage.cpuusage
		];
		
			if(tempinfo.tempinfo){
				fields.splice(6,0,_('Temperature'));
				fields.splice(7,0,tempinfo.tempinfo);
				         }
					 
		var table = E('table', { 'class': 'table' });
		for (var i = 0; i < fields.length; i += 2) {
			table.appendChild(E('tr', { 'class': 'tr' }, [
				E('td', { 'class': 'td left', 'width': '33%' }, [ fields[i] ]),
				E('td', { 'class': 'td left' }, [ (fields[i + 1] != null) ? fields[i + 1] : '?' ])
			]));
		}
		return table;
	}
});
EOF

sleep 1

uci commit system
/etc/init.d/system reload

#-----------------------------------------------------------------------------

# Disable ipv6
uci set 'network.lan.ipv6=0'
uci set 'network.wan.ipv6=0'
uci set 'dhcp.lan.dhcpv6=disabled'

/etc/init.d/odhcpd stop
/etc/init.d/odhcpd disable

uci set network.lan.delegate="0"

uci -q delete network.globals.ula_prefix

uci -q delete dhcp.lan.dhcpv6
uci -q delete dhcp.lan.ra

uci delete network.wan6
uci commit

/etc/init.d/network restart

#-----------------------------------------------------------------------------

#vnstat
rm -r /etc/config/vnstat

cat << 'EOF' >> /etc/config/vnstat

config vnstat
	list interface 'br-lan'
	list interface 'eth0'
	list interface 'eth1'
EOF

exit 0
