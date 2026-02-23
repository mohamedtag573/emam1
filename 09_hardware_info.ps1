# ==============================================================
#   Hardware Info - Full Hardware Report
#   Version 3.0 | 2026
# ==============================================================

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""; Exit
}

$reportFile = "C:\IT_Hardware_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

function Log($msg, $color = "White") {
    Write-Host "  $msg" -ForegroundColor $color
    $msg | Out-File $reportFile -Append -Encoding UTF8
}

Clear-Host
Log "╔══════════════════════════════════════════════════╗" "Cyan"
Log "║   Hardware Report - Full Hardware Report      ║" "Cyan"
Log "║   $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')                      ║" "Cyan"
Log "╚══════════════════════════════════════════════════╝" "Cyan"

# 1. System
Log "`n[1]  :" "Yellow"
$cs = Get-WmiObject Win32_ComputerSystem
$os = Get-WmiObject Win32_OperatingSystem
$bios = Get-WmiObject Win32_BIOS
Log "        : $($cs.Manufacturer)" "White"
Log "        : $($cs.Model)" "White"
Log "  PC Name   : $($cs.Name)" "White"
Log "  OS : $($os.Caption)" "White"
Log "  Build         : $($os.BuildNumber)" "White"
Log "      : $($os.ConvertToDateTime($os.LastBootUpTime))" "White"
Log "  Serial BIOS  : $($bios.SerialNumber)" "White"
Log "  BIOS Version : $($bios.SMBIOSBIOSVersion)" "White"

# 2. CPU
Log "`n[2] CPU (CPU):" "Yellow"
$cpu = Get-WmiObject Win32_Processor
Log "          : $($cpu.Name)" "White"
Log "  Cores        : $($cpu.NumberOfCores)" "White"
Log "  Threads      : $($cpu.NumberOfLogicalProcessors)" "White"
Log "         : $($cpu.MaxClockSpeed) MHz" "White"
$load = $cpu.LoadPercentage
$loadColor = if ($load -gt 90) { "Red" } elseif ($load -gt 70) { "Yellow" } else { "Green" }
Log "    : $load%" $loadColor

# 3. RAM
Log "`n[3] Memory (RAM):" "Yellow"
$totalRAM = [math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory/1GB, 1)
$freeRAM  = [math]::Round((Get-WmiObject Win32_OperatingSystem).FreePhysicalMemory/1MB, 1)
$usedRAM  = [math]::Round($totalRAM - $freeRAM/1024, 1)
Log "       : $totalRAM GB" "White"
Log "  User     : $usedRAM GB" "White"
Log "         : $freeRAM MB" "White"
$ramSticks = Get-WmiObject Win32_PhysicalMemory
foreach ($stick in $ramSticks) {
    Log "  Slot: $($stick.DeviceLocator) | $([math]::Round($stick.Capacity/1GB,0)) GB | $($stick.Speed) MHz | $($stick.Manufacturer)" "Gray"
}

# 4. Disk
Log "`n[4] :" "Yellow"
$disks = Get-WmiObject Win32_DiskDrive
foreach ($d in $disks) {
    $type = if ($d.MediaType -match "SSD" -or $d.Model -match "SSD|NVMe") { "SSD" } else { "HDD" }
    Log "  $($d.Model)  |  $([math]::Round($d.Size/1GB,0)) GB  |  $type  |  S/N: $($d.SerialNumber)" "White"
}
Log "  ---  ---" "Gray"
Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    $free  = [math]::Round($_.FreeSpace/1GB,1)
    $total = [math]::Round($_.Size/1GB,1)
    $used  = [math]::Round(($_.Size-$_.FreeSpace)/1GB,1)
    $pct   = [math]::Round(($used/$total)*100)
    $c = if ($pct -gt 90) { "Red" } elseif ($pct -gt 70) { "Yellow" } else { "Green" }
    Log "  $($_.DeviceID)  : $total GB  : $used GB  : $free GB  ($pct%)" $c
}

# 5. GPU
Log "`n[5]   (GPU):" "Yellow"
Get-WmiObject Win32_VideoController | ForEach-Object {
    Log "  $($_.Name)  |  $([math]::Round($_.AdapterRAM/1MB,0)) MB  |  Driver: $($_.DriverVersion)" "White"
}

# 6. Network
Log "`n[6] Network:" "Yellow"
Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress } | ForEach-Object {
    Log "  $($_.Description)" "White"
    Log "    IP  : $($_.IPAddress -join ', ')" "Gray"
    Log "    MAC : $($_.MACAddress)" "Gray"
    Log "    DNS : $($_.DNSServerSearchOrder -join ', ')" "Gray"
}

# 7. Temperature
Log "`n[7]  :" "Yellow"
try {
    $temps = Get-WmiObject MSAcpi_ThermalZoneTemperature -Namespace "root/wmi" -EA Stop
    foreach ($t in $temps) {
        $c = [math]::Round(($t.CurrentTemperature - 2732) / 10, 1)
        $color = if ($c -gt 85) { "Red" } elseif ($c -gt 65) { "Yellow" } else { "Green" }
        Log "  $($t.InstanceName): $c °C" $color
    }
} catch {
    Log "  Not available   " "Gray"
}

# 8. Battery
Log "`n[8] Battery:" "Yellow"
$bat = Get-WmiObject Win32_Battery -EA SilentlyContinue
if ($bat) {
    $pct = $bat.EstimatedChargeRemaining
    $c = if ($pct -lt 20) { "Red" } elseif ($pct -lt 50) { "Yellow" } else { "Green" }
    Log "     : $pct%" $c
    Log "    : $($bat.Status)" "White"
    Log "     : $($bat.EstimatedRunTime) " "White"
} else {
    Log "    -  " "Gray"
}

Log "`n╔══════════════════════════════════════════════════╗" "Cyan"
Log "║  ✅  Report  : $reportFile" "Green"
Log "╚══════════════════════════════════════════════════╝" "Cyan"

Write-Host ""
Read-Host "  Press Enter to return to menu"
