
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""; Exit
}
Set-ExecutionPolicy Bypass -Scope Process -Force
$host.UI.RawUI.WindowTitle     = "IT Emam Toolkit"
$host.UI.RawUI.BackgroundColor = "Black"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Run($file) {
    $p = Join-Path $ScriptDir $file
    if (Test-Path $p) { & powershell.exe -ExecutionPolicy Bypass -File "$p" }
    else { Write-Host "  [!] File not found: $file" -ForegroundColor Red; Start-Sleep 2 }
}

function Show-Menu {
    Clear-Host
    $pc   = $env:COMPUTERNAME
    $user = $env:USERNAME
    $date = Get-Date -Format "dd/MM/yyyy  HH:mm"
    $ip   = try { (Get-NetIPConfiguration | Where-Object {$_.IPv4DefaultGateway} | Select-Object -First 1).IPv4Address.IPAddress } catch { "N/A" }
    $ram  = [math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory/1GB)
    $free = [math]::Round((Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace/1GB)
    $os   = (Get-WmiObject Win32_OperatingSystem).Caption -replace "Microsoft ",""

    Write-Host ""
    Write-Host "  +---------------------------------------------------------+" -ForegroundColor DarkGray
    Write-Host "  |  ███████╗███╗   ███╗ █████╗ ███╗   ███╗              |" -ForegroundColor DarkBlue
    Write-Host "  |  ██╔════╝████╗ ████║██╔══██╗████╗ ████║              |" -ForegroundColor Blue
    Write-Host "  |  █████╗  ██╔████╔██║███████║██╔████╔██║              |" -ForegroundColor Cyan
    Write-Host "  |  ██╔══╝  ██║╚██╔╝██║██╔══██║██║╚██╔╝██║              |" -ForegroundColor Blue
    Write-Host "  |  ███████╗██║ ╚═╝ ██║██║  ██║██║ ╚═╝ ██║              |" -ForegroundColor DarkBlue
    Write-Host "  |  ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝              |" -ForegroundColor DarkGray
    Write-Host "  |       Professional IT Toolkit  by Emam  v3.2         |" -ForegroundColor DarkCyan
    Write-Host "  +---------------------------------------------------------+" -ForegroundColor DarkGray
    Write-Host "  |  PC $($pc.PadRight(16))  |  User $($user.PadRight(16))  |" -ForegroundColor DarkGray
    Write-Host "  |  IP $("$ip".PadRight(16))  |  RAM  $($ram)GB   C:\ $($free)GB free     |" -ForegroundColor DarkGray
    Write-Host "  |  OS $($os.PadRight(51))|" -ForegroundColor DarkGray
    Write-Host "  |  $($date.PadRight(55))|" -ForegroundColor DarkGray
    Write-Host "  +---------------------------------------------------------+" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "   INSTALLATION" -ForegroundColor Yellow
    Write-Host "   [ 1] Pre-Install Check          [ 2] Auto Install Apps" -ForegroundColor White
    Write-Host "   [ 3] Activate Win + Office      [ 4] Windows Update" -ForegroundColor White
    Write-Host "   [ 5] Post-Install Check" -ForegroundColor White
    Write-Host ""
    Write-Host "   MAINTENANCE" -ForegroundColor Yellow
    Write-Host "   [ 6] Cleanup & Speed Up         [ 7] Windows Full Repair" -ForegroundColor White
    Write-Host "   [ 8] Auto Error Fix" -ForegroundColor White
    Write-Host ""
    Write-Host "   TOOLS & DIAGNOSTICS" -ForegroundColor Yellow
    Write-Host "   [ 9] Hardware Report            [10] Network Check" -ForegroundColor White
    Write-Host "   [11] WiFi Passwords             [12] Remote Support" -ForegroundColor White
    Write-Host ""
    Write-Host "   ADVANCED" -ForegroundColor Yellow
    Write-Host "   [13] Emergency Backup           [14] Rename PC by Serial" -ForegroundColor White
    Write-Host "   [15] Smart Partition GPT/MBR    [16] Password Manager" -ForegroundColor White
    Write-Host "   [17] Driver Backup & Restore    [18] HTML Report" -ForegroundColor White
    Write-Host "   [19] Disk Health (SMART)" -ForegroundColor White
    Write-Host ""
    Write-Host "   [ 0] Exit" -ForegroundColor DarkRed
    Write-Host ""
    Write-Host "  +---------------------------------------------------------+" -ForegroundColor DarkGray
}

do {
    Show-Menu
    $c = Read-Host "  >> Option"
    switch ($c) {
        "1"  { Run "01_pre_check.ps1" }
        "2"  { Run "02_install_apps.ps1" }
        "3"  { Run "03_activation.ps1" }
        "4"  { Run "04_windows_update.ps1" }
        "5"  { Run "05_post_check.ps1" }
        "6"  { Run "06_cleanup.ps1" }
        "7"  { Run "07_system_repair.ps1" }
        "8"  { Run "08_error_handler.ps1" }
        "9"  { Run "09_hardware_info.ps1" }
        "10" { Run "10_network_check.ps1" }
        "11" { Run "11_wifi_passwords.ps1" }
        "12" { Run "12_remote_support.ps1" }
        "13" { Run "13_backup_data.ps1" }
        "14" { Run "14_rename_pc.ps1" }
        "15" { Run "15_smart_partition.ps1" }
        "16" { Run "16_password_manager.ps1" }
        "17" { Run "17_driver_backup.ps1" }
        "18" { Run "18_report_generator.ps1" }
        "19" { Run "19_disk_health.ps1" }
        "0"  { Clear-Host; Write-Host "`n  Goodbye, Emam!" -ForegroundColor Cyan; Start-Sleep 1; exit }
        default { Write-Host "  [!] Invalid option. Try again." -ForegroundColor Red; Start-Sleep 1 }
    }
} while ($true)
