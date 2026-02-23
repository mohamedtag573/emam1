# ==============================================================
#   Backup Data - Emergency Data Backup
#   Version 3.0 | 2026
# ==============================================================

Clear-Host
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║   Backup Data - Emergency Data Backup     ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

#  
Write-Host "   :" -ForegroundColor Gray
Write-Host "    C:\Users\Ahmed   ( )" -ForegroundColor Gray
Write-Host "    C:\Users         ( User)" -ForegroundColor Gray
Write-Host "    D:\              ( )" -ForegroundColor Gray
Write-Host ""
$source = Read-Host "    "

if (-not (Test-Path $source)) {
    Write-Host "  [!]  Not found: $source" -ForegroundColor Red
    pause; exit
}

Write-Host ""
Write-Host "   :" -ForegroundColor Gray
Write-Host "    E:\Backup        (   )" -ForegroundColor Gray
Write-Host "    D:\Backup        ( )" -ForegroundColor Gray
Write-Host ""
$dest = Read-Host "    "

$backupDir = "$dest\Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')_$(Split-Path $source -Leaf)"

if (-not (Test-Path $dest)) {
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
}
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "  ║     : $source" -ForegroundColor White
Write-Host "  ║     : $backupDir" -ForegroundColor White
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""

#   
$folders = @("Documents","Desktop","Pictures","Downloads","Videos","Music","AppData\Roaming")
$copied  = 0

foreach ($folder in $folders) {
    $src = Join-Path $source $folder
    $dst = Join-Path $backupDir $folder
    if (Test-Path $src) {
        Write-Host "  Running : $folder ..." -ForegroundColor Yellow
        robocopy "$src" "$dst" /E /COPYALL /R:1 /W:1 /NP /NFL /NDL 2>&1 | Out-Null
        Write-Host "  [OK] $folder ✅" -ForegroundColor Green
        $copied++
    }
}

#  
Write-Host ""
$extra = Read-Host "    (   Enter )"
if ($extra -ne "" -and (Test-Path $extra)) {
    Write-Host "  Running   ..." -ForegroundColor Yellow
    robocopy "$extra" "$backupDir\Extra" /E /COPYALL /R:1 /W:1 /NP /NFL /NDL 2>&1 | Out-Null
    Write-Host "  [OK]   ✅" -ForegroundColor Green
}

# 
$totalSize = (Get-ChildItem $backupDir -Recurse -EA SilentlyContinue | Measure-Object -Property Length -Sum).Sum
$totalGB   = [math]::Round($totalSize / 1GB, 2)

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║  ✅  Completed  !             ║" -ForegroundColor Green
Write-Host "  ║    : $copied              ║" -ForegroundColor White
Write-Host "  ║          : $totalGB GB         ║" -ForegroundColor White
Write-Host "  ║           : $backupDir" -ForegroundColor Gray
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Green

Write-Host ""
Read-Host "  Press Enter to return to menu"
