# ==============================================================
#   Driver Backup & Restore -   
#   Version 3.0 | 2026
# ==============================================================

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""; Exit
}

Clear-Host
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║   Driver Backup -           ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "  [1]   ( )" -ForegroundColor White
Write-Host "  [2]   ( )" -ForegroundColor White
Write-Host ""
$op = Read-Host "  "

switch ($op) {

    # ============   ============
    "1" {
        Write-Host ""
        Write-Host "  : E:\Drivers    D:\Backup\Drivers" -ForegroundColor Gray
        $dest = Read-Host "   "

        if (-not (Test-Path $dest)) {
            New-Item -ItemType Directory -Path $dest -Force | Out-Null
        }

        $backupPath = "$dest\Drivers_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        New-Item -ItemType Directory -Path $backupPath -Force | Out-Null

        Write-Host ""
        Write-Host "  Running  ..." -ForegroundColor Yellow

        #   
        Export-WindowsDriver -Online -Destination $backupPath -EA SilentlyContinue | Out-Null

        # 
        $count = (Get-ChildItem $backupPath -Directory).Count
        $size  = [math]::Round((Get-ChildItem $backupPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB, 1)

        Write-Host ""
        Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "  ║  ✅    $count                ║" -ForegroundColor Green
        Write-Host "  ║   : $size MB                        ║" -ForegroundColor White
        Write-Host "  ║  : $backupPath" -ForegroundColor Gray
        Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Green
    }

    # ============   ============
    "2" {
        Write-Host ""
        $src = Read-Host "     "

        if (-not (Test-Path $src)) {
            Write-Host "  [!]  Not found" -ForegroundColor Red
            pause; exit
        }

        Write-Host ""
        Write-Host "  Running  ..." -ForegroundColor Yellow

        $drivers = Get-ChildItem $src -Recurse -Filter "*.inf" -EA SilentlyContinue
        $installed = 0
        $failed    = 0

        foreach ($drv in $drivers) {
            try {
                pnputil /add-driver "$($drv.FullName)" /install 2>&1 | Out-Null
                $installed++
            } catch {
                $failed++
            }
        }

        Write-Host ""
        Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "  ║  ✅    $installed          ║" -ForegroundColor Green
        if ($failed -gt 0) {
        Write-Host "  ║  ⚠️  Failed $failed                  ║" -ForegroundColor Yellow
        }
        Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Green
    }

    default { Write-Host "  [!]   " -ForegroundColor Red }
}


Write-Host ""
Read-Host "  Press Enter to return to menu"
