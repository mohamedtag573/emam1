Write-Host ""
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host "   ||       Hardware Report                       ||" -ForegroundColor Cyan
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host ""
$cpu    = (Get-WmiObject Win32_Processor).Name
$ram    = [math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory/1GB)
$gpu    = (Get-WmiObject Win32_VideoController).Name
$mb     = (Get-WmiObject Win32_BaseBoard).Product
$serial = (Get-WmiObject Win32_BIOS).SerialNumber
$os     = (Get-WmiObject Win32_OperatingSystem).Caption
$disks  = Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3}

Write-Host "   CPU    : $cpu" -ForegroundColor White
Write-Host "   RAM    : $ram GB" -ForegroundColor White
Write-Host "   GPU    : $gpu" -ForegroundColor White
Write-Host "   MB     : $mb" -ForegroundColor White
Write-Host "   Serial : $serial" -ForegroundColor White
Write-Host "   OS     : $os" -ForegroundColor White
Write-Host ""
Write-Host "   DISKS:" -ForegroundColor Cyan
foreach ($d in $disks) {
    $size = [math]::Round($d.Size/1GB)
    $free = [math]::Round($d.FreeSpace/1GB)
    Write-Host "   $($d.DeviceID)  $free GB free of $size GB" -ForegroundColor White
}
Write-Host ""
Pause
