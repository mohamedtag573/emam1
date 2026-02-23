Write-Host ""
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host "   ||       Windows Update                        ||" -ForegroundColor Cyan
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "   [~] Installing PSWindowsUpdate module..." -ForegroundColor Yellow
Install-Module PSWindowsUpdate -Force -Confirm:$false 2>$null
Write-Host "   [~] Checking for updates..." -ForegroundColor Yellow
Get-WindowsUpdate -Install -AcceptAll -AutoReboot
Write-Host ""
Write-Host "   [OK] Windows Update completed." -ForegroundColor Green
Write-Host ""
Pause
