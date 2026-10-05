#!/system/bin/sh
PATH="/system/bin:$PATH"
MODDIR=${0%/*}

#启动AdGuardHome与SmartDNS
sleep 10
$MODDIR/busybox setuidgid "root:net_raw" "$MODDIR/SmartDNS/smartdns" -c "$MODDIR/SmartDNS/smartdns.conf" -p -
$MODDIR/busybox setuidgid "root:net_raw" "$MODDIR/AdGuardHome/AdGuardHome" --no-check-update > /dev/null 2>&1 &
sleep 3
echo $(pidof smartdns) >/dev/cpuset/system-background/cgroup.procs
echo $(pidof AdGuardHome) >/dev/cpuset/system-background/cgroup.procs

#配置本地IPV4的DNS请求转发
iptables -w 64 -t nat -N ADGH
iptables -w 64 -t nat -A ADGH -m owner --uid-owner root --gid-owner net_raw -j RETURN
iptables -w 64 -t nat -A ADGH -p udp --dport 53 -j REDIRECT --to-ports 3927
iptables -w 64 -t nat -A ADGH -p tcp --dport 53 -j REDIRECT --to-ports 3927
iptables -w 64 -t nat -I OUTPUT -j ADGH

#丢弃本地IPV6的DNS请求(缺失IPV6转发模块)
ip6tables -w 64 -A OUTPUT -p udp --dport 53 -j DROP
ip6tables -w 64 -A OUTPUT -p tcp --dport 53 -j DROP

#配置热点转发
iptables -w 64 -t nat -I PREROUTING -p tcp --dport 53 -j REDIRECT --to-ports 3927
iptables -w 64 -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 3927

#额外处理
iptables -w 64 -I INPUT -i lo -j ACCEPT
sleep 60
iptables -w 64 -t nat -F OUTPUT
iptables -w 64 -t nat -I OUTPUT -j ADGH
