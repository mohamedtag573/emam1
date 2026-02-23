Write-Host ""
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host "   ||       Cleanup & Speed Up                    ||" -ForegroundColor Cyan
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "   [~] Cleaning temp files..." -ForegroundColor Yellow
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "   [OK] Temp files cleaned." -ForegroundColor Green

Write-Host "   [~] Running Disk Cleanup..." -ForegroundColor Yellow
cleanmgr /sagerun:1 2>$null

Write-Host "   [~] Flushing DNS..." -ForegroundColor Yellow
ipconfig /flushdns | Out-Null
Write-Host "   [OK] DNS flushed." -ForegroundColor Green

Write-Host "   [~] Disabling unnecessary startup items..." -ForegroundColor Yellow
Get-CimInstance Win32_StartupCommand | Select-Object Name, Command | Format-Table -AutoSize

Write-Host ""
Write-Host "   [OK] Cleanup complete. System is faster now." -ForegroundColor Green
Write-Host ""
Pause
