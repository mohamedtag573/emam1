Write-Host ""
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host "   ||       Driver Backup & Restore               ||" -ForegroundColor Cyan
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host ""
$dest = "C:\DriversBackup_$(Get-Date -Format 'yyyyMMdd')"
Write-Host "   [~] Backing up drivers to $dest ..." -ForegroundColor Yellow
Export-WindowsDriver -Online -Destination $dest
Write-Host "   [OK] Drivers backed up successfully." -ForegroundColor Green
Write-Host ""
Pause
