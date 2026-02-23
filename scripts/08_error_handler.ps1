Write-Host ""
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host "   ||       Auto Error Fix                        ||" -ForegroundColor Cyan
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "   [~] Fixing common Windows errors..." -ForegroundColor Yellow
Write-Host ""
Write-Host "   [~] Resetting Windows Update components..." -ForegroundColor Cyan
net stop wuauserv 2>$null
net stop cryptSvc 2>$null
net stop bits 2>$null
net stop msiserver 2>$null
Remove-Item "C:\Windows\SoftwareDistribution" -Recurse -Force -ErrorAction SilentlyContinue
net start wuauserv 2>$null
net start cryptSvc 2>$null
net start bits 2>$null
net start msiserver 2>$null
Write-Host "   [OK] Windows Update reset." -ForegroundColor Green

Write-Host "   [~] Fixing network..." -ForegroundColor Cyan
netsh winsock reset | Out-Null
netsh int ip reset | Out-Null
ipconfig /flushdns | Out-Null
Write-Host "   [OK] Network fixed." -ForegroundColor Green

Write-Host ""
Write-Host "   [OK] All errors fixed. Please restart your PC." -ForegroundColor Green
Write-Host ""
Pause
