if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""; Exit
}

$logFile = "C:\IT_PreCheck_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$issues  = @()
function Log($msg, $color="White") {
    $line = "$(Get-Date -Format 'HH:mm:ss')  $msg"
    Write-Host "  $line" -ForegroundColor $color
    $line | Out-File $logFile -Append -Encoding UTF8
}
Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║  PRE-INSTALL CHECK                                   ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Log ">>> [1] RAM..." "Yellow"
$ram = [math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory/1GB,1)
if ($ram -lt 4) { Log "  [!] RAM=$ram GB - Below 4GB minimum" "Red"; $issues+="Low RAM: $ram GB" }
else { Log "  [OK] RAM = $ram GB" "Green" }

Log ">>> [2] Disk..." "Yellow"
$disk = Get-WmiObject Win32_DiskDrive | Select-Object -First 1
$diskGB = [math]::Round($disk.Size/1GB)
$diskType = if ($disk.Model -match "SSD|NVMe") { "SSD" } else { "HDD" }
if ($diskGB -lt 64) { Log "  [!] Disk=$diskGB GB ($diskType) - Below 64GB" "Red"; $issues+="Small Disk: $diskGB GB" }
else { Log "  [OK] Disk = $diskGB GB ($diskType)" "Green" }

Log ">>> [3] CPU..." "Yellow"
$cpu = Get-WmiObject Win32_Processor
Log "  [OK] $($cpu.Name) | $($cpu.NumberOfCores) Cores | $($cpu.MaxClockSpeed) MHz" "Green"

Log ">>> [4] Firmware..." "Yellow"
$fw = (Get-ItemProperty "HKLM:\System\CurrentControlSet\Control" -Name PEFirmwareType -EA SilentlyContinue).PEFirmwareType
if ($fw -eq 2) { Log "  [OK] UEFI - Will use GPT" "Green" }
else { Log "  [OK] Legacy BIOS - Will use MBR" "Green" }

Log ">>> [5] TPM..." "Yellow"
try {
    $tpm = Get-WmiObject -Namespace "root\cimv2\security\microsofttpm" -Class Win32_Tpm -EA Stop
    if ($tpm.IsEnabled_InitialValue) { Log "  [OK] TPM Enabled - Win11 Ready" "Green" }
    else { Log "  [!] TPM Disabled - Enable in BIOS" "Yellow"; $issues+="TPM Disabled" }
} catch { Log "  [!] No TPM found" "Yellow"; $issues+="No TPM" }

Log ">>> [6] Internet..." "Yellow"
$net = Test-Connection "8.8.8.8" -Count 1 -EA SilentlyContinue
if ($net) { Log "  [OK] Internet OK - $($net.ResponseTime)ms" "Green" }
else { Log "  [!] No Internet" "Yellow"; $issues+="No Internet" }

$bat = Get-WmiObject Win32_Battery -EA SilentlyContinue
if ($bat) {
    $pct=$bat.EstimatedChargeRemaining
    $col=if($pct-lt 20){"Red"}elseif($pct-lt 50){"Yellow"}else{"Green"}
    Log ">>> Battery: $pct%" $col
    if ($pct-lt 20) { $issues+="Low Battery: $pct%" }
}

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
if ($issues.Count -eq 0) {
    Write-Host "  ║  [OK] Device is READY for installation!             ║" -ForegroundColor Green
} else {
    Write-Host "  ║  [!] Warnings:                                      ║" -ForegroundColor Yellow
    foreach ($i in $issues) { Write-Host "  ║    - $i" -ForegroundColor Yellow }
    Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    $c = Read-Host "  Continue anyway? (y/n)"
    if ($c -ne "y") { exit 1 }
}
Write-Host "  ║  Report: $logFile" -ForegroundColor Gray
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host ""
Read-Host "  Press Enter to return to menu"
