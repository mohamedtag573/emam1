# ==============================================================
#   Disk Health - Disk Health Check (SMART)
#   Version 3.0 | 2026
# ==============================================================

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""; Exit
}

$reportFile = "C:\IT_DiskHealth_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

function Log($msg, $color = "White") {
    Write-Host "  $msg" -ForegroundColor $color
    $msg | Out-File $reportFile -Append -Encoding UTF8
}

Clear-Host
Log "╔══════════════════════════════════════════╗" "Cyan"
Log "║   Disk Health - Disk Health Check          ║" "Cyan"
Log "╚══════════════════════════════════════════╝" "Cyan"

# SMART Status
Log ">>> [1] SMART Status:" "Yellow"
$disks = Get-WmiObject Win32_DiskDrive
foreach ($disk in $disks) {
    $sizeGB = [math]::Round($disk.Size / 1GB, 0)
    Log "  Disk: $($disk.Model) ($sizeGB GB)" "White"
    try {
        $smart = Get-WmiObject -Namespace "root\wmi" -Class "MSStorageDriver_FailurePredictStatus" -EA Stop
        if ($smart.PredictFailure) {
            Log "  SMART : Warning - Disk  Failed !" "Red"
        } else {
            Log "  SMART : Disk  " "Green"
        }
    } catch {
        Log "  SMART : Not available" "Gray"
    }
    Log "  ────────────────────────────────────" "DarkGray"
}

#  
Log ">>> [2]  :" "Yellow"
Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    $free  = [math]::Round($_.FreeSpace / 1GB, 1)
    $total = [math]::Round($_.Size / 1GB, 1)
    $used  = [math]::Round(($_.Size - $_.FreeSpace) / 1GB, 1)
    $pct   = [math]::Round(($used / $total) * 100)
    $color = if ($pct -gt 90) { "Red" } elseif ($pct -gt 75) { "Yellow" } else { "Green" }
    $barF  = [math]::Round($pct / 5)
    $barE  = 20 - $barF
    $bar   = "[" + ("X" * $barF) + ("-" * $barE) + "]"
    Log "  $($_.DeviceID)  $bar  $pct%  |  : $free GB  $total GB" $color
}

# CHKDSK
Log ">>> [3]  CHKDSK   C:..." "Yellow"
$chk = chkdsk C: 2>&1 | Out-String
$chk | Out-File $reportFile -Append -Encoding UTF8
if ($chk -match "no problems") {
    Log "  Disk  -  " "Green"
} else {
    Log "    -  " "Red"
}

# Temp Files
Log ">>> [4]   Temp:" "Yellow"
$tempSize = (Get-ChildItem $env:TEMP -Recurse -EA SilentlyContinue | Measure-Object -Property Length -Sum).Sum
$tempMB   = [math]::Round($tempSize / 1MB, 1)
$color    = if ($tempMB -gt 1000) { "Red" } elseif ($tempMB -gt 500) { "Yellow" } else { "Green" }
Log "  Temp Files: $tempMB MB" $color
if ($tempMB -gt 500) { Log "    Cleanup ( 6)" "Yellow" }

Log "╔══════════════════════════════════════════╗" "Cyan"
Log "║  Report: $reportFile" "Green"
Log "╚══════════════════════════════════════════╝" "Cyan"

Write-Host ""
Read-Host "  Press Enter to return to menu"
