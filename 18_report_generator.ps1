# ==============================================================
#   Report Generator -    
#   Version 3.0 | 2026
# ==============================================================

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""; Exit
}

$date       = Get-Date -Format "yyyy-MM-dd HH:mm"
$reportFile = "C:\IT_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"

Clear-Host
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║   Report Generator -         ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "  Running   ..." -ForegroundColor Yellow

# ============   ============
$cs      = Get-WmiObject Win32_ComputerSystem
$os      = Get-WmiObject Win32_OperatingSystem
$bios    = Get-WmiObject Win32_BIOS
$cpu     = Get-WmiObject Win32_Processor
$ram     = Get-WmiObject Win32_PhysicalMemory
$disks   = Get-WmiObject Win32_DiskDrive
$gpu     = Get-WmiObject Win32_VideoController
$net     = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress }
$battery = Get-WmiObject Win32_Battery -EA SilentlyContinue

$totalRAM  = [math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1)
$freeRAM   = [math]::Round((Get-WmiObject Win32_OperatingSystem).FreePhysicalMemory / 1MB / 1024, 1)

$activation = Get-WmiObject SoftwareLicensingProduct -EA SilentlyContinue |
    Where-Object { $_.Name -like "Windows*" -and $_.LicenseStatus -eq 1 }
$actStatus = if ($activation) { "Enabled ✅" } else { " Enabled ❌" }

$netTest = Test-Connection "8.8.8.8" -Count 1 -EA SilentlyContinue
$netStatus = if ($netTest) { "Connected ✅ ($($netTest.ResponseTime)ms)" } else { " Connected ❌" }

$missingDrv = (Get-WmiObject Win32_PnPEntity -EA SilentlyContinue |
    Where-Object { $_.ConfigManagerErrorCode -ne 0 }).Count

# Disk info
$diskRows = ""
Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    $free  = [math]::Round($_.FreeSpace / 1GB, 1)
    $total = [math]::Round($_.Size / 1GB, 1)
    $used  = [math]::Round(($_.Size - $_.FreeSpace) / 1GB, 1)
    $pct   = [math]::Round(($used / $total) * 100)
    $color = if ($pct -gt 90) { "#e74c3c" } elseif ($pct -gt 70) { "#f39c12" } else { "#27ae60" }
    $diskRows += "<tr><td>$($_.DeviceID)</td><td>$total GB</td><td>$used GB</td><td style='color:$color'>$free GB ($pct% )</td></tr>"
}

# RAM Sticks
$ramRows = ""
foreach ($stick in $ram) {
    $ramRows += "<tr><td>$($stick.DeviceLocator)</td><td>$([math]::Round($stick.Capacity/1GB,0)) GB</td><td>$($stick.Speed) MHz</td><td>$($stick.Manufacturer)</td></tr>"
}

# Network
$netRows = ""
foreach ($n in $net) {
    $netRows += "<tr><td>$($n.Description)</td><td>$($n.IPAddress -join ', ')</td><td>$($n.MACAddress)</td></tr>"
}

# Battery
$batterySection = ""
if ($battery) {
    $pct = $battery.EstimatedChargeRemaining
    $color = if ($pct -lt 20) { "#e74c3c" } elseif ($pct -lt 50) { "#f39c12" } else { "#27ae60" }
    $batterySection = "<tr><td>Battery</td><td style='color:$color'>$pct%</td></tr>"
}

# Tech name
$techName = Read-Host "    ( -  Enter )"
if ($techName -eq "") { $techName = "IT Team" }

