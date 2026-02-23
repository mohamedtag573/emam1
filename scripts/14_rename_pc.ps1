Write-Host ""
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host "   ||       Rename PC by Serial                   ||" -ForegroundColor Cyan
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host ""
$serial = (Get-WmiObject Win32_BIOS).SerialNumber.Trim()
Write-Host "   Serial : $serial" -ForegroundColor White
Write-Host "   [~] Renaming PC to: $serial" -ForegroundColor Yellow
Rename-Computer -NewName $serial -Force
Write-Host "   [OK] PC renamed. Please restart." -ForegroundColor Green
Write-Host ""
Pause
