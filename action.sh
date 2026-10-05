#!/system/bin/sh
PATH="/system/bin:$PATH"
adgh_pid=$(pidof AdGuardHome)
smartdns_pid=$(pidof smartdns)
echo "===== SERVER ====="
if [ "$adgh_pid" != "" ];then
    echo " - AdGuardHome运行中(Pid:${adgh_pid})"
else
    echo " - AdGuardHome未运行！"
fi
if [ "$smartdns_pid" != "" ];then
    echo " - SmartDNS运行中(Pid:${smartdns_pid})"
else
    echo " - SmartDNS未运行！"
fi
echo "===== NET_INF ====="
echo " - 端口状态："
netstat -tulpn | grep -E "3000|3721|3927"
echo " "
echo " - IPV4："
iptables -L INPUT -n -v
echo " "
iptables -t nat -L PREROUTING -n -v
echo " "
iptables -t nat -L OUTPUT -n -v
echo " "
iptables -t nat -L ADGH -n -v
echo " "
echo " - IPV6："
ip6tables -L OUTPUT -n -v
