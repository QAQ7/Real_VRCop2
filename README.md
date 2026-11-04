# Real_VRCop2

Virtua Cop 2 VR — 在 Meta Quest 3 上运行的《VR 战警 2》移植版本。

## 关于本项目

本项目由 **QAQ7** 开发，基于 **[Port0r](https://github.com/jacquesdupontd/port0r)**
（作者：[jacquesdupontd](https://github.com/jacquesdupontd)）的 Cop VR v0.2.3 版本进行改造，
将默认游戏从 **Virtua Cop 1**（Model 1 基板）替换为 **Virtua Cop 2**（Model 2A 基板）。

**感谢 jacquesdupontd 提供了优秀的 VR 移植框架和底层实现。** 本项目的改造建立在
Port0r 的工作之上。原项目的许可证信息保留在 [LICENSE](LICENSE) 的致谢部分。

## 改动内容

在 Port0r Cop VR v0.2.3 基础上做了以下修改：

### 1. 默认驱动从 vcop 改为 vcop2

通过反汇编 `libhello_xr.so`，修改了 `arcadexr::packs` 的默认游戏配置：

- `packs::DefaultGame()` 的返回值从 `"vcop"` 改为 `"vcop2"`
- pack 模板的 driver 字段同步更新
- 两者通过一处字符串覆写（`"discord.name"` → `"vcop2"`）保持一致

### 2. 设备 ROM 映射修正

原项目把 `segabill`（Model 2 的 Billboard 控制板固件）映射为
`model1io2`（Model 1 的 I/O 板），导致启动时提示缺少 `model1io2`。
已修正为直接返回 `"segabill"`。

### 3. ROM 自动导入

在 `TcvrActivity.smali` 中新增了 `copyAsset()` 方法，
使 ROM 可以从 APK 的 `assets/roms/` 自动复制到应用私有目录，
免去手动 `adb push` 的步骤。

### 4. APK 打包修复

- `extractNativeLibs` 设为 `false`（与原项目一致）
- 使用 `zipalign -p 4096` 对 native 库做 4KB 页对齐
- `resources.arsc` 改为 STORED 并 4 字节对齐（Android 11+ 要求）
- 补齐 `versionCode` / `versionName` / `minSdkVersion` / `targetSdkVersion`
- 修正 R 类资源 ID 与资源表的不匹配
- 重新签名（v1/v2/v3）

## 运行需求

| 项目 | 版本 |
| --- | --- |
| 设备 | Meta Quest 3 |
| Android | 10 (API 29) 及以上 |
| ROM | `vcop2.zip`（MAME 0.289 版）+ `segabill.zip` |

ROM 文件**不包含在本仓库中**（版权原因）。请自行准备后放入 `roms/` 目录。

## 安装

**方法一：安装脚本（推荐）**

将 `roms/` 目录下的 ROM 准备好后，双击运行 `install.bat`：

```bat
install.bat
```

脚本会自动：检测 adb → 检查设备 → 安装 APK → 推送 ROM → 授予权限。

**方法二：手动安装**

```bat
adb install -r vcop2vr.apk
adb shell mkdir -p /sdcard/Android/data/io.vcop2vr/files/roms
adb push roms/vcop2.zip    /sdcard/Android/data/io.vcop2vr/files/roms/
adb push roms/segabill.zip /sdcard/Android/data/io.vcop2vr/files/roms/
```

## 目录结构

```
Real_VRCop2/
├── vcop2vr.apk          APK（已剥离 ROM，82 MB）
├── roms/                ROM 放置目录
│   ├── vcop2.zip
│   └── segabill.zip
├── install.bat          安装脚本（CMD）
├── install.ps1          安装脚本（PowerShell）
├── LICENSE              本项目许可证（BSD 3-Clause）
└── README.md
```

## 致谢

- **[jacquesdupontd](https://github.com/jacquesdupontd)** — [Port0r](https://github.com/jacquesdupontd/port0r)
  的作者，提供了完整的 VR 移植框架、OpenXR/Vulkan 渲染层和 MAME 集成。
  本项目的一切改造建立在其工作之上。Port0r 采用 BSD 3-Clause 许可证。
- **MAME 开发团队** — Model 2 模拟核心。
- **SEGA** — 原始游戏《Virtua Cop 2》的版权方。

## 许可证

本项目采用 [BSD 3-Clause License](LICENSE)。

- 本项目版权：Copyright (c) 2026, QAQ7
- 参考项目：[Port0r](https://github.com/jacquesdupontd/port0r) by
  [jacquesdupontd](https://github.com/jacquesdupontd)，同样采用 BSD 3-Clause 许可证

## 免责声明

本项目仅供学习研究使用。游戏 ROM 的版权归 SEGA 所有，
请确保你拥有合法的游戏副本。
