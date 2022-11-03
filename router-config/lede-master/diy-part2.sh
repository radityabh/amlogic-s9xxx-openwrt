#!/bin/bash
#========================================================================================================================
# https://github.com/ophub/amlogic-s9xxx-openwrt
# Description: Automatically Build OpenWrt for Amlogic S9xxx STB
# Function: Diy script (After Update feeds, Modify the default IP, hostname, theme, add/remove software packages, etc.)
# Source code repository: https://github.com/coolsnowwolf/lede / Branch: master
#========================================================================================================================

# ------------------------------- Main source started -------------------------------
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# Mod default-settings
[ -d package/emortal/default-settings/files ] && pushd package/emortal/default-settings/files

cat << 'EOF' >>  99-default-settings
if ! grep '/usr/bin/zsh' /etc/passwd
sed -i 's|/bin/ash|/usr/bin/zsh|g' /etc/passwd
fi

exit 0
EOF

popd

pushd package/base-files
sed -i 's/ImmortalWrt/GiGaWRT/g' image-config.in
sed -i 's/ImmortalWrt/GiGaWRT/g' files/bin/config_generate
sed -i 's/UTC/UTC+8/g' files/bin/config_generate
popd

sed -i 's/ImmortalWrt/GiGaWRT/g' config/Config-images.in
sed -i 's/ImmortalWrt/GiGaWRT/g' include/version.mk
sed -i 's/immortalwrt.org/openwrt.org/g' include/version.mk

# Version Update
sed -i '/DISTRIB_DESCRIPTION/d' package/base-files/files/etc/openwrt_release
echo "DISTRIB_DESCRIPTION=' STB B3 build $(TZ=UTC+8 date "+%Y.%m") '" >> package/base-files/files/etc/openwrt_release
sed -i '/DISTRIB_REVISION/d' package/base-files/files/etc/openwrt_release
echo "DISTRIB_REVISION='[WSS]'" >> package/base-files/files/etc/openwrt_release

# Modify default theme（FROM uci-theme-bootstrap CHANGE TO luci-theme-material）
#sed -i 's/luci-theme-bootstrap/luci-theme-material/g' ./feeds/luci/collections/luci/Makefile

# Modify some code adaptation
sed -i 's/LUCI_DEPENDS.*/LUCI_DEPENDS:=\@\(arm\|\|aarch64\)/g' package/lean/luci-app-cpufreq/Makefile

# Add autocore support for armvirt
sed -i 's/TARGET_rockchip/TARGET_rockchip\|\|TARGET_armvirt/g' package/lean/autocore/Makefile

# Modify default root's password（FROM 'password'[$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.] CHANGE TO 'your password'）
# sed -i 's/root::0:0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/g' /etc/shadow

# Replace the default software source
# sed -i 's#openwrt.proxy.ustclug.org#mirrors.bfsu.edu.cn\\/openwrt#' package/lean/default-settings/files/zzz-default-settings
#
# ------------------------------- Main source ends -------------------------------

############################################################
# Remove some net packages
rm -rf ./feeds/packages/net/https-dns-proxy
rm -rf ./feeds/packages/net/kcptun
rm -rf ./feeds/packages/net/shadowsocks-libev
rm -rf ./feeds/packages/net/xray-core
rm -rf ./feeds/packages/net/brook
rm -rf ./feeds/packages/net/chinadns-ng
rm -rf ./feeds/packages/net/hysteria
rm -rf ./feeds/packages/net/ssocks
rm -rf ./feeds/packages/net/trojan
rm -rf ./feeds/packages/net/trojan-go
rm -rf ./feeds/packages/net/trojan-plus
rm -rf ./feeds/packages/net/sagernet-core
rm -rf ./feeds/packages/net/naiveproxy
rm -rf ./feeds/packages/net/shadowsocks-rust
rm -rf ./feeds/packages/net/shadowsocksr-libev
rm -rf ./feeds/packages/net/simple-obfs
rm -rf ./feeds/packages/net/tcping
rm -rf ./feeds/packages/net/v2ray-core
rm -rf ./feeds/packages/net/v2ray-geodata
rm -rf ./feeds/packages/net/v2ray-plugin
rm -rf ./feeds/packages/net/v2raya
rm -rf ./feeds/packages/net/xray-core
rm -rf ./feeds/packages/net/xray-plugin
rm -rf ./feeds/packages/net/dns2socks
rm -rf ./feeds/packages/net/microsocks
rm -rf ./feeds/packages/net/ipt2socks
rm -rf ./feeds/packages/net/pdnsd-alt
rm -rf ./feeds/packages/net/redsocks2

