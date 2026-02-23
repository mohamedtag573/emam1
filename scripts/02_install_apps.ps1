Write-Host ""
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host "   ||       Auto Install Apps                     ||" -ForegroundColor Cyan
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "   [~] Installing Winget apps..." -ForegroundColor Yellow
Write-Host ""

$apps = @(
    "Google.Chrome",
    "Mozilla.Firefox",
    "7zip.7zip",
    "VideoLAN.VLC",
    "Microsoft.VCRedist.2015+.x64",
    "Adobe.Acrobat.Reader.64-bit"
)

foreach ($app in $apps) {
    Write-Host "   [+] Installing $app ..." -ForegroundColor Cyan
    winget install --id $app -e --silent --accept-package-agreements --accept-source-agreements 2>$null
    Write-Host "   [OK] $app done." -ForegroundColor Green
}

Write-Host ""
Write-Host "   [OK] All apps installed successfully." -ForegroundColor Green
Write-Host ""
Pause