# ============  HTML ============
$html = @"
<!DOCTYPE html>
<html dir="rtl" lang="ar">
<head>
<meta charset="UTF-8">
<title>  - $($cs.Name)</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { font-family: 'Segoe UI', Tahoma, sans-serif; background: #f0f2f5; color: #333; direction: rtl; }
  .header { background: linear-gradient(135deg, #1a1a2e, #16213e, #0f3460); color: white; padding: 40px; text-align: center; }
  .header h1 { font-size: 2em; margin-bottom: 10px; }
  .header p { opacity: 0.8; font-size: 0.95em; }
  .badge { display: inline-block; background: rgba(255,255,255,0.2); padding: 5px 15px; border-radius: 20px; margin: 5px; font-size: 0.85em; }
  .container { max-width: 1000px; margin: 30px auto; padding: 0 20px; }
  .card { background: white; border-radius: 12px; padding: 25px; margin-bottom: 20px; box-shadow: 0 2px 15px rgba(0,0,0,0.08); }
  .card h2 { color: #1a1a2e; border-bottom: 3px solid #0f3460; padding-bottom: 10px; margin-bottom: 20px; font-size: 1.1em; }
  .card h2 span { margin-left: 8px; }
  table { width: 100%; border-collapse: collapse; }
  th { background: #f8f9fa; padding: 10px 15px; text-align: right; font-weight: 600; color: #555; border-bottom: 2px solid #eee; }
  td { padding: 10px 15px; border-bottom: 1px solid #f0f0f0; }
  tr:last-child td { border-bottom: none; }
  tr:hover td { background: #f8f9fa; }
  .status-ok  { color: #27ae60; font-weight: bold; }
  .status-err { color: #e74c3c; font-weight: bold; }
  .status-warn { color: #f39c12; font-weight: bold; }
  .grid { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }
  .info-item { background: #f8f9fa; padding: 12px 15px; border-radius: 8px; border-right: 4px solid #0f3460; }
  .info-item .label { font-size: 0.8em; color: #888; margin-bottom: 4px; }
  .info-item .value { font-weight: 600; color: #1a1a2e; }
  .footer { text-align: center; padding: 30px; color: #888; font-size: 0.85em; }
  @media print { body { background: white; } .card { box-shadow: none; border: 1px solid #eee; } }
</style>
</head>
<body>

<div class="header">
  <h1>📋  </h1>
  <p>$($cs.Name) | $date</p>
  <br>
  <span class="badge">: $techName</span>
  <span class="badge">$($os.Caption)</span>
  <span class="badge">: $actStatus</span>
</div>

<div class="container">

  <!--   -->
  <div class="card">
    <h2><span>💻</span>  </h2>
    <div class="grid">
      <div class="info-item"><div class="label"> </div><div class="value">$($cs.Manufacturer) $($cs.Model)</div></div>
      <div class="info-item"><div class="label">PC Name</div><div class="value">$($cs.Name)</div></div>
      <div class="info-item"><div class="label">Serial Number</div><div class="value">$($bios.SerialNumber)</div></div>
      <div class="info-item"><div class="label">OS</div><div class="value">$($os.Caption)</div></div>
      <div class="info-item"><div class="label">Build Number</div><div class="value">$($os.BuildNumber)</div></div>
      <div class="info-item"><div class="label">BIOS Version</div><div class="value">$($bios.SMBIOSBIOSVersion)</div></div>
      <div class="info-item"><div class="label"> </div><div class="value">$($os.ConvertToDateTime($os.LastBootUpTime))</div></div>
      <div class="info-item"><div class="label">User </div><div class="value">$env:USERNAME</div></div>
    </div>
  </div>

  <!--   -->
  <div class="card">
    <h2><span>⚡</span>  </h2>
    <table>
      <tr><th></th><th></th></tr>
      <tr><td> Windows</td><td class="$(if($activation){'status-ok'}else{'status-err'})">$actStatus</td></tr>
      <tr><td>Internet</td><td class="$(if($netTest){'status-ok'}else{'status-err'})">$netStatus</td></tr>
      <tr><td> </td><td class="$(if($missingDrv -eq 0){'status-ok'}else{'status-warn'})">$(if($missingDrv -eq 0){'   ✅'}else{"$missingDrv   ⚠️"})</td></tr>
      $batterySection
    </table>
  </div>

  <!-- CPU + RAM -->
  <div class="card">
    <h2><span>🔧</span> CPU Memory</h2>
    <table>
      <tr><th></th><th></th></tr>
      <tr><td>CPU</td><td>$($cpu.Name)</td></tr>
      <tr><td>Cores / Threads</td><td>$($cpu.NumberOfCores)  / $($cpu.NumberOfLogicalProcessors) Thread</td></tr>
      <tr><td></td><td>$($cpu.MaxClockSpeed) MHz</td></tr>
      <tr><td> RAM</td><td>$totalRAM GB</td></tr>
      <tr><td>RAM </td><td>$freeRAM GB</td></tr>
    </table>
    $(if($ramRows -ne "") {
    "<br><table><tr><th>Slot</th><th></th><th></th><th></th></tr>$ramRows</table>"
    })
  </div>

  <!-- Disk -->
  <div class="card">
    <h2><span>💾</span> </h2>
    <table>
      <tr><th></th><th> </th></tr>
      $(foreach ($d in $disks) {
        "<tr><td>Disk $($d.Index)</td><td>$($d.Model) - $([math]::Round($d.Size/1GB,0)) GB</td></tr>"
      })
    </table>
    <br>
    <table>
      <tr><th></th><th></th><th>User</th><th></th></tr>
      $diskRows
    </table>
  </div>

  <!--   -->
  <div class="card">
    <h2><span>🖥️</span>  </h2>
    <table>
      <tr><th></th><th>Memory</th><th></th></tr>
      $(foreach ($g in $gpu) {
        "<tr><td>$($g.Name)</td><td>$([math]::Round($g.AdapterRAM/1MB,0)) MB</td><td>$($g.DriverVersion)</td></tr>"
      })
    </table>
  </div>

  <!-- Network -->
  <div class="card">
    <h2><span>🌐</span> Network</h2>
    <table>
      <tr><th></th><th>IP</th><th>MAC</th></tr>
      $netRows
    </table>
  </div>

</div>

<div class="footer">
  <p>   Report  IT Flash Drive v3.0 | $date | : $techName</p>
</div>

</body>
</html>
"@

$html | Out-File -FilePath $reportFile -Encoding UTF8

#  Report  
Start-Process $reportFile

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║  ✅    Report!                  ║" -ForegroundColor Green
Write-Host "  ║       PDF       ║" -ForegroundColor Yellow
Write-Host "  ║  : $reportFile" -ForegroundColor Gray
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "   PDF:    Ctrl+P ← Save as PDF" -ForegroundColor Cyan

Write-Host ""
Read-Host "  Press Enter to return to menu"
