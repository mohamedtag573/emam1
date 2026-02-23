if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""; Exit
}

$logFile = "C:\IT_PostCheck_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$fixed=@(); $failed=@()
function Log($msg, $color="White") {
    $line = "$(Get-Date -Format 'HH:mm:ss')  $msg"
    Write-Host "  $line" -ForegroundColor $color
    $line | Out-File $logFile -Append -Encoding UTF8
}
Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║  POST-INSTALL CHECK                                  ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Log ">>> OS Info..." "Yellow"
$os = Get-WmiObject Win32_OperatingSystem
Log "  [OK] $($os.Caption) Build $($os.BuildNumber)" "Green"

Log ">>> Activation..." "Yellow"
$act = Get-WmiObject SoftwareLicensingProduct -EA SilentlyContinue | Where-Object { $_.Name -like "Windows*" -and $_.LicenseStatus -eq 1 }
if ($act) { Log "  [OK] Windows Activated" "Green" }
else {
    & slmgr.vbs /ipk "W269N-WFGWX-YVC9B-4J6C9-T83GX" 2>&1 | Out-Null
    & slmgr.vbs /skms kms8.msguides.com 2>&1 | Out-Null
    & slmgr.vbs /ato 2>&1 | Out-Null; Start-Sleep 3
    $r2 = Get-WmiObject SoftwareLicensingProduct -EA SilentlyContinue | Where-Object { $_.Name -like "Windows*" -and $_.LicenseStatus -eq 1 }
    if ($r2) { Log "  [OK] Activated!" "Green"; $fixed+="Windows activation" }
    else { Log "  [!] Not activated" "Red"; $failed+="Windows activation" }
}

Log ">>> Key Apps..." "Yellow"
@("Chrome","RustDesk","7-Zip") | ForEach-Object {
    $found = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" -EA SilentlyContinue | Where-Object { $_.DisplayName -like "*$_*" }
    if ($found) { Log "  [OK] $_ installed" "Green" }
    else { Log "  [!] $_ missing" "Yellow"; $failed+="$_ not found" }
}

Log ">>> Drivers..." "Yellow"
$miss = (Get-WmiObject Win32_PnPEntity -EA SilentlyContinue | Where-Object { $_.ConfigManagerErrorCode -ne 0 }).Count
if ($miss -gt 0) { Log "  [!] $miss missing drivers" "Red"; $failed+="$miss missing drivers" }
else { Log "  [OK] All drivers OK" "Green" }

Log ">>> Network..." "Yellow"
$net = Test-Connection "8.8.8.8" -Count 1 -EA SilentlyContinue
if ($net) { Log "  [OK] Connected $($net.ResponseTime)ms" "Green" }
else { Log "  [!] No Internet" "Red"; $failed+="No Internet" }

Log ">>> RDP..." "Yellow"
$rdp = (Get-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server" -EA SilentlyContinue).fDenyTSConnections
if ($rdp -eq 0) { Log "  [OK] RDP Enabled" "Green" }
else {
    Set-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server" "fDenyTSConnections" 0
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -EA SilentlyContinue
    Log "  [OK] RDP Enabled!" "Green"; $fixed+="RDP enabled"
}

Log ">>> Disk Space..." "Yellow"
Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    $free=[math]::Round($_.FreeSpace/1GB,1); $total=[math]::Round($_.Size/1GB,1)
    $pct=[math]::Round(($_.FreeSpace/$_.Size)*100)
    $col=if($pct-lt 10){"Red"}elseif($pct-lt 20){"Yellow"}else{"Green"}
    Log "  $($_.DeviceID): $total GB | Free: $free GB ($pct%)" $col
}

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
if ($failed.Count -eq 0) { Write-Host "  ║  [OK] System is 100% Ready!                         ║" -ForegroundColor Green }
else { foreach ($f in $failed) { Write-Host "  ║  [X] $f" -ForegroundColor Red } }
if ($fixed.Count -gt 0) { foreach ($f in $fixed) { Write-Host "  ║  [FIX] $f" -ForegroundColor Green } }
Write-Host "  ║  Report: $logFile" -ForegroundColor Gray
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host ""
Read-Host "  Press Enter to return to menu"
