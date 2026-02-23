# ==============================================================
#   Remote Support - Remote Support Setup
#   Version 3.0 | 2026
# ==============================================================

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""; Exit
}

Clear-Host
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║   Remote Support -            ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# 1. RDP
Write-Host "  >>>  RDP..." -ForegroundColor Yellow
Set-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server" "fDenyTSConnections" 0 -EA SilentlyContinue
Set-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" "UserAuthentication" 0 -EA SilentlyContinue
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -EA SilentlyContinue
netsh advfirewall firewall add rule name="RDP" dir=in action=allow protocol=TCP localport=3389 2>&1 | Out-Null
Write-Host "  [OK] RDP  (Port 3389) ✅" -ForegroundColor Green

# 2. WinRM
Write-Host "  >>>  WinRM..." -ForegroundColor Yellow
Enable-PSRemoting -Force -SkipNetworkProfileCheck 2>&1 | Out-Null
Set-Service WinRM -StartupType Automatic -EA SilentlyContinue
Write-Host "  [OK] WinRM  ✅" -ForegroundColor Green

# 3. Remote Registry
Write-Host "  >>>  Remote Registry..." -ForegroundColor Yellow
Set-Service RemoteRegistry -StartupType Automatic -EA SilentlyContinue
Start-Service RemoteRegistry -EA SilentlyContinue
Write-Host "  [OK] Remote Registry  ✅" -ForegroundColor Green

# 4. RustDesk
Write-Host "  >>>  RustDesk..." -ForegroundColor Yellow
if (-not (Get-Command rustdesk -EA SilentlyContinue)) {
    winget install --id RustDesk.RustDesk --silent --accept-package-agreements --accept-source-agreements 2>&1 | Out-Null
    Write-Host "  [OK] RustDesk   ✅" -ForegroundColor Green
} else {
    Write-Host "  [OK] RustDesk Found  ✅" -ForegroundColor Green
}

# 5.  
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║                           ║" -ForegroundColor Cyan
Write-Host "  ╠══════════════════════════════════════════╣" -ForegroundColor Cyan

$pc   = $env:COMPUTERNAME
$user = $env:USERNAME
$localIP = (Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway } | Select-Object -First 1).IPv4Address.IPAddress

Write-Host "  ║  PC Name : $pc" -ForegroundColor White
Write-Host "  ║  User   : $user" -ForegroundColor White
Write-Host "  ║  IP   : $localIP" -ForegroundColor White
Write-Host "  ║  RDP Port   : 3389" -ForegroundColor White

try {
    $pubIP = (Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 5)
    Write-Host "  ║  IP    : $pubIP" -ForegroundColor Cyan
} catch {
    Write-Host "  ║  IP    : Not available" -ForegroundColor Red
}

Write-Host "  ╠══════════════════════════════════════════╣" -ForegroundColor Cyan
Write-Host "  ║    RDP: mstsc /v:$localIP      ║" -ForegroundColor Yellow
Write-Host "  ║    RustDesk ID                  ║" -ForegroundColor Yellow
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host ""
Read-Host "  Press Enter to return to menu"
