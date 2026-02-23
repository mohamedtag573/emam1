Write-Host ""
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host "   ||       WiFi Passwords                        ||" -ForegroundColor Cyan
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "   [~] Getting saved WiFi passwords..." -ForegroundColor Yellow
Write-Host ""
$profiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object {
    ($_ -split ":")[1].Trim()
}
foreach ($p in $profiles) {
    $pass = netsh wlan show profile name="$p" key=clear | Select-String "Key Content"
    if ($pass) {
        $pw = ($pass -split ":")[1].Trim()
        Write-Host "   WiFi  : $p" -ForegroundColor Cyan
        Write-Host "   Pass  : $pw" -ForegroundColor Green
        Write-Host "   -----------------------------------------------" -ForegroundColor DarkGray
    }
}
Write-Host ""
Pause
