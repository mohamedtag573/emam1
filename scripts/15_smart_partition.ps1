Write-Host ""
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host "   ||       Smart Partition GPT/MBR               ||" -ForegroundColor Cyan
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host ""
$disks = Get-WmiObject Win32_DiskDrive
foreach ($d in $disks) {
    Write-Host "   Disk  : $($d.Caption)" -ForegroundColor White
    Write-Host "   Size  : $([math]::Round($d.Size/1GB)) GB" -ForegroundColor White
    Write-Host "   Parts : $($d.Partitions) partitions" -ForegroundColor White
    Write-Host "   -----------------------------------------------" -ForegroundColor DarkGray
}
Write-Host ""
Pause
