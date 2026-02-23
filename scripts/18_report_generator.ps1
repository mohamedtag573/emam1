Write-Host ""
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host "   ||       HTML Report                           ||" -ForegroundColor Cyan
Write-Host "   =================================================" -ForegroundColor DarkCyan
Write-Host ""
$pc   = $env:COMPUTERNAME
$user = $env:USERNAME
$os   = (Get-WmiObject Win32_OperatingSystem).Caption
$cpu  = (Get-WmiObject Win32_Processor).Name
$ram  = [math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory/1GB)
$free = [math]::Round((Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace/1GB)
$date = Get-Date -Format "dd/MM/yyyy HH:mm"
$out  = "$env:USERPROFILE\Desktop\IT_Report_$pc.html"

$html = "<html><body style='font-family:Arial;background:#111;color:#0ff;padding:20px'>"
$html += "<h1 style='color:#fff'>IT Emam Report</h1>"
$html += "<p>PC: $pc | User: $user</p>"
$html += "<p>OS: $os</p><p>CPU: $cpu</p>"
$html += "<p>RAM: $ram GB | Free: $free GB</p>"
$html += "<p>Date: $date</p>"
$html += "<p style='color:#0f0'>Report by Emam Professional IT Toolkit v3.2</p>"
$html += "</body></html>"

$html | Set-Content $out -Force
Write-Host "   [OK] Report saved to Desktop." -ForegroundColor Green
Start-Process $out
Write-Host ""
Pause
