# Pre
$ErrorActionPreference = "Stop"
$WarningPreference = "SilentlyContinue"
$restartNeeded = $false

# Vars
$user = "laserzentrale"

# Start
Write-Host -ForegroundColor Cyan "------------------------------------"
Write-Host -ForegroundColor Cyan "    Laserzentrale Computer Setup    "
Write-Host -ForegroundColor Cyan "------------------------------------`n"

# Notebook mode
Write-Host -ForegroundColor White "Select Computer mode:"
Write-Host -ForegroundColor White "1 - Active"
Write-Host -ForegroundColor White "2 - Backup"
Write-Host -ForegroundColor White "3 - Other"
$mode = Read-Host -Prompt "Type (1/2/3) and press enter"

switch ($mode) 
{
    1 {
        $notebook = "laserzentrale-1".ToUpper()
        $wallpaper = "wallpaper-active.png"
    }
    2 {
        $notebook = "laserzentrale-2".ToUpper()
        $wallpaper = "wallpaper-backup.png"
    }
    3 {
        $notebook = Read-Host -Prompt "Type in the desired hostname"
    }
    Default{
        Write-Error -Message "No valid mode was selected" -Category InvalidData -RecommendedAction "Type 1 or 2 for the desired mode"
        Exit 1
    }
}

# Progress Bar
$i = 0
$g = 11
$activity = "Notebook Setup"

# Create directories
$i++
Write-Progress -Activity $activity -PercentComplete ($i/$g*100)
$dirs = @(
    "C:\LGServer"
    "C:\LGServer\Media"
    "C:\LGServer\Share"
    "C:\LGServer\Software"
    "C:\LGServer\Docs"
    "C:\Users\$user\git"
    "C:\Users\$user\Desktop\Shows"
    "C:\Users\$user\AppData\Local\nvim"
    "C:\Users\$user\Pictures\Laserzentrale"
)

