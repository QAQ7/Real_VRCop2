# ============================================================
#  Virtua Cop 2 VR - 安装脚本（剥离 ROM 版）
#  - 安装 vcop2vr_lite/vcop2vr.apk
#  - 把 roms\ 下的 ROM 推到设备
#  - 授权存储权限
#  用法: .\install.ps1 [-AdbPath <path>] [-Device <serial>]
# ============================================================
param(
    [string]$AdbPath = "",
    [string]$Device = ""
)

$ErrorActionPreference = "Stop"

# ---------- 定位 adb ----------
function Find-Adb {
    if ($AdbPath -and (Test-Path $AdbPath)) { return $AdbPath }
    foreach ($p in @(
        "$env:ANDROID_HOME\platform-tools\adb.exe",
        "$env:ANDROID_SDK_ROOT\platform-tools\adb.exe",
        "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
        "$env:USERPROFILE\AppData\Local\Android\Sdk\platform-tools\adb.exe"
    )) {
        if (Test-Path $p) { return $p }
    }
    $cmd = Get-Command adb -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    throw "找不到 adb.exe。请设置 ANDROID_HOME 或把 platform-tools 加入 PATH。"
}

$adb = Find-Adb
Write-Host "[INFO] adb: $adb"

function Invoke-Adb {
    param([string[]]$Args)
    if ($Device) { & $adb -s $Device @Args } else { & $adb @Args }
    if ($LASTEXITCODE -ne 0) { throw "adb 命令失败: $($Args -join ' ')" }
}

# ---------- 检查设备 ----------
Write-Host "`n[INFO] 检查设备连接..."
$devices = Invoke-Adb -Args @("devices") | Where-Object { $_ -match "\tdevice$" }
if (-not $devices) { throw "没有检测到已连接的设备。请用 USB 连接 Quest 3 并在头显里允许 USB 调试。" }
Write-Host "[OK] 设备:" $devices

# ---------- 安装 APK ----------
$apk = Join-Path $PSScriptRoot "vcop2vr.apk"
if (-not (Test-Path $apk)) { throw "找不到 $apk" }

Write-Host "`n[INFO] 安装 $apk ..."
try {
    Invoke-Adb -Args @("install", "-r", $apk)
} catch {
    Write-Host "[WARN] 覆盖安装失败，尝试卸载旧版本..."
    Invoke-Adb -Args @("uninstall", "io.vcop2vr") 2>$null | Out-Null
    Invoke-Adb -Args @("install", $apk)
}
Write-Host "[OK] 安装完成"

# ---------- 推送 ROM ----------
$romDir = Join-Path $PSScriptRoot "roms"
if (-not (Test-Path $romDir)) { throw "找不到 $romDir" }

Write-Host "`n[INFO] 创建 ROM 目录..."
Invoke-Adb -Args @("shell", "mkdir", "-p", "/sdcard/Android/data/io.vcop2vr/files/roms")

Write-Host "[INFO] 推送 ROM..."
foreach ($f in Get-ChildItem "$romDir\*.zip") {
    Write-Host ("  - {0}" -f $f.Name)
    Invoke-Adb -Args @("push", $f.FullName, "/sdcard/Android/data/io.vcop2vr/files/roms/" + $f.Name)
}
Write-Host "[OK] ROM 推送完成"

# ---------- 授权 ----------
Write-Host "`n[INFO] 授予存储权限..."
foreach ($perm in @(
    "android.permission.WRITE_EXTERNAL_STORAGE",
    "android.permission.READ_EXTERNAL_STORAGE"
)) {
    try { Invoke-Adb -Args @("shell", "pm", "grant", "io.vcop2vr", $perm) } catch {}
}

Write-Host "`n=============================================="
Write-Host "  安装完成！在 Quest 3 里打开 ""Virtua Cop 2 VR"" 即可游玩。"
Write-Host "=============================================="
