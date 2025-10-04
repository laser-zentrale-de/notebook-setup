# Get all active network adapters
$adapters = Get-NetAdapter | Where-Object { $_.Status -ne "Disabled" -and ($_.InterfaceDescription -match "Ethernet" -or $_.InterfaceDescription -match "Wi-Fi" -or $_.Name -match "Ethernet|Wi-Fi|LAN|WLAN") }

# Set all network adapters
foreach ($adapter in $adapters) {
    $ifIndex = $adapter.ifIndex
    # Get-NetIPAddress -InterfaceIndex $ifIndex -AddressFamily IPv4 | Remove-NetIPAddress -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
    Set-NetIPInterface -InterfaceIndex $ifIndex -Dhcp Enabled -AddressFamily IPv4
    Set-DnsClientServerAddress -InterfaceIndex $ifIndex -ResetServerAddresses
    $adapter | Disable-NetAdapter -confirm:$false 
    $adapter | Enable-NetAdapter -confirm:$false
    Write-Host -ForegroundColor Green "Configured $($adapter.Name) to DHCP"
}
