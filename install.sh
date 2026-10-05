SKIPMOUNT=false
LATESTARTSERVICE=true
POSTFSDATA=false
PROPFILE=false

# 旧模块目录（升级刷入时，旧目录在重启前仍保留在 /data/adb/modules/ 下）
OLD_MODULE=/data/adb/modules/hoshitele

print_modname() {
 ui_print "*******************************"
 ui_print "     	Magisk Module        "
 ui_print "Make By 小白杨（爱玩机工具箱）"
 ui_print "*******************************"
 ui_print "- AdGuardHome v1.0.0-b.1 (beta)"
 ui_print "- SmartDNS 1.2026.08.05 (R48.4)"
}
on_install() {
 ui_print "- 正在释放程序文件"
 unzip -o "$ZIPFILE" 'AdGuardHome/AdGuardHome' -d $MODPATH >&2
 unzip -o "$ZIPFILE" 'SmartDNS/smartdns' -d $MODPATH >&2
 unzip -o "$ZIPFILE" 'busybox' -d $MODPATH >&2
 unzip -o "$ZIPFILE" 'action.sh' -d $MODPATH >&2
 unzip -o "$ZIPFILE" 'webroot/index.html' -d $MODPATH >&2
 mkdir -p $MODPATH/AdGuardHome/data/filters
 mkdir -p $MODPATH/SmartDNS

 if [ -f "$OLD_MODULE/AdGuardHome/AdGuardHome.yaml" ]; then
  ui_print "- 检测到旧版本，保留设备上原有配置"
  ui_print "- DNS重写/黑白名单/SmartDNS配置不会被覆盖"
  # AdGuardHome：配置与数据（DNS重写、user_rules黑白名单、过滤列表、统计与日志）
  cp -f $OLD_MODULE/AdGuardHome/AdGuardHome.yaml $MODPATH/AdGuardHome/AdGuardHome.yaml
  if [ -f $OLD_MODULE/AdGuardHome/AdGuardHome.yaml.bak ]; then
   cp -f $OLD_MODULE/AdGuardHome/AdGuardHome.yaml.bak $MODPATH/AdGuardHome/AdGuardHome.yaml.bak
  fi
  cp -af $OLD_MODULE/AdGuardHome/data/. $MODPATH/AdGuardHome/data/
  # SmartDNS：配置、备份与缓存
  cp -f $OLD_MODULE/SmartDNS/smartdns.conf $MODPATH/SmartDNS/smartdns.conf
  if [ -f $OLD_MODULE/SmartDNS/smartdns.conf.bak ]; then
   cp -f $OLD_MODULE/SmartDNS/smartdns.conf.bak $MODPATH/SmartDNS/smartdns.conf.bak
  fi
  if [ -f $OLD_MODULE/SmartDNS/smartdns.cache ]; then
   cp -f $OLD_MODULE/SmartDNS/smartdns.cache $MODPATH/SmartDNS/smartdns.cache
  fi
 else
  ui_print "- 全新安装，使用默认配置"
  ui_print "- 面板: http://127.0.0.1:3000 (首次免登录)"
  unzip -o "$ZIPFILE" 'AdGuardHome/AdGuardHome.yaml' -d $MODPATH >&2
  unzip -o "$ZIPFILE" 'SmartDNS/smartdns.conf' -d $MODPATH >&2
 fi
}
set_permissions() {
 set_perm_recursive $MODPATH 0 0 0755 0644
# 二进制与脚本需要可执行权限
 set_perm $MODPATH/busybox 0 0 0755
 set_perm $MODPATH/AdGuardHome/AdGuardHome 0 0 0755
 set_perm $MODPATH/SmartDNS/smartdns 0 0 0755
 set_perm $MODPATH/action.sh 0 0 0755
 set_perm $MODPATH/service.sh 0 0 0755
}
