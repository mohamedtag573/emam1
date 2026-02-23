Set-ExecutionPolicy Bypass -Scope Process -Force
$host.UI.RawUI.BackgroundColor = "Black"
$host.UI.RawUI.ForegroundColor = "White"
$host.UI.RawUI.WindowTitle = "EMAM // Professional IT Toolkit"
Clear-Host

$stored = "901c812503b70f10ab3728a3da2e0fb6e12683189b7a17b5d0ce5f703b365e9a"

function Show-Banner {
    Write-Host ""
    Write-Host "   =================================================" -ForegroundColor DarkCyan
    Write-Host "   ||                                             ||" -ForegroundColor DarkCyan
    Write-Host "   ||        E  M  A  M                          ||" -ForegroundColor Cyan
    Write-Host "   ||        Professional IT Toolkit  v3.2       ||" -ForegroundColor White
    Write-Host "   ||                                             ||" -ForegroundColor DarkCyan
    Write-Host "   =================================================" -ForegroundColor DarkCyan
    Write-Host ""
}

function Divider {
    Write-Host "   -------------------------------------------------" -ForegroundColor DarkGray
}

$tries = 0
while ($tries -lt 3) {
    Clear-Host
    Show-Banner
    if ($tries -gt 0) {
        Write-Host "   [!] Wrong password  --  $(3 - $tries) attempt(s) left." -ForegroundColor Red
        Write-Host ""
    }
    Divider
    Write-Host "    SECURE ACCESS  //  Enter password to continue" -ForegroundColor DarkCyan
    Divider
    Write-Host ""
    $sp = Read-Host "    Password" -AsSecureString
    $inp = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sp))
    $h = [System.BitConverter]::ToString(
        [System.Security.Cryptography.SHA256]::Create().ComputeHash(
            [System.Text.Encoding]::UTF8.GetBytes($inp)
        )).Replace("-","").ToLower()
    if ($h -eq $stored) {
        Write-Host ""
        Divider
        Write-Host "    [+] ACCESS GRANTED  //  Welcome back, Emam." -ForegroundColor Green
        Divider
        Start-Sleep 1
        break
    }
    $tries++
}

if ($tries -ge 3) {
    Clear-Host
    Divider
    Write-Host "    [X] ACCESS DENIED  //  Too many failed attempts." -ForegroundColor Red
    Divider
    Start-Sleep 3
    exit
}

function Get-SysInfo {
    $pc   = $env:COMPUTERNAME
    $user = $env:USERNAME
    $date = Get-Date -Format "ddd  dd/MM/yyyy  HH:mm"
    $ip   = try { (Get-NetIPConfiguration | Where-Object {$_.IPv4DefaultGateway} | Select-Object -First 1).IPv4Address.IPAddress } catch { "N/A" }
    $ram  = [math]::Round((Get-WmiObject Win32_ComputerSystem).TotalPhysicalMemory/1GB)
    $free = [math]::Round((Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'").FreeSpace/1GB)
    $os   = (Get-WmiObject Win32_OperatingSystem).Caption -replace "Microsoft ",""
    return @{pc=$pc;user=$user;date=$date;ip=$ip;ram=$ram;free=$free;os=$os}
}

function Show-Menu {
    Clear-Host
    $s = Get-SysInfo
    Show-Banner
    Divider
    Write-Host "    PC     $($s.pc)   //   User   $($s.user)" -ForegroundColor White
    Write-Host "    IP     $($s.ip)   //   RAM    $($s.ram) GB   //   Free   $($s.free) GB" -ForegroundColor White
    Write-Host "    OS     $($s.os)" -ForegroundColor White
    Write-Host "    Date   $($s.date)" -ForegroundColor White
    Divider
    Write-Host ""
    Write-Host "    INSTALLATION" -ForegroundColor Cyan
    Write-Host "    01  Pre-Install Check              02  Auto Install Apps" -ForegroundColor White
    Write-Host "    03  Activate Windows + Office      04  Windows Update" -ForegroundColor White
    Write-Host "    05  Post-Install Check" -ForegroundColor White
    Write-Host ""
    Write-Host "    MAINTENANCE" -ForegroundColor Cyan
    Write-Host "    06  Cleanup & Speed Up             07  Windows Full Repair" -ForegroundColor White
    Write-Host "    08  Auto Error Fix" -ForegroundColor White
    Write-Host ""
    Write-Host "    TOOLS & DIAGNOSTICS" -ForegroundColor Cyan
    Write-Host "    09  Hardware Report                10  Network Check" -ForegroundColor White
    Write-Host "    11  WiFi Passwords                 12  Remote Support" -ForegroundColor White
    Write-Host ""
    Write-Host "    ADVANCED" -ForegroundColor Cyan
    Write-Host "    13  Emergency Backup               14  Rename PC by Serial" -ForegroundColor White
    Write-Host "    15  Smart Partition GPT/MBR        16  Password Manager" -ForegroundColor White
    Write-Host "    17  Driver Backup & Restore        18  HTML Report" -ForegroundColor White
    Write-Host "    19  Disk Health (SMART)" -ForegroundColor White
    Write-Host ""
    Divider
    Write-Host "    00  Exit" -ForegroundColor DarkRed
    Divider
    Write-Host ""
}

function Run-Option($num) {
    $url = "https://raw.githubusercontent.com/mohamedtag573/emam/main/scripts/$num"
    try {
        Write-Host ""
        Write-Host "    [~] Loading $num ..." -ForegroundColor DarkCyan
        $code = (New-Object Net.WebClient).DownloadString($url)
        Invoke-Expression $code
    } catch {
        Write-Host "    [!] Script not found or no internet." -ForegroundColor Red
        Start-Sleep 2
    }
}

do {
    Show-Menu
    $c = Read-Host "    >> Enter Option"
    switch ($c) {
        {$_ -in "1","01"} { Run-Option "01_pre_check.ps1" }
        {$_ -in "2","02"} { Run-Option "02_install_apps.ps1" }
        {$_ -in "3","03"} { Run-Option "03_activation.ps1" }
        {$_ -in "4","04"} { Run-Option "04_windows_update.ps1" }
        {$_ -in "5","05"} { Run-Option "05_post_check.ps1" }
        {$_ -in "6","06"} { Run-Option "06_cleanup.ps1" }
        {$_ -in "7","07"} { Run-Option "07_system_repair.ps1" }
        {$_ -in "8","08"} { Run-Option "08_error_handler.ps1" }
        {$_ -in "9","09"} { Run-Option "09_hardware_info.ps1" }
        "10" { Run-Option "10_network_check.ps1" }
        "11" { Run-Option "11_wifi_passwords.ps1" }
        "12" { Run-Option "12_remote_support.ps1" }
        "13" { Run-Option "13_backup_data.ps1" }
        "14" { Run-Option "14_rename_pc.ps1" }
        "15" { Run-Option "15_smart_partition.ps1" }
        "16" { Run-Option "16_password_manager.ps1" }
        "17" { Run-Option "17_driver_backup.ps1" }
        "18" { Run-Option "18_report_generator.ps1" }
        "19" { Run-Option "19_disk_health.ps1" }
        {$_ -in "0","00"} {
            Clear-Host
            Show-Banner
            Divider
            Write-Host "    Goodbye, Emam.  See you on the next mission." -ForegroundColor Cyan
            Divider
            Write-Host ""
            Start-Sleep 2
            exit
        }
        default {
            Write-Host "    [!] Invalid option. Try again." -ForegroundColor Red
            Start-Sleep 1
        }
    }
} while ($true)
