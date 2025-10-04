# Vars
$ipAddressActive = "10.0.0.1"
$ipAddressBackup = "10.0.0.2"
$prefixLength = 8

# Decide IP-Address based on hostname
if ($env:COMPUTERNAME -eq "laserzentrale-1")
{
  $ipAddress = $ipAddressActive
} else
{
  $ipAddress = $ipAddressBackup
}

# Get all active network adapters
$adapters = Get-NetAdapter | Where-Object { $_.Status -ne "Disabled" -and ($_.InterfaceDescription -match "Ethernet" -or $_.InterfaceDescription -match "Wi-Fi" -or $_.Name -match "Ethernet|Wi-Fi|LAN|WLAN") }

# Set all network adapters
foreach ($adapter in $adapters) {
    $ifIndex = $adapter.ifIndex
    Get-NetIPAddress -InterfaceIndex $ifIndex -AddressFamily IPv4 | Remove-NetIPAddress -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
    New-NetIPAddress -InterfaceIndex $ifIndex -IPAddress $ipAddress -PrefixLength $prefixLength | Out-Null
    Write-Host -ForegroundColor Green "Configured $($adapter.Name) to $ipAddress/$prefixLength"
}
