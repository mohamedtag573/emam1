if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""; Exit
}

$logFile = "C:\IT_Cleanup_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$saved=0
function Log($msg, $color="White") {
    $line = "$(Get-Date -Format 'HH:mm:ss')  $msg"
    Write-Host "  $line" -ForegroundColor $color
    $line | Out-File $logFile -Append -Encoding UTF8
}
Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "  ║  CLEANUP AND SPEED UP                                ║" -ForegroundColor Yellow
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""

Log ">>> [1] Temp Files..." "Yellow"
@($env:TEMP,"$env:SystemRoot\Temp","$env:LOCALAPPDATA\Temp","$env:SystemRoot\Prefetch","$env:SystemDrive\Windows\SoftwareDistribution\Download") | ForEach-Object {
    if (Test-Path $_) {
        $sz=(Get-ChildItem $_ -Recurse -EA SilentlyContinue | Measure-Object -Property Length -Sum).Sum
        Get-ChildItem $_ -Recurse -EA SilentlyContinue | Remove-Item -Recurse -Force -EA SilentlyContinue
        $saved+=$sz; Log "  Cleaned: $_ ($([math]::Round($sz/1MB,1)) MB)" "Gray"
    }
}
Log "  [OK] Freed: $([math]::Round($saved/1MB,1)) MB" "Green"

Log ">>> [2] Recycle Bin..." "Yellow"
Clear-RecycleBin -Force -EA SilentlyContinue; Log "  [OK] Done" "Green"

Log ">>> [3] Startup Bloat..." "Yellow"
@("OneDrive","Skype","Teams","Discord","Spotify","AdobeUpdater","Cortana") | ForEach-Object {
    Remove-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $_ -EA SilentlyContinue
}
Log "  [OK] Done" "Green"

Log ">>> [4] High Performance Mode..." "Yellow"
powercfg /setactive SCHEME_MIN 2>&1|Out-Null
powercfg /change standby-timeout-ac 0 2>&1|Out-Null
powercfg /hibernate off 2>&1|Out-Null
Log "  [OK] Done" "Green"

Log ">>> [5] Visual Effects..." "Yellow"
$vp="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
if (-not (Test-Path $vp)) { New-Item -Path $vp -Force|Out-Null }
Set-ItemProperty $vp "VisualFXSetting" 2 -EA SilentlyContinue
Log "  [OK] Done" "Green"

Log ">>> [6] Disable Bloat Services..." "Yellow"
@("DiagTrack","dmwappushservice","XblGameSave","XboxNetApiSvc") | ForEach-Object {
    Stop-Service $_ -Force -EA SilentlyContinue
    Set-Service $_ -StartupType Disabled -EA SilentlyContinue
}
Log "  [OK] Done" "Green"

Log ">>> [7] DNS + Network Flush..." "Yellow"
ipconfig /flushdns|Out-Null; ipconfig /release|Out-Null; ipconfig /renew|Out-Null
Log "  [OK] Done" "Green"

Log ">>> [8] Disk Cleanup..." "Yellow"
$ck="HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
Get-ChildItem $ck -EA SilentlyContinue | ForEach-Object { Set-ItemProperty $_.PsPath "StateFlags0001" 2 -EA SilentlyContinue }
Start-Process cleanmgr -ArgumentList "/sagerun:1" -Wait -NoNewWindow -EA SilentlyContinue
Log "  [OK] Done" "Green"

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║  [OK] Cleanup Complete! Freed $([math]::Round($saved/1MB,1)) MB" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
$r = Read-Host "  Restart now? (y/n)"
if ($r -eq "y") { Restart-Computer -Force }
else { Read-Host "  Press Enter to return to menu" }
