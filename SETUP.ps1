
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""; Exit
}
Set-ExecutionPolicy Bypass -Scope Process -Force

$src        = Split-Path -Parent $MyInvocation.MyCommand.Path
$installDir = "C:\ITEmam"
$launchPath = "$installDir\launch.ps1"
$authFile   = "$installDir\.auth"
$menuPath   = "$installDir\MASTER_MENU.ps1"

$host.UI.RawUI.WindowTitle     = "IT Emam - Setup"
$host.UI.RawUI.BackgroundColor = "Black"
Clear-Host

Write-Host ""
Write-Host "  +---------------------------------------------------------+" -ForegroundColor Cyan
Write-Host "  |          IT EMAM TOOLKIT  —  GLOBAL INSTALL            |" -ForegroundColor Cyan
Write-Host "  |  Run once. Then type  emam  in any PowerShell or CMD   |" -ForegroundColor DarkCyan
Write-Host "  +---------------------------------------------------------+" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Choose a password (you will need it every time you run):" -ForegroundColor Yellow
Write-Host ""

$p1 = Read-Host "  New password    " -AsSecureString
$p2 = Read-Host "  Confirm         " -AsSecureString
$plain1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($p1))
$plain2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($p2))

if ($plain1 -ne $plain2 -or $plain1.Length -eq 0) {
    Write-Host ""
    Write-Host "  [!] Passwords do not match or are empty." -ForegroundColor Red
    pause; exit
}

$hash = [System.BitConverter]::ToString(
    [System.Security.Cryptography.SHA256]::Create().ComputeHash(
        [System.Text.Encoding]::UTF8.GetBytes($plain1)
    )
).Replace("-","").ToLower()

Write-Host ""

# ── 1. Copy files ──────────────────────────────────────
Write-Host "  [1/5] Installing toolkit to $installDir ..." -ForegroundColor Yellow
if (-not (Test-Path $installDir)) { New-Item -ItemType Directory $installDir -Force | Out-Null }
Get-ChildItem "$src\*.ps1" | Copy-Item -Destination $installDir -Force
Copy-Item "$src\*.bat" $installDir -Force -EA SilentlyContinue
$hash | Out-File $authFile -Encoding UTF8 -Force
(Get-Item $authFile).Attributes = "Hidden"
Write-Host "  [OK] Files installed + password saved (SHA-256)" -ForegroundColor Green

# ── 2. Write launch.ps1 ───────────────────────────────
Write-Host "  [2/5] Writing password screen ..." -ForegroundColor Yellow

$launchContent = @'
$authFile = "C:\ITEmam\.auth"
if (-not (Test-Path $authFile)) {
    Write-Host "  [!] Toolkit not installed. Run SETUP.ps1 first." -ForegroundColor Red
    Start-Sleep 3; exit
}
$stored = (Get-Content $authFile -Raw).Trim()
$tries  = 0
while ($tries -lt 3) {
    Clear-Host
    $host.UI.RawUI.WindowTitle     = "IT Emam Toolkit"
    $host.UI.RawUI.BackgroundColor = "Black"
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
    Write-Host ""
    if ($tries -gt 0) {
        Write-Host "  [!] Wrong password — $(3 - $tries) attempt(s) remaining." -ForegroundColor Red
        Write-Host ""
    }
    Write-Host "  ENTER PASSWORD TO CONTINUE" -ForegroundColor DarkGray
    Write-Host ""
    $sp  = Read-Host "  Password" -AsSecureString
    $inp = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
              [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sp))
    $h   = [System.BitConverter]::ToString(
              [System.Security.Cryptography.SHA256]::Create().ComputeHash(
                  [System.Text.Encoding]::UTF8.GetBytes($inp)
              )).Replace("-","").ToLower()
    if ($h -eq $stored) {
        Write-Host ""
        Write-Host "  [OK] Access granted. Welcome, Emam!" -ForegroundColor Green
        Start-Sleep 1
        & powershell.exe -ExecutionPolicy Bypass -File "C:\ITEmam\MASTER_MENU.ps1"
        exit
    }
    $tries++
}
Clear-Host
Write-Host "  [X] Access Denied." -ForegroundColor Red
Start-Sleep 3

'@
$launchContent | Out-File $launchPath -Encoding UTF8 -Force
Write-Host "  [OK] Password screen ready" -ForegroundColor Green

# ── 3. PowerShell profile (All Users) ─────────────────
Write-Host "  [3/5] Adding  emam  to PowerShell ..." -ForegroundColor Yellow
$psProfile = "C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1"
$profDir   = Split-Path $psProfile
if (-not (Test-Path $profDir)) { New-Item -ItemType Directory $profDir -Force | Out-Null }
if (-not (Test-Path $psProfile)) { New-Item -ItemType File $psProfile -Force | Out-Null }
$cur = Get-Content $psProfile -Raw -EA SilentlyContinue
if ($cur -notmatch "ITEmam") {
    Add-Content $psProfile "`n# IT Emam Toolkit"
    Add-Content $psProfile "function emam { powershell.exe -ExecutionPolicy Bypass -NoExit -File 'C:\ITEmam\launch.ps1' }"
}
Write-Host "  [OK] Type  emam  in any PowerShell window" -ForegroundColor Green

# ── 4. CMD via registry ────────────────────────────────
Write-Host "  [4/5] Adding  emam  to CMD ..." -ForegroundColor Yellow
$cmdKey = "HKLM:\Software\Microsoft\Command Processor"
Set-ItemProperty $cmdKey "AutoRun" `
    "doskey emam=powershell.exe -ExecutionPolicy Bypass -NoExit -File C:\ITEmam\launch.ps1" `
    -EA SilentlyContinue
Write-Host "  [OK] Type  emam  in any CMD window" -ForegroundColor Green

# ── 5. Desktop + Start Menu shortcuts ─────────────────
Write-Host "  [5/5] Creating shortcuts ..." -ForegroundColor Yellow
$args  = "-ExecutionPolicy Bypass -NoExit -File `"C:\ITEmam\launch.ps1`""
$wsh   = New-Object -ComObject WScript.Shell
$locs  = @(
    [Environment]::GetFolderPath("CommonDesktopDirectory"),
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
)
foreach ($loc in $locs) {
    $sc = $wsh.CreateShortcut("$loc\IT Emam.lnk")
    $sc.TargetPath = "powershell.exe"
    $sc.Arguments  = $args
    $sc.WindowStyle = 1
    $sc.Description = "IT Emam Toolkit"
    $sc.Save()
}
Write-Host "  [OK] Shortcuts created on Desktop + Start Menu" -ForegroundColor Green

Write-Host ""
Write-Host "  +---------------------------------------------------------+" -ForegroundColor Green
Write-Host "  |  SETUP COMPLETE!                                        |" -ForegroundColor Green
Write-Host "  |                                                         |" -ForegroundColor Green
Write-Host "  |  Open any PowerShell or CMD and type:  emam            |" -ForegroundColor Cyan
Write-Host "  |  Or double-click  IT Emam  on the Desktop              |" -ForegroundColor Cyan
Write-Host "  |                                                         |" -ForegroundColor Green
Write-Host "  |  To uninstall: delete  C:\ITEmam  + Desktop shortcut   |" -ForegroundColor DarkGray
Write-Host "  +---------------------------------------------------------+" -ForegroundColor Green
Write-Host ""
pause
