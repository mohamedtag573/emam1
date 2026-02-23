Write-Host ""
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host "   ||       Pre-Install Check                     ||" -ForegroundColor Cyan
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "   [~] Checking system..." -ForegroundColor Yellow

$os   = (Get-WmiObject Win32_OperatingSystem).Caption
$ram  = [math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory/1GB)
$free = [math]::Round((Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace/1GB)
$disk = [math]::Round((Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'").Size/1GB)
$cpu  = (Get-WmiObject Win32_Processor).Name

Write-Host ""
Write-Host "   OS    : $os" -ForegroundColor White
Write-Host "   CPU   : $cpu" -ForegroundColor White
Write-Host "   RAM   : $ram GB" -ForegroundColor White
Write-Host "   Disk  : $free GB free of $disk GB" -ForegroundColor White

Write-Host ""
if ($free -lt 10) {
    Write-Host "   [!] Low disk space! Less than 10GB free." -ForegroundColor Red
} else {
    Write-Host "   [OK] System is ready for installation." -ForegroundColor Green
}
Write-Host ""
Pause
