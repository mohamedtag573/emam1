# ==============================================================
#   System Repair - Windows Full Repair
#   Version 3.0 | 2026
# ==============================================================

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""; Exit
}

$logFile = "C:\IT_Repair_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

function Log($msg, $color = "White") {
    $line = "$(Get-Date -Format 'HH:mm:ss')  $msg"
    Write-Host "  $line" -ForegroundColor $color
    $line | Out-File $logFile -Append -Encoding UTF8
}

Clear-Host
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║   System Repair - Windows Full Repair ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

# 1. SFC
Log ">>> [1]   Windows (SFC)..." "Yellow"
$sfc = sfc /scannow 2>&1
$sfc | Out-File $logFile -Append -Encoding UTF8
Log "  [OK] SFC  ✅" "Green"

# 2. DISM
Log ">>> [2]   Windows (DISM)..." "Yellow"
DISM /Online /Cleanup-Image /CheckHealth   2>&1 | Out-File $logFile -Append -Encoding UTF8
DISM /Online /Cleanup-Image /ScanHealth    2>&1 | Out-File $logFile -Append -Encoding UTF8
DISM /Online /Cleanup-Image /RestoreHealth 2>&1 | Out-File $logFile -Append -Encoding UTF8
Log "  [OK] DISM  ✅" "Green"

# 3.  Windows Update
Log ">>> [3]  Windows Update..." "Yellow"
$wuSvc = @("wuauserv","cryptSvc","bits","msiserver")
foreach ($s in $wuSvc) { Stop-Service $s -Force -EA SilentlyContinue }
Remove-Item "C:\Windows\SoftwareDistribution" -Recurse -Force -EA SilentlyContinue
Remove-Item "C:\Windows\System32\catroot2"    -Recurse -Force -EA SilentlyContinue
foreach ($s in $wuSvc) { Start-Service $s -EA SilentlyContinue }
Log "  [OK] Windows Update   ✅" "Green"

# 4.  Network
Log ">>> [4]  Network..." "Yellow"
netsh winsock reset    2>&1 | Out-Null
netsh int ip reset     2>&1 | Out-Null
netsh int tcp reset    2>&1 | Out-Null
ipconfig /release      | Out-Null
ipconfig /flushdns     | Out-Null
ipconfig /renew        | Out-Null
Log "  [OK] Network   ✅" "Green"

# 5.  Boot
Log ">>> [5]  Boot..." "Yellow"
try {
    bootrec /fixmbr     2>&1 | Out-Null
    bootrec /fixboot    2>&1 | Out-Null
    bootrec /rebuildbcd 2>&1 | Out-Null
    Log "  [OK] Boot   ✅" "Green"
} catch {
    Log "  [--] Boot repair Not available (UEFI)" "Gray"
}

# 6.   
Log ">>> [6]   ..." "Yellow"
$svcs = @("Spooler","wuauserv","Winmgmt","EventLog","BITS","RpcSs","Schedule")
foreach ($s in $svcs) {
    try {
        Set-Service  $s -StartupType Automatic -EA SilentlyContinue
        Start-Service $s -EA SilentlyContinue
        Log "   : $s" "Gray"
    } catch {}
}
Log "  [OK]    ✅" "Green"

# 7.  Printer Spooler
Log ">>> [7]  Printer Spooler..." "Yellow"
Stop-Service Spooler -Force -EA SilentlyContinue
Get-ChildItem "C:\Windows\System32\spool\PRINTERS" -EA SilentlyContinue |
    Remove-Item -Force -Recurse -EA SilentlyContinue
Start-Service Spooler -EA SilentlyContinue
Log "  [OK] Printer Spooler   ✅" "Green"

# 8.  Temp
Log ">>> [8]   ..." "Yellow"
@($env:TEMP, "$env:SystemRoot\Temp", "$env:LOCALAPPDATA\Temp") | ForEach-Object {
    Get-ChildItem $_ -Recurse -EA SilentlyContinue | Remove-Item -Recurse -Force -EA SilentlyContinue
}
Log "  [OK]   ✅" "Green"

# 9. CHKDSK ()
Log ">>> [9]  Disk (CHKDSK)..." "Yellow"
$do = Read-Host "   CHKDSK   Restart (y/n)"
if ($do -eq "y") {
    echo Y | chkdsk C: /f /r /x 2>&1 | Out-Null
    Log "  [OK] CHKDSK    Restart ✅" "Green"
} else {
    Log "  [--]   CHKDSK" "Gray"
}

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║  ✅  Completed  !              ║" -ForegroundColor Green
Write-Host "  ║  Report: $logFile" -ForegroundColor Gray
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
$r = Read-Host "  Restart    (y/n)"
if ($r -eq "y") { Restart-Computer -Force }
Write-Host ""
Read-Host "  Press Enter to return to menu"