# Dependencies
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/brook feeds/packages/net/brook
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/chinadns-ng feeds/packages/net/chinadns-ng
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/dns2tcp feeds/packages/net/dns2tcp
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/hysteria feeds/packages/net/hysteria
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/ssocks feeds/packages/net/ssocks
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/sing-box feeds/packages/net/sing-box
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/trojan-go feeds/packages/net/trojan-go
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/trojan-plus feeds/packages/net/trojan-plus
svn export https://github.com/xiaorouji/openwrt-passwall/trunk/sagernet-core feeds/packages/net/sagernet-core
svn export https://github.com/fw876/helloworld/trunk/naiveproxy feeds/packages/net/naiveproxy
svn export https://github.com/immortalwrt/packages/trunk/net/shadowsocks-libev feeds/packages/net/shadowsocks-libev
svn export https://github.com/fw876/helloworld/trunk/shadowsocks-rust feeds/packages/net/shadowsocks-rust
svn export https://github.com/fw876/helloworld/trunk/shadowsocksr-libev feeds/packages/net/shadowsocksr-libev
svn export https://github.com/fw876/helloworld/trunk/simple-obfs feeds/packages/net/simple-obfs
svn export https://github.com/fw876/helloworld/trunk/tcping feeds/packages/net/tcping
svn export https://github.com/fw876/helloworld/trunk/trojan feeds/packages/net/trojan
svn export https://github.com/fw876/helloworld/trunk/v2ray-core feeds/packages/net/v2ray-core
svn export https://github.com/fw876/helloworld/trunk/v2ray-geodata feeds/packages/net/v2ray-geodata
svn export https://github.com/fw876/helloworld/trunk/v2ray-plugin feeds/packages/net/v2ray-plugin
svn export https://github.com/fw876/helloworld/trunk/v2raya feeds/packages/net/v2raya
svn export https://github.com/arqam999/openwrt-passwall/branches/xtls-wss/xray-core feeds/packages/net/xray-core
svn export https://github.com/fw876/helloworld/trunk/xray-plugin feeds/packages/net/xray-plugin
svn export https://github.com/fw876/helloworld/trunk/lua-neturl feeds/packages/net/lua-neturl
svn export https://github.com/immortalwrt/packages/trunk/net/dns2socks feeds/packages/net/dns2socks
svn export https://github.com/immortalwrt/packages/trunk/net/microsocks feeds/packages/net/microsocks
svn export https://github.com/immortalwrt/packages/trunk/net/ipt2socks feeds/packages/net/ipt2socks
svn export https://github.com/immortalwrt/packages/trunk/net/pdnsd-alt feeds/packages/net/pdnsd-alt
svn export https://github.com/immortalwrt/packages/trunk/net/redsocks2 feeds/packages/net/redsocks2
svn export https://github.com/immortalwrt/packages/trunk/net/https-dns-proxy feeds/packages/net/https-dns-proxy
svn export https://github.com/immortalwrt/packages/trunk/net/kcptun feeds/packages/net/kcptun
svn export https://github.com/kiddin9/openwrt-bypass/trunk/lua-maxminddb feeds/packages/net/lua-maxminddb
svn export https://github.com/coolsnowwolf/lede/trunk/package/lean/shortcut-fe package/kernel/shortcut-fe
svn export https://github.com/immortalwrt/packages/trunk/net/dnsforwarder feeds/packages/net/dnsforwarder

############################################################
# luci-app-passwall
rm -r ./feeds/luci/applications/luci-app-passwall
svn export https://github.com/arqam999/openwrt-passwall/branches/luci-nodns/luci-app-passwall feeds/luci/applications/luci-app-passwall

#luci-app-turboacc
svn export https://github.com/immortalwrt/luci/trunk/applications/luci-app-turboacc feeds/luci/applications/luci-app-turboacc

# Autocore
svn export https://github.com/immortalwrt/immortalwrt/branches/openwrt-21.02/package/emortal/autocore feeds/packages/utils/autocore
sed -i 's/"getTempInfo" /"getTempInfo", "getCPUBench", "getCPUUsage" /g' feeds/packages/utils/autocore/files/generic/luci-mod-status-autocore.json

# Coremark
rm -rf ./feeds/packages/utils/coremark
svn export https://github.com/immortalwrt/packages/trunk/utils/coremark feeds/packages/utils/coremark
############################################################


# ------------------------------- Other started -------------------------------
# Clone community packages to package/community
mkdir package/community
pushd package/community

# edit Argon
rm -rf package/lean/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/lean/luci-theme-argon

