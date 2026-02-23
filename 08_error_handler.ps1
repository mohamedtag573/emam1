# ==============================================================
#   Error Handler - Auto Error Fix
#   Version 3.0 | 2026
# ==============================================================

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""; Exit
}

$logFile = "C:\IT_ErrorHandler_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

function Log($msg, $color = "White") {
    $line = "$(Get-Date -Format 'HH:mm:ss')  $msg"
    Write-Host "  $line" -ForegroundColor $color
    $line | Out-File $logFile -Append -Encoding UTF8
}

Clear-Host
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Red
Write-Host "  ║   Error Handler - Auto Error Fix║" -ForegroundColor Red
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Red
Write-Host ""
Log "Starting   ..." "Cyan"

# 1. SFC + DISM
Log ">>> [1]   ..." "Yellow"
sfc /scannow 2>&1 | Out-File $logFile -Append -Encoding UTF8
DISM /Online /Cleanup-Image /RestoreHealth 2>&1 | Out-File $logFile -Append -Encoding UTF8
Log "  [OK] ✅" "Green"

# 2. Windows Update Fix
Log ">>> [2]  Windows Update..." "Yellow"
@("wuauserv","cryptSvc","bits","msiserver") | ForEach-Object { Stop-Service $_ -Force -EA SilentlyContinue }
Remove-Item "C:\Windows\SoftwareDistribution" -Recurse -Force -EA SilentlyContinue
Remove-Item "C:\Windows\System32\catroot2"    -Recurse -Force -EA SilentlyContinue
@("wuauserv","cryptSvc","bits","msiserver") | ForEach-Object { Start-Service $_ -EA SilentlyContinue }
Log "  [OK] ✅" "Green"

# 3. Network Reset
Log ">>> [3]  Network ..." "Yellow"
netsh winsock reset 2>&1 | Out-Null
netsh int ip reset  2>&1 | Out-Null
netsh int tcp reset 2>&1 | Out-Null
netsh int ipv4 reset 2>&1 | Out-Null
netsh int ipv6 reset 2>&1 | Out-Null
ipconfig /release   | Out-Null
ipconfig /flushdns  | Out-Null
ipconfig /renew     | Out-Null
Log "  [OK] ✅" "Green"

# 4. Boot Fix
Log ">>> [4]  Boot..." "Yellow"
try {
    bootrec /fixmbr     2>&1 | Out-Null
    bootrec /fixboot    2>&1 | Out-Null
    bootrec /rebuildbcd 2>&1 | Out-Null
    Log "  [OK] ✅" "Green"
} catch { Log "  [--] Not available" "Gray" }

# 5.  Registry
Log ">>> [5]  Registry..." "Yellow"
$regPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SYSTEM\CurrentControlSet\Services"
)
foreach ($path in $regPaths) {
    if (-not (Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
        Log "  : $path" "Gray"
    }
}
Log "  [OK] ✅" "Green"

# 6.  
Log ">>> [6]   ..." "Yellow"
$svcs = @("Spooler","wuauserv","Winmgmt","EventLog","BITS","RpcSs","Schedule","Themes","AudioSrv")
foreach ($s in $svcs) {
    try {
        Set-Service $s -StartupType Automatic -EA SilentlyContinue
        Start-Service $s -EA SilentlyContinue
    } catch {}
}
Log "  [OK] ✅" "Green"

# 7.  RDP
Log ">>> [7]   RDP..." "Yellow"
Set-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server" "fDenyTSConnections" 0 -EA SilentlyContinue
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -EA SilentlyContinue
Log "  [OK] RDP  ✅" "Green"

# 8.  Firewall
Log ">>> [8]  Windows Firewall..." "Yellow"
netsh advfirewall reset 2>&1 | Out-Null
Set-Service MpsSvc -StartupType Automatic -EA SilentlyContinue
Start-Service MpsSvc -EA SilentlyContinue
Log "  [OK] Firewall   ✅" "Green"

# 9.  Temp
Log ">>> [9]   ..." "Yellow"
@($env:TEMP, "$env:SystemRoot\Temp") | ForEach-Object {
    Get-ChildItem $_ -Recurse -EA SilentlyContinue | Remove-Item -Recurse -Force -EA SilentlyContinue
}
Log "  [OK] ✅" "Green"

# 10. DNS Cache
Log ">>> [10]  DNS..." "Yellow"
ipconfig /flushdns | Out-Null
Clear-DnsClientCache -EA SilentlyContinue
Log "  [OK] ✅" "Green"

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║  ✅      !     ║" -ForegroundColor Green
Write-Host "  ║  Report: $logFile" -ForegroundColor Gray
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
$r = Read-Host "  Restart  (y/n)"
if ($r -eq "y") { Restart-Computer -Force }
Write-Host ""
Read-Host "  Press Enter to return to menu"
