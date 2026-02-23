# ==============================================================
#   Rename PC - Rename PC by Serial
#   Version 3.0 | 2026
# ==============================================================

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""; Exit
}

Clear-Host
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║   Rename PC -                ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$bios    = Get-WmiObject Win32_BIOS
$cs      = Get-WmiObject Win32_ComputerSystem
$serial  = $bios.SerialNumber.Trim() -replace '[^a-zA-Z0-9]', ''
$model   = $cs.Model.Trim() -replace '\s+', '-' -replace '[^a-zA-Z0-9\-]', ''
$current = $env:COMPUTERNAME

Write-Host "     : $current" -ForegroundColor Gray
Write-Host "  Serial Number : $serial" -ForegroundColor White
Write-Host "         : $model" -ForegroundColor White
Write-Host ""
Write-Host "   :" -ForegroundColor Yellow
Write-Host "  [1] IT-{Serial}   →  : IT-ABC123" -ForegroundColor White
Write-Host "  [2] PC-{Serial}   →  : PC-ABC123" -ForegroundColor White
Write-Host "  [3]  " -ForegroundColor White
Write-Host ""

$choice = Read-Host "   (1/2/3)"

switch ($choice) {
    "1" { $newName = "IT-$serial" }
    "2" { $newName = "PC-$serial" }
    "3" { $newName = Read-Host "    " }
    default { $newName = "IT-$serial" }
}

#    (15  max)
if ($newName.Length -gt 15) { $newName = $newName.Substring(0, 15) }

Write-Host ""
Write-Host "    : $newName" -ForegroundColor Green
Write-Host ""
$confirm = Read-Host "    (y/n)"

if ($confirm -eq "y") {
    try {
        Rename-Computer -NewName $newName -Force -EA Stop
        Write-Host ""
        Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "  ║  ✅     : $newName        ║" -ForegroundColor Green
        Write-Host "  ║  ⚠️   Restart         ║" -ForegroundColor Yellow
        Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Green
        Write-Host ""
        $r = Read-Host "  Restart  (y/n)"
        if ($r -eq "y") { Restart-Computer -Force }
    } catch {
        Write-Host "  [!] Error: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "   " -ForegroundColor Gray
}

Write-Host ""
Read-Host "  Press Enter to return to menu"
