<#
.SYNOPSIS
    自动同步并精简 Web-Dev-For-Beginners 仓库，仅保留简体中文翻译与中文图片。
.DESCRIPTION
    该脚本执行以下操作：
    1. 从 upstream（Microsoft 原仓库）拉取最新提交；
    2. 合并到本地 main 分支；
    3. 使用 git-filter-repo 删除非中文翻译与图片；
    4. 执行 Git 清理与垃圾回收；
    5. 强制推送结果到 GitHub 仓库.
#>

# ---------------------- 配置区 ----------------------

# 你的仓库远程地址（请换成自己的）
$originUrl = "https://github.com/vain-Liang/Web-Dev-For-Beginners.git"

# 上游官方仓库地址
$upstreamUrl = "https://gh-proxy.com//https://github.com/microsoft/Web-Dev-For-Beginners.git"

# 日志写入
# Start-Transcript -Path "./log/sync-log-$(Get-Date -Format yyyyMMdd-HHmmss).txt"

# ---------------------- 检查环境 ----------------------

Write-Host "🔍 检查 git 版本..." -ForegroundColor Cyan
git --version | Out-Host

Write-Host "🔍 检查 git-filter-repo 是否可用..." -ForegroundColor Cyan
try {
    git-filter-repo --version | Out-Host
} catch {
    Write-Host "❌ 未检测到 git-filter-repo，请先执行: pip install git-filter-repo" -ForegroundColor Red
    exit 1
}

# ---------------------- 设置仓库 ----------------------

Write-Host "📂 切换至仓库目录..." -ForegroundColor Cyan
# 脚本位于仓库根目录下
$repoPath = (Resolve-Path ".").Path
Set-Location $repoPath

# 确认仓库存在
if (!(Test-Path ".git")) {
    Write-Host "❌ 当前目录不是 git 仓库，请在仓库根目录运行此脚本。" -ForegroundColor Red
    exit 1
}

# 确保 main 分支
Write-Host "🔄 切换到 main 分支..." -ForegroundColor Cyan
git checkout main

# ---------------------- 同步上游 ----------------------

Write-Host "🌍 添加上游仓库..." -ForegroundColor Cyan
$hasUpstream = git remote | Select-String "upstream"
if (git remote get-rul upstream 2>$null) {
    git remote set-url upstream $upstreamUrl
}
if (-not $hasUpstream) {
    git remote add upstream $upstreamUrl
}

Write-Host "⬇️ 获取上游更新..." -ForegroundColor Cyan
git fetch upstream

Write-Host "🧩 合并上游更新..." -ForegroundColor Cyan
git merge upstream/main --allow-unrelated-histories -m "Sync from upstream"

# ---------------------- 精简仓库 ----------------------

Write-Host "🧹 开始执行过滤，仅保留中文翻译与图片..." -ForegroundColor Yellow

git-filter-repo --force --filename-callback '
  if filename.startswith(b"translations/") and not filename.startswith(b"translations/zh/"):
    return None
  # 删除非中文图片
  if filename.startswith(b"translated_images/") and not filename.endswith(b".zh.png"):
    return None
  return filename
'

# ---------------------- 清理与优化 ----------------------

Write-Host "🧽 清理历史与垃圾对象..." -ForegroundColor Yellow
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# ---------------------- 推送更新 ----------------------

Write-Host "🚀 推送精简后仓库到远程..." -ForegroundColor Cyan
$hasOrigin = git remote | Select-String "origin"
if (-not $hasOrigin) {
    git remote add origin $originUrl
}
git push origin main --force

# ---------------------- 完成 ----------------------

Write-Host ""
Write-Host "✅ 仓库同步与精简已完成！" -ForegroundColor Green
Write-Host "当前远程: $originUrl"
Write-Host "上游源:    $upstreamUrl"
Write-Host "时间:      $(Get-Date)"
Write-Host ""
