if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""; Exit
}

$logFile = "C:\IT_Install_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
$host.UI.RawUI.WindowTitle = "Auto Install Apps"

function Log($msg, $color="White") {
    $line = "$(Get-Date -Format 'HH:mm:ss')  $msg"
    Write-Host "  $line" -ForegroundColor $color
    $line | Out-File $logFile -Append -Encoding UTF8
}

function Install-Winget-App($id, $name) {
    Log "  Installing: $name ..." "Yellow"
    $result = winget install --id $id --silent --accept-package-agreements --accept-source-agreements --force 2>&1
    $exitCode = $LASTEXITCODE
    if ($exitCode -eq 0 -or ($result -join "") -match "Successfully installed|already installed|No applicable upgrade") {
        Log "  [OK] $name installed" "Green"
        return $true
    } else {
        Log "  [!] Failed: $name (code: $exitCode)" "Red"
        return $false
    }
}

function Install-Choco-App($pkg, $name) {
    Log "  Trying Chocolatey: $name ..." "Gray"
    choco install $pkg -y --no-progress 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) { Log "  [OK] $name via Chocolatey" "Green"; return $true }
    return $false
}

Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║            AUTO INSTALL APPS  v3.2                  ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ── Check/Install Winget ──
Log ">>> Checking Winget..." "Yellow"
$wingetOK = $false
if (Get-Command winget -EA SilentlyContinue) {
    $wingetOK = $true
    Log "  [OK] Winget Ready" "Green"
} else {
    Log "  Installing Winget..." "Yellow"
    try {
        $url = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $out = "$env:TEMP\winget.msixbundle"
        Invoke-WebRequest $url -OutFile $out -TimeoutSec 60
        Add-AppxPackage $out -EA SilentlyContinue
        if (Get-Command winget -EA SilentlyContinue) { $wingetOK = $true; Log "  [OK] Winget Installed" "Green" }
    } catch { Log "  [!] Could not install Winget" "Red" }
}

# ── Check/Install Chocolatey as fallback ──
$chocoOK = $false
if (-not (Get-Command choco -EA SilentlyContinue)) {
    Log ">>> Installing Chocolatey (fallback)..." "Yellow"
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))
        if (Get-Command choco -EA SilentlyContinue) { $chocoOK = $true; Log "  [OK] Chocolatey Ready" "Green" }
    } catch { Log "  [!] Chocolatey install failed" "Red" }
} else { $chocoOK = $true; Log "  [OK] Chocolatey Ready" "Green" }

Write-Host ""

$apps = @(
    @{ id="Google.Chrome";                    choco="googlechrome";     name="Google Chrome" },
    @{ id="Mozilla.Firefox";                  choco="firefox";          name="Mozilla Firefox" },
    @{ id="7zip.7zip";                        choco="7zip";             name="7-Zip" },
    @{ id="RARLab.WinRAR";                   choco="winrar";           name="WinRAR" },
    @{ id="Notepad++.Notepad++";              choco="notepadplusplus";  name="Notepad++" },
    @{ id="VideoLAN.VLC";                     choco="vlc";              name="VLC" },
    @{ id="CodecGuide.K-LiteCodecPack.Full"; choco="k-litecodecpackfull"; name="K-Lite Codec Pack" },
    @{ id="Adobe.Acrobat.Reader.64-bit";     choco="adobereader";      name="Adobe Reader" },
    @{ id="RustDesk.RustDesk";               choco="rustdesk";         name="RustDesk" },
    @{ id="PuTTY.PuTTY";                     choco="putty";            name="PuTTY" },
    @{ id="WinSCP.WinSCP";                   choco="winscp";           name="WinSCP" },
    @{ id="qBittorrent.qBittorrent";         choco="qbittorrent";      name="qBittorrent" },
    @{ id="Piriform.CCleaner";               choco="ccleaner";         name="CCleaner" },
    @{ id="CrystalDewWorld.CrystalDiskInfo"; choco="crystaldiskinfo";  name="CrystalDiskInfo" },
    @{ id="CrystalDewWorld.CrystalDiskMark"; choco="crystaldiskmark";  name="CrystalDiskMark" },
    @{ id="CPUID.CPU-Z";                     choco="cpu-z";            name="CPU-Z" },
    @{ id="REALiX.HWiNFO";                   choco="hwinfo";           name="HWiNFO" },
    @{ id="WiresharkFoundation.Wireshark";   choco="wireshark";        name="Wireshark" },
    @{ id="angryziber.AngryIPScanner";       choco="angryip";          name="Angry IP Scanner" },
    @{ id="Microsoft.VCRedist.x64.2015+";    choco="vcredist140";      name="VC++ x64" },
    @{ id="Microsoft.VCRedist.x86.2015+";    choco="vcredist140";      name="VC++ x86" },
    @{ id="Microsoft.DotNet.Runtime.8";      choco="dotnet-8.0-runtime"; name=".NET Runtime 8" },
    @{ id="Microsoft.DirectX";               choco="directx";          name="DirectX" }
)

$ok = 0; $fail = 0
Log ">>> Installing $($apps.Count) apps..." "Cyan"
Write-Host ""

foreach ($app in $apps) {
    $success = $false
    if ($wingetOK) { $success = Install-Winget-App $app.id $app.name }
    if (-not $success -and $chocoOK) { $success = Install-Choco-App $app.choco $app.name }
    if ($success) { $ok++ } else { $fail++ }
}

# IT Settings
Log ">>> Applying IT settings..." "Yellow"
Set-ItemProperty "HKLM:\System\CurrentControlSet\Control\Terminal Server" "fDenyTSConnections" 0 -EA SilentlyContinue
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" -EA SilentlyContinue
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0 -EA SilentlyContinue
Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1 -EA SilentlyContinue
powercfg /change standby-timeout-ac 0 | Out-Null
powercfg /hibernate off | Out-Null
Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -All -NoRestart -EA SilentlyContinue | Out-Null
Log "  [OK] IT Settings Applied" "Green"

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║  DONE! Installed: $ok  |  Failed: $fail              " -ForegroundColor Green
Write-Host "  ║  Report: $logFile" -ForegroundColor Gray
Write-Host "  ╚══════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Read-Host "  Press Enter to return to menu"
