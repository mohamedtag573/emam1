Write-Host ""
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host "   ||       Post-Install Check                    ||" -ForegroundColor Cyan
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "   [~] Checking installed apps..." -ForegroundColor Yellow
Write-Host ""
$apps = @("chrome","firefox","vlc","7z")
foreach ($app in $apps) {
    $found = Get-Command $app -ErrorAction SilentlyContinue
    if ($found) {
        Write-Host "   [OK] $app is installed." -ForegroundColor Green
    } else {
        Write-Host "   [!] $app not found." -ForegroundColor Red
    }
}
Write-Host ""
Write-Host "   [OK] Post-install check complete." -ForegroundColor Green
Write-Host ""
Pause
