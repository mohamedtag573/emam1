Write-Host ""
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host "   ||       Windows Full Repair                   ||" -ForegroundColor Cyan
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "   [~] Running SFC scan..." -ForegroundColor Yellow
sfc /scannow
Write-Host ""
Write-Host "   [~] Running DISM repair..." -ForegroundColor Yellow
DISM /Online /Cleanup-Image /RestoreHealth
Write-Host ""
Write-Host "   [OK] System repair complete." -ForegroundColor Green
Write-Host ""
Pause
