# 星屑☆テレパス (hoshitele) — AdGuardHome + SmartDNS Magisk/SukiSU 模块

在 Android 设备上以 Magisk/SukiSU 模块形式本地部署 **AdGuard Home** 与 **SmartDNS**，
通过 iptables 接管全机 DNS 请求，实现系统级广告过滤与 DNS 优选。

> **关于本仓库**：原模块由「爱玩机工具箱」模板制作，原作者已无法找到，本仓库是社区更新维护备份。
> 模块本体不含任何个人数据，内置配置为通用默认配置。

## 工作原理

```
App/系统 DNS 请求 (:53)
   │  iptables OUTPUT/PREROUTING REDIRECT
   ▼
AdGuard Home  127.0.0.1:3927   ← 广告过滤 / DNS 重写 / 黑白名单
   │  upstream
   ▼
SmartDNS      127.0.0.1:3721   ← 多上游测速优选 / 缓存
   │  DoH
   ▼
阿里 / 腾讯 / 360 / Google 等公共 DoH 上游
```

- IPv4：本机及热点客户端的 53 端口请求被重定向到 AdGuard Home
- IPv6：53 端口请求直接丢弃（模块未含 IPv6 转发），强制走 IPv4 通道
- AdGuard / SmartDNS 自身进程（root:net_raw）被 owner 规则豁免，避免回环
- 两个进程启动后写入 `/dev/cpuset/system-background` 后台调度组

## 内置版本

| 组件 | 版本 | 来源 |
|---|---|---|
| AdGuard Home | v1.0.0-b.1 (beta, linux_arm64) | [AdguardTeam/AdGuardHome Releases](https://github.com/AdguardTeam/AdGuardHome/releases) |
| SmartDNS | 1.2026.08.05 (Release48.4, aarch64 静态链接) | [pymumu/smartdns Releases](https://github.com/pymumu/smartdns/releases) |
| busybox | 模块自带 | 原模块遗留 |

## 默认配置（全新安装）

| 项目 | 值 |
|---|---|
| AdGuard Home 管理面板 | `http://127.0.0.1:3000`（首次**免登录**，建议进面板后立即创建管理员账号） |
| AdGuard Home DNS 监听 | `127.0.0.1:3927` |
| AdGuard Home 上游 | `127.0.0.1:3721`（SmartDNS） |
| SmartDNS 监听 | `127.0.0.1:3721` |
| SmartDNS 上游 | 阿里 / 腾讯 sm2 / 360 / Google DoH + 国内公共 DNS |
| 广告过滤 | 仅 AdGuard 官方默认过滤器（AdGuard DNS filter） |
| DNS 重写 / 黑白名单 | 空，自行在面板配置 |

SmartDNS 配置位于 `SmartDNS/smartdns.conf`，缓存与日志路径写死为模块目录
（`/data/adb/modules/hoshitele/SmartDNS/`），如改模块 id 需同步修改。

## 安装 / 升级

1. 在 SukiSU / Magisk 管理器中刷入本仓库 Release 里的 zip（或用 `build_zip.py` 自行打包）
2. 重启后生效（模块更新在重启时由管理器替换）

**升级刷入不会丢失配置**：`install.sh` 检测到 `/data/adb/modules/hoshitele` 中已有旧配置时，
只更新程序文件（两个二进制 / busybox / 脚本），以下内容全部原样保留：

- `AdGuardHome.yaml`（含 DNS 重写、自定义黑白名单 user_rules）
- `AdGuardHome/data/`（过滤列表、统计、查询日志）
- `SmartDNS/smartdns.conf`、`.bak`、DNS 缓存

只有设备上不存在旧模块时，才使用包内默认配置。

## 面板常用入口

- 管理面板：`http://127.0.0.1:3000`
- 模块「操作」按钮：查看进程状态、端口监听、iptables 规则（`action.sh`）

## 自行打包

```bash
python build_zip.py            # 生成 hoshitele-dns-module.zip
python build_zip.py 自定义.zip  # 指定输出文件名
```

## 许可证

- 模块脚本部分遵循 [GPL-3.0](LICENSE)。原作者已无法找到，如有异议请联系仓库所有者处理。
- 内置二进制来自上游开源项目，遵循其各自许可证分发，源码见上表链接：
  - [AdGuard Home](https://github.com/AdguardTeam/AdGuardHome) — GPL-3.0
  - [SmartDNS](https://github.com/pymumu/smartdns) — GPL-3.0

## 免责声明

本项目仅供学习与个人网络优化使用，请遵守所在地区法律法规，勿用于非法用途。
使用本模块造成的任何问题由使用者自行承担。
