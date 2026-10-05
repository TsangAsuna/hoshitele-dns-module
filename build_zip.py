#!/usr/bin/env python3
"""从本仓库文件组装可刷入的 Magisk/SukiSU 模块 zip。

用法：
    python build_zip.py [输出文件名]

默认输出：hoshitele-dns-module.zip
排除仓库特有文件（README.md、LICENSE、build_zip.py、.git 等）。
"""
import os
import sys
import zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
EXCLUDE = {"README.md", "LICENSE", "build_zip.py", ".git", ".github"}
MODULE_ID = "hoshitele"


def read_version():
    prop = {}
    with open(os.path.join(HERE, "module.prop"), encoding="utf-8") as f:
        for line in f:
            if "=" in line:
                k, v = line.rstrip("\n").split("=", 1)
                prop[k.strip()] = v.strip()
    return prop.get("version", "unknown").replace("/", "_")


def main():
    out_name = sys.argv[1] if len(sys.argv) > 1 else f"{MODULE_ID}-dns-module.zip"
    out_path = os.path.join(HERE, out_name)

    files = []
    for root, dirs, names in os.walk(HERE):
        dirs[:] = [d for d in dirs if d not in EXCLUDE]
        for n in names:
            if n in EXCLUDE or n.endswith(".zip"):
                continue
            p = os.path.join(root, n)
            files.append((p, os.path.relpath(p, HERE).replace(os.sep, "/")))
    files.sort(key=lambda x: x[1])

    with zipfile.ZipFile(out_path, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as zf:
        for p, arc in files:
            zf.write(p, arc)

    print(f"已生成: {out_path}")
    for _, arc in files:
        print(f"  + {arc}")
    print(f"共 {len(files)} 个文件, 版本: {read_version()}")


if __name__ == "__main__":
    main()
