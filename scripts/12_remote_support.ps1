Write-Host ""
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host "   ||       Remote Support                        ||" -ForegroundColor Cyan
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "   [~] Launching AnyDesk..." -ForegroundColor Yellow
$anydesk = "https://download.anydesk.com/AnyDesk.exe"
$out = "$env:TEMP\AnyDesk.exe"
(New-Object Net.WebClient).DownloadFile($anydesk, $out)
Start-Process $out
Write-Host "   [OK] AnyDesk launched." -ForegroundColor Green
Write-Host ""
Pause
