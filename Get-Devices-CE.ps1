<#
.SYNOPSIS
Get-Devices-CE.ps1 - Exchange Server ActiveSync device report
.DESCRIPTION 
Produces a report of ActiveSync device associations in the organisation including the LastSync date.
.OUTPUTS
Results are output to CSV File, please change this to your required path

Change Log:
V1.00, 03/11/2022 - Initial version

#>

# Enables login with MFA
Connect-ExchangeOnline

# Change CSV for required company

$csv = "C:\temp\CE_Devices.csv"
$results = @()
# Find all Mailboxes
$mailboxUsers = get-mailbox -resultsize unlimited
$mobileDevice = @()

# Iterate through all Mailbox users
foreach($user in $mailboxUsers)
{
$UPN = $user.UserPrincipalName
$displayName = $user.DisplayName

# Get Mobile Device for each mailbox user
$mobileDevices = Get-MobileDevice -Mailbox $UPN
      
      foreach($mobileDevice in $mobileDevices)
      {
        # For each Mobile device, retreive statistics
        $Stats = Get-MobileDeviceStatistics -Identity $mobileDevice.Guid.toString()
        $properties =@{
        Identity              = $mobileDevice.Identity -replace "\\.+"
        DeviceType            = $mobileDevice.DeviceType
        DeviceModel           = $mobileDevice.DeviceModel
        DeviceOS              = $mobileDevice.DeviceOS
        FriendlyName          = $mobileDevice.FriendlyName
        LastSuccessSync       = $Stats.LastSuccessSync
        LastSyncAttemptTime   = $Stats.LastSyncAttemptTime
        LastPolicyUpdateTime  = $Stats.LastPolicyUpdateTime
        LastPingHeartbeat     = $Stats.LastPingHeartbeat
        ClientType            = $Stats.ClientType
    }
    # Append info to results object
    $results += New-Object psobject -Property $properties
    }

}

#Write to csv
$results | Select-Object Identity, DeviceType, DeviceModel, DeviceOS, FriendlyName, LastSuccessSync, LastSyncAttemptTime, LastPolicyUpdateTime, LastPingHeartbeat, ClientType | Export-Csv -notypeinformation -Path $csv