# update mwan3
rm -rf package/lean/luci-app-mwan3helper
svn co https://github.com/Lienol/openwrt/branches/21.02/package/lean/luci-app-mwan3helper package/lean/luci-app-mwan3helper

rm -rf feeds/luci/applications/luci-app-mwan3
svn co https://github.com/openwrt/luci/branches/openwrt-21.02/applications/luci-app-mwan3 feeds/luci/applications/luci-app-mwan3

rm -rf feeds/packages/net/mwan3
svn co https://github.com/openwrt/packages/branches/openwrt-21.02/net/mwan3 feeds/packages/net/mwan3

# Add luci-app-amlogic
svn co https://github.com/ophub/luci-app-amlogic/trunk/luci-app-amlogic package/luci-app-amlogic

# Add official OpenClash source
git clone --depth=1 -b dev https://github.com/vernesong/OpenClash

# HelmiWrt packages
git clone --depth=1 https://github.com/helmiau/helmiwrt-packages
rm -rf helmiwrt-packages/luci-app-v2raya
# telegrambot
svn co https://github.com/helmiau/helmiwrt-adds/trunk/packages/net/telegrambot helmiwrt-adds/telegrambot
svn co https://github.com/helmiau/helmiwrt-adds/trunk/luci/luci-app-telegrambot helmiwrt-adds/luci-app-telegrambot

# Add Adguardhome
git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package/new/luci-app-adguardhome
rm -rf ./feeds/packages/net/adguardhome
svn export https://github.com/openwrt/packages/trunk/net/adguardhome feeds/packages/net/adguardhome
sed -i '/init/d' feeds/packages/net/adguardhome/Makefile

# Add luci-app-ssr-plus
# svn co https://github.com/fw876/helloworld/trunk/luci-app-ssr-plus package/openwrt-ssrplus
# rm -rf package/openwrt-ssrplus/luci-app-ssr-plus/po/zh_Hans 2>/dev/null
# Add p7zip
# svn co https://github.com/hubutui/p7zip-lede/trunk package/p7zip

# coolsnowwolf default software package replaced with Lienol related software package
# rm -rf feeds/packages/utils/{containerd,libnetwork,runc,tini}
# svn co https://github.com/Lienol/openwrt-packages/trunk/utils/{containerd,libnetwork,runc,tini} feeds/packages/utils

# Add third-party software packages (The entire repository)
# git clone https://github.com/libremesh/lime-packages.git package/lime-packages
# Add third-party software packages (Specify the package)
# svn co https://github.com/libremesh/lime-packages/trunk/packages/{shared-state-pirania,pirania-app,pirania} package/lime-packages/packages
# Add to compile options (Add related dependencies according to the requirements of the third-party software package Makefile)
# sed -i "/DEFAULT_PACKAGES/ s/$/ pirania-app pirania ip6tables-mod-nat ipset shared-state-pirania uhttpd-mod-lua/" target/linux/armvirt/Makefile

# Apply patch
# git apply ../router-config/patches/{0001*,0002*}.patch --directory=feeds/luci

popd
#
# ------------------------------- Other ends -------------------------------

# Fix mt76 wireless driver
pushd package/kernel/mt76
sed -i '/mt7662u_rom_patch.bin/a\\techo mt76-usb disable_usb_sg=1 > $\(1\)\/etc\/modules.d\/mt76-usb' Makefile
popd

# Change default shell to zsh
sed -i 's|/bin/ash|/usr/bin/zsh|g' package/base-files/files/etc/passwd


# Add extra wireless drivers
svn co https://github.com/immortalwrt/immortalwrt/branches/openwrt-18.06-k5.4/package/kernel/rtl8812au-ac
svn co https://github.com/immortalwrt/immortalwrt/branches/openwrt-18.06-k5.4/package/kernel/rtl8188eu
svn co https://github.com/immortalwrt/immortalwrt/branches/openwrt-18.06-k5.4/package/kernel/rtl88x2bu

# Add cpufreq
rm -rf ./feeds/luci/applications/luci-app-cpufreq 
svn co https://github.com/DHDAXCW/luci-bt/trunk/applications/luci-app-cpufreq ./feeds/luci/applications/luci-app-cpufreq
ln -sf ./feeds/luci/applications/luci-app-cpufreq ./package/feeds/luci/luci-app-cpufreq
sed -i 's,1608,1800,g' feeds/luci/applications/luci-app-cpufreq/root/etc/uci-defaults/10-cpufreq
sed -i 's,2016,2208,g' feeds/luci/applications/luci-app-cpufreq/root/etc/uci-defaults/10-cpufreq
sed -i 's,1512,1608,g' feeds/luci/applications/luci-app-cpufreq/root/etc/uci-defaults/10-cpufreq