foreach ($dir in $dirs) 
{
    if (-not (Test-Path -Path $dir)) 
    {
        Write-Host -ForegroundColor Green "Create directory: $dir"
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# --------------------------
# Windows Configuration
# --------------------------

# Copy Wallpaper
$i++
Write-Progress -Activity $activity -PercentComplete ($i/$g*100)

$wallpaperPath = "C:\Users\$user\Pictures\Laserzentrale\$wallpaper"
if(-not (Test-Path -Path $wallpaperPath))
{
    Copy-Item -Path "$PSScriptRoot\wallpaper\$wallpaper" -Destination $wallpaperPath -Force
}

# Set hostname
$i++
Write-Progress -Activity $activity -PercentComplete ($i/$g*100)

if ($($env:COMPUTERNAME) -ne $notebook) 
{
    Write-Host -ForegroundColor Green "Set hostname: $notebook"
    Rename-Computer -Restart:$false -NewName $notebook -Force
    $restartNeeded = $true
}

# Disable IPv6
$i++
Write-Progress -Activity $activity -PercentComplete ($i/$g*100)

$adapters = Get-NetAdapterBinding | Select-Object Name, DisplayName, ComponentID, Enabled
foreach ($adapter in $adapters) 
{
    if ($adapter.ComponentID -match 'ms_tcpip6' -and $adapter.Enabled) {
        Write-Host -ForegroundColor Green "Disable IPv6 Adapter: $($adapter.Name)"
        Disable-NetAdapterBinding -Name $adapter.Name -ComponentID 'ms_tcpip6' -Confirm:$false
    }
}

# Deactivate Windows Firewall
$i++
Write-Progress -Activity $activity -PercentComplete ($i/$g*100)

$firewallState = Get-NetFirewallProfile -All
if ($true -in $firewallState.Enabled)
{
    Write-Host -ForegroundColor Green "Deactivate Windows Firewall"
    Set-NetFirewallProfile -Profile Domain,Private,Public -Enabled False
}

# --------------------------
# Software
# --------------------------

# Install Lasergraph Software
$i++
Write-Progress -Activity $activity -PercentComplete ($i/$g*100)

$lgsoftware = @(
    "https://laseranimation.com/download/LGControl/LGControl--2020-04-09.exe"
    "https://laseranimation.com/download/LGRemote/LGRemote--2025-04-16.exe"
    "https://laseranimation.com/download/LGStatus/LGStatus--2025-05-02.exe"
    "https://laseranimation.com/download/LGTimecode/LGTimecode--2024-11-29.exe"
    "https://laseranimation.com/download/LpvCreator/LpvCreator--2025-07-22.exe"
    "https://laseranimation.com/download/LpvPlayer/LpvPlayer--2025-07-22.exe"
    "https://laseranimation.com/download/proTizeConverter/proTizeConverterDSP--2023-09-25.exe"
    "https://laseranimation.com/download/IldaViewer/IldaViewer--2024-11-05.exe"
)

foreach ($url in $lgsoftware)
{
    $software = $url.Split('/')[-1]
    $short = $software.Split('-')[0]
    if (-not (Test-Path -Path "C:\LGServer\Software\$software"))
    {
        Write-Host -ForegroundColor Green "Starting software download: $software"
        Start-BitsTransfer -Source $url -Destination "C:\LGServer\Software"

        Write-Host -ForegroundColor Green "Install software: $short ($software)"
        Start-Process -FilePath "C:\LGServer\Software\$software" -ArgumentList "/INSTALL", "/VERYSILENT" -NoNewWindow -Wait
    }
}

# Download Lasergraph User manuals
$i++
Write-Progress -Activity $activity -PercentComplete ($i/$g*100)

$lgmanual = @(
    "https://laseranimation.com/download/dsp/Complete%20Manual--2025-04-04.pdf"
)

foreach ($url in $lgmanual)
{
    $manual = $url.Split('/')[-1]
    if (-not (Test-Path -Path "C:\LGServer\Docs\$manual"))
    {
        Write-Host -ForegroundColor Green "Starting user manual download: $manual"
        Start-BitsTransfer -Source $url -Destination "C:\LGServer\Docs"
    }
}

# Install Tascam Audiointerface driver
$i++
Write-Progress -Activity $activity -PercentComplete ($i/$g*100)

$url = "https://www.tascam.eu/sw/uh-7000/UH-7000_DR_v102_win.zip"
$software = $url.Split('/')[-1]
$short = $software.Split('.')[0]
$folder = $software.TrimEnd('.zip')
if (-not (Test-Path -Path "C:\LGServer\Software\$software"))
{
    Write-Host -ForegroundColor Green "Starting software download: $software"
    Start-BitsTransfer -Source $url -Destination "C:\LGServer\Software"

    Write-Host -ForegroundColor Green "Unzip to: $folder"
    Expand-Archive -Path "C:\LGServer\Software\$software" -DestinationPath "C:\LGServer\Software\$folder"

    $item = Get-Item -Path "C:\LGServer\Software\$folder\*.exe"

    Write-Host -ForegroundColor Green "Install software: $short ($software)"
    Start-Process -FilePath $item.FullName -ArgumentList "/INSTALL", "/VERYSILENT" -NoNewWindow -Wait
}

# Install LoopMidi
$i++
Write-Progress -Activity $activity -PercentComplete ($i/$g*100)

$url = "https://www.tobias-erichsen.de/wp-content/uploads/2020/01/loopMIDISetup_1_0_16_27.zip"
$software = $url.Split('/')[-1]
$short = $software.Split('.')[0]
$folder = $software.TrimEnd('.zip')
if (-not (Test-Path -Path "C:\LGServer\Software\$software"))
{
    Write-Host -ForegroundColor Green "Starting software download: $software"
    Start-BitsTransfer -Source $url -Destination "C:\LGServer\Software"

    Write-Host -ForegroundColor Green "Unzip to: $folder"
    Expand-Archive -Path "C:\LGServer\Software\$software" -DestinationPath "C:\LGServer\Software\$folder"

    $item = Get-Item -Path "C:\LGServer\Software\$folder\*.exe"

    Write-Host -ForegroundColor Green "Install software: $short ($software)"
    Start-Process -FilePath $item.FullName -ArgumentList "/install", "/quiet" -NoNewWindow -Wait
}


# Install lasergraph-timecode-importer
$i++
Write-Progress -Activity $activity -PercentComplete ($i/$g*100)

$url = "https://github.com/laser-zentrale-de/lasergraph-timecode-importer/releases/download/v1.1.1/lasergraph-timecode-importer_1.1.1_windows_x86_64.zip"
$software = $url.Split('/')[-1]
$short = $software.Split('.')[0]
$folder = $software.TrimEnd('.zip')
if (-not (Test-Path -Path "C:\LGServer\Software\$software"))
{
    Write-Host -ForegroundColor Green "Starting software download: $software"
    Start-BitsTransfer -Source $url -Destination "C:\LGServer\Software"

    Write-Host -ForegroundColor Green "Unzip to: $folder"
    Expand-Archive -Path "C:\LGServer\Software\$software" -DestinationPath "C:\LGServer\Software\$folder"

    $item = Get-Item -Path "C:\LGServer\Software\$folder\*.exe"

    Write-Host -ForegroundColor Green "Install software: $short ($software)"
    Copy-Item -Path $item.FullName -Destination "C:\Windows\System32\lasergraph-timecode-importer.exe" -Force

    Write-Host -ForegroundColor Green "Configure Powershell completions for: $short ($software)"
    $profilePath = "C:\Users\laserzentrale\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    $completionString = "Invoke-Expression (& lasergraph-timecode-importer.exe completions powershell | Out-String)"
    if (-not (Test-Path $profilePath))
    {
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
    }
    $prof = Get-Content -Path $profilePath
    if ($prof -notcontains $completionString)
    {
        echo $completionString | Out-File -FilePath $profilePath -Append
    }
}

# Winget Software
$i++
Write-Progress -Activity $activity -PercentComplete ($i/$g*100)

$wingetSoftware = @(
    "VideoLAN.VLC"
    "Cockos.REAPER"
    "Neovim.Neovim"
    "Git.Git"
    "RustDesk.RustDesk"
    "LocalSend.LocalSend"
)

foreach ($software in $wingetSoftware)
{
    $get = winget list --id $software
    if ($get -match "No installed package found") 
    {
        Write-Host -ForegroundColor Green "Install Winget software: $software"
        winget install -e --silent --id $software --accept-package-agreements --accept-source-agreements | Out-Null
    }
}

# Neovim
$nvimConfig = "C:\Users\$user\AppData\Local\nvim\init.lua"
if (-not (Test-Path -Path $nvimConfig))
{
    Copy-Item -Path "$PSScriptRoot\nvim\init.lua" -Destination $nvimConfig -Force
}

# End Progress Bar
Write-Progress -Activity "Playbook" -Completed

# Restart if needed
if ($restartNeeded)
{
    Write-Host -ForegroundColor Green "Computer will restart in 10 seconds!"
    Start-Sleep
    Restart-Computer -Force
}
