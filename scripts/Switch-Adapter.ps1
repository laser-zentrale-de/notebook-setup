# Get all network adapters
$adapters = Get-NetAdapter | Where-Object { $_.InterfaceDescription -match "Ethernet" -or $_.InterfaceDescription -match "Wi-Fi" -or $_.Name -match "Ethernet|Wi-Fi|LAN|WLAN" }

# Disable adapters
$adaptersUp = $adapters | Where-Object { $_.Status -ne "Disabled" } | Disable-NetAdapter -Confirm:$false -PassThru
Write-Host -ForegroundColor Green "Disabled: $($adaptersUp.Name)"

# Enable adapters
$adaptersDown = $adapters | Where-Object { $_.Status -eq "Disabled" } | Enable-NetAdapter -Confirm:$false -PassThru
Write-Host -ForegroundColor Green "Enabled: $($adaptersDown.Name)"
