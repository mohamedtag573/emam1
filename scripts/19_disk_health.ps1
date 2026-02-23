Write-Host ""
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host "   ||       Disk Health (SMART)                   ||" -ForegroundColor Cyan
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "   [~] Checking disk health..." -ForegroundColor Yellow
Write-Host ""
Get-WmiObject Win32_DiskDrive | ForEach-Object {
    Write-Host "   Disk  : $($_.Caption)" -ForegroundColor White
    Write-Host "   Size  : $([math]::Round($_.Size/1GB)) GB" -ForegroundColor White
    Write-Host "   Status: $($_.Status)" -ForegroundColor Green
    Write-Host "   -----------------------------------------------" -ForegroundColor DarkGray
}
Write-Host ""
Pause
