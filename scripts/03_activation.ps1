Write-Host ""
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host "   ||       Activate Windows + Office             ||" -ForegroundColor Cyan
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "   [~] Running activation..." -ForegroundColor Yellow
Write-Host ""
iex(New-Object Net.WebClient).DownloadString('https://massgrave.dev/get')
Write-Host ""
Pause
