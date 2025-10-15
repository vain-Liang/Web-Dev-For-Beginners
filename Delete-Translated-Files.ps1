# 1. 配置参数
# =================================================================

# --- 任务1: 清理图片文件 ---
# 图片所在的文件夹路径
$imageDirectory = ".\translated_images"
# 要保留的图片语言代码
$imageLanguagesToKeep = @('zh')

# --- 任务2: 清理翻译文件夹 ---
# 翻译文件夹所在的路径
$translationDirectory = ".\translations"
# 要保留的翻译子文件夹名称
$translationDirsToKeep = @('zh')


# 2. 执行逻辑
# =================================================================

# --- 执行任务1: 删除指定语言的图片文件 ---
Write-Host "--- 开始任务 1: 清理 '$imageDirectory' 文件夹中的图片 ---" -ForegroundColor Cyan

if (Test-Path -Path $imageDirectory) {
    Get-ChildItem -Path $imageDirectory -Filter "*.png" -File | ForEach-Object {
        $file = $_
        $fileNameParts = $file.Name.Split('.')
        
        if ($fileNameParts.Count -ge 4) {
            $languageCode = $fileNameParts[-2]
            
            if ($languageCode -notin $imageLanguagesToKeep) {
                Write-Host "[图片] 准备删除: $($file.Name) (语言: $languageCode)" -ForegroundColor Yellow
                
                # !! 安全预览: -WhatIf 会模拟删除, 确认无误后, 删除 "-WhatIf"
                Remove-Item -Path $file.FullName -Force -WhatIf
                
                # 真正执行删除时, 使用此行 (删除 -WhatIf)
                # Remove-Item -Path $file.FullName -Force
            }
        } else {
            Write-Host "[图片] 跳过格式不符的文件: $($file.Name)" -ForegroundColor Gray
        }
    }
} else {
    Write-Host "错误: 找不到图片文件夹 '$imageDirectory'。请检查路径。" -ForegroundColor Red
}

Write-Host "--- 任务 1 完成 ---`n" -ForegroundColor Cyan


# --- 执行任务2: 删除指定语言的翻译文件夹 ---
Write-Host "--- 开始任务 2: 清理 '$translationDirectory' 文件夹中的子文件夹 ---" -ForegroundColor Cyan

if (Test-Path -Path $translationDirectory) {
    # -Directory 参数确保只获取文件夹
    Get-ChildItem -Path $translationDirectory -Directory | Where-Object { $_.Name -notin $translationDirsToKeep } | ForEach-Object {
        $dir = $_
        Write-Host "[文件夹] 准备删除: $($dir.Name)" -ForegroundColor Yellow
        
        # !! 安全预览: -WhatIf 会模拟删除。-Recurse 用于删除非空文件夹。
        Remove-Item -Path $dir.FullName -Recurse -Force -WhatIf
        
        # 真正执行删除时, 使用下面这行 (删除 -WhatIf)
        # Remove-Item -Path $dir.FullName -Recurse -Force
    }
} else {
    Write-Host "错误: 找不到翻译文件夹 '$translationDirectory'。请检查路径。" -ForegroundColor Red
}

Write-Host "--- 任务 2 完成 ---" -ForegroundColor Cyan
Write-Host "`n脚本执行完毕!" -ForegroundColor Green