Write-Host ""
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host "   ||       Emergency Backup                      ||" -ForegroundColor Cyan
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host ""
$dest = "C:\EmamBackup_$(Get-Date -Format 'yyyyMMdd_HHmm')"
New-Item -ItemType Directory -Path $dest -Force | Out-Null
Write-Host "   [~] Backing up Desktop..." -ForegroundColor Yellow
Copy-Item "$env:USERPROFILE\Desktop\*" "$dest\Desktop" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "   [~] Backing up Documents..." -ForegroundColor Yellow
Copy-Item "$env:USERPROFILE\Documents\*" "$dest\Documents" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "   [~] Backing up Pictures..." -ForegroundColor Yellow
Copy-Item "$env:USERPROFILE\Pictures\*" "$dest\Pictures" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host ""
Write-Host "   [OK] Backup saved to: $dest" -ForegroundColor Green
Write-Host ""
Pause
