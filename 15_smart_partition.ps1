# ==============================================================
#   Smart Partition -  Disk  GPT/MBR
#   Version 3.0 | 2026
#   ⚠️ Warning:       Disk
# ==============================================================

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""; Exit
}

Clear-Host
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Red
Write-Host "  ║   Smart Partition -  Disk        ║" -ForegroundColor Red
Write-Host "  ║   ⚠️  Warning:    !     ║" -ForegroundColor Yellow
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Red
Write-Host ""

#  Disk 
Write-Host "  Disk :" -ForegroundColor Yellow
$disks = Get-Disk | Select-Object Number, FriendlyName, Size, PartitionStyle
$disks | ForEach-Object {
    $gb = [math]::Round($_.Size/1GB)
    Write-Host "  Disk $($_.Number) : $($_.FriendlyName) - $gb GB - $($_.PartitionStyle)" -ForegroundColor White
}
Write-Host ""

$diskNum = Read-Host "    Disk (: 0)"
if ($diskNum -notmatch '^\d+$') { Write-Host "  [!]   "; pause; exit }

$selectedDisk = Get-Disk -Number $diskNum -EA SilentlyContinue
if (-not $selectedDisk) { Write-Host "  [!] Disk Not found"; pause; exit }

$diskGB = [math]::Round($selectedDisk.Size/1GB)
Write-Host ""
Write-Host "  ⚠️      :" -ForegroundColor Red
Write-Host "  Disk $diskNum : $($selectedDisk.FriendlyName) - $diskGB GB" -ForegroundColor Red
Write-Host ""
$confirm = Read-Host "   YES  "
if ($confirm -ne "YES") { Write-Host "   "; pause; exit }

#    Firmware
$fw = (Get-ItemProperty 'HKLM:\System\CurrentControlSet\Control' -Name PEFirmwareType -EA SilentlyContinue).PEFirmwareType
$isUEFI = ($fw -eq 2)

Write-Host ""
if ($isUEFI) {
    Write-Host "  [OK] UEFI  -   GPT" -ForegroundColor Green
    $script = @"
select disk $diskNum
clean
convert gpt
create partition efi size=300
format quick fs=fat32 label="System"
assign letter=S
create partition msr size=128
create partition primary
format quick fs=ntfs label="Windows"
assign letter=C
"@
} else {
    Write-Host "  [OK] Legacy BIOS  -   MBR" -ForegroundColor Green
    $script = @"
select disk $diskNum
clean
convert mbr
create partition primary size=500
format quick fs=ntfs label="System"
active
create partition primary
format quick fs=ntfs label="Windows"
assign letter=C
"@
}

Write-Host "  Running  Disk..." -ForegroundColor Yellow
$script | diskpart

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║  ✅    Disk !             ║" -ForegroundColor Green
Write-Host "  ║  : $(if($isUEFI){'GPT (UEFI)'}else{'MBR (Legacy)'})                     ║" -ForegroundColor White
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Green

Write-Host ""
Read-Host "  Press Enter to return to menu"
