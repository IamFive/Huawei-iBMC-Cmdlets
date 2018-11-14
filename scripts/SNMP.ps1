<# NOTE: iBMC SNMP module Cmdlets #>

try { [SnmpV3PrivProtocol] | Out-Null } catch {
  Add-Type -TypeDefinition @'
  public enum SnmpV3PrivProtocol {
    DES,
    AES
  }
'@
}

try { [SnmpV3AuthProtocol] | Out-Null } catch {
  Add-Type -TypeDefinition @'
  public enum SnmpV3AuthProtocol {
    MD5,
    SHA1
  }
'@
}

function Get-iBMCSNMPSetting {
<#
.SYNOPSIS
Get iBMC SNMP Basic Settings.

.DESCRIPTION
Get iBMC SNMP Basic Settings.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.OUTPUTS
PSObject[]
Returns PSObject indicates SNMP Basic Settings if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> Get-iBMCSNMPSetting -Session $session

SnmpV1Enabled       : False
SnmpV2CEnabled      : False
SnmpV3Enabled       : True
LongPasswordEnabled : True
RWCommunityEnabled  : True
SnmpV3AuthProtocol  : MD5
SnmpV3PrivProtocol  : DES

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Set-iBMCSNMPSetting
Get-iBMCSNMPTrapSetting
Set-iBMCSNMPTrapSetting
Get-iBMCSNMPTrapServer
Set-iBMCSNMPTrapServer
Connect-iBMC
Disconnect-iBMC

#>
  [CmdletBinding()]
  param (
    [RedfishSession[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    $Session
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
  }

  process {
    $Logger.info("Invoke Get iBMC SNMP Settings function")

    $ScriptBlock = {
      param($RedfishSession)
      $(Get-Logger).info($(Trace-Session $RedfishSession "Invoke get iBMC SNMP Settings now"))
      $Path = "/Managers/$($RedfishSession.Id)/SnmpService"
      $Response = Invoke-RedfishRequest $RedfishSession $Path | ConvertFrom-WebResponse
      $Properties = @(
        "SnmpV1Enabled", "SnmpV2CEnabled", "SnmpV3Enabled", "LongPasswordEnabled",
        "RWCommunityEnabled", "SnmpV3AuthProtocol", "SnmpV3PrivProtocol"
      )
      $Settings = Copy-ObjectProperties $Response $Properties
      return $Settings
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Logger.info($(Trace-Session $RedfishSession "Submit get iBMC SNMP Settings task"))
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $ScriptBlock @($RedfishSession)))
      }

      $Results = Get-AsyncTaskResults $tasks
      return $Results
    }
    finally {
      $pool.close()
    }
  }

  end {
  }
}

function Set-iBMCSNMPSetting {
<#
.SYNOPSIS
Modify iBMC SNMP Basic Settings.

.DESCRIPTION
Modify iBMC SNMP Basic Settings.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.PARAMETER SnmpV1Enabled
Indicates whether SNMPV1 is enabled.
Support values are powershell boolean value: $true, $false.

.PARAMETER SnmpV2CEnabled
Indicates whether SNMPV2C is enabled.
Support values are powershell boolean value: $true, $false.

.PARAMETER LongPasswordEnabled
Indicates whether long password is enabled.
Support values are powershell boolean value: $true, $false.

.PARAMETER RWCommunityEnabled
Indicates whether read-write community name is enabled.
Support values are powershell boolean value: $true, $false.

.PARAMETER ReadOnlyCommunity
Indicates the read only community name.
A character string that meets the following requirements:
- Cannot contain spaces.
- Contain 1 to 32 bytes by default or 16 to 32 bytes for long passwords.
- If password complexity check is enabled, the password must contain at least 8 bytes and contain at least two types of uppercase letters, lowercase letters, digits, and special characters.
- Have at least two new characters when compared with the previous community name.
- Read-only community name and Read-write community name must be different.

.PARAMETER ReadWriteCommunity
Indicates the read write community name.
A character string that meets the following requirements:
- Cannot contain spaces.
- Contain 1 to 32 bytes by default or 16 to 32 bytes for long passwords.
- If password complexity check is enabled, the password must contain at least 8 bytes and contain at least two types of uppercase letters, lowercase letters, digits, and special characters.
- Have at least two new characters when compared with the previous community name.
- Read-only community name and Read-write community name must be different.

.PARAMETER SnmpV3AuthProtocol
Indicates the SNMPv3 authentication algorithm.
Available Value Set: ('MD5', 'SHA')

.PARAMETER SnmpV3PrivProtocol
Indicates the SNMPv3 encryption algorithm.
Available Value Set: ('DES', 'AES')

.OUTPUTS
Null
Returns Null if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> Set-iBMCSNMPSetting $session -SnmpV1Enabled $false -SnmpV2CEnabled $false `
        -LongPasswordEnabled $true -RWCommunityEnabled $true `
        -ReadOnlyCommunity 'SomeP@ssw0rd' -ReadWriteCommunity 'SomeP@ssw0rd' `
        -SnmpV3AuthProtocol MD5 -SnmpV3PrivProtocol DES


.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Get-iBMCSNMPSetting
Get-iBMCSNMPTrapSetting
Set-iBMCSNMPTrapSetting
Get-iBMCSNMPTrapServer
Set-iBMCSNMPTrapServer
Connect-iBMC
Disconnect-iBMC

#>
  [CmdletBinding()]
  param (
    [RedfishSession[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    $Session,

    [Boolean[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    $SnmpV1Enabled,

    [Boolean[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    $SnmpV2CEnabled,

    [Boolean[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    $LongPasswordEnabled,

    [Boolean[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    $RWCommunityEnabled,

    [string[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    $ReadOnlyCommunity,

    [string[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    $ReadWriteCommunity,

    [SnmpV3AuthProtocol[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    $SnmpV3AuthProtocol,

    [SnmpV3PrivProtocol[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    $SnmpV3PrivProtocol
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
    $SnmpV1EnabledList = Get-OptionalMatchedSizeArray $Session $SnmpV1Enabled
    $SnmpV2CEnabledList = Get-OptionalMatchedSizeArray $Session $SnmpV2CEnabled
    $LongPasswordEnabledList = Get-OptionalMatchedSizeArray $Session $LongPasswordEnabled
    $RWCommunityEnabledList = Get-OptionalMatchedSizeArray $Session $RWCommunityEnabled
    $ReadOnlyCommunityList = Get-OptionalMatchedSizeArray $Session $ReadOnlyCommunity
    $ReadWriteCommunityList = Get-OptionalMatchedSizeArray $Session $ReadWriteCommunity
    $SnmpV3AuthProtocolList = Get-OptionalMatchedSizeArray $Session $SnmpV3AuthProtocol
    $SnmpV3PrivProtocolList = Get-OptionalMatchedSizeArray $Session $SnmpV3PrivProtocol
  }

  process {
    $Logger.info("Invoke Set iBMC SNMP Settings function")

    $ScriptBlock = {
      param($RedfishSession, $Payload)
      $(Get-Logger).info($(Trace-Session $RedfishSession "Invoke Set iBMC SNMP Settings now"))
      $Path = "/Managers/$($RedfishSession.Id)/SnmpService"
      $Response = Invoke-RedfishRequest $RedfishSession $Path 'Patch' $Payload
      Resolve-RedfishPartialSuccessResponse $RedfishSession $Response | Out-Null
      return $null
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Payload = @{
          SnmpV1Enabled=$SnmpV1EnabledList[$idx];
          SnmpV2CEnabled=$SnmpV2CEnabledList[$idx];
          LongPasswordEnabled=$LongPasswordEnabledList[$idx];
          RWCommunityEnabled=$RWCommunityEnabledList[$idx];
          ReadOnlyCommunity=$ReadOnlyCommunityList[$idx];
          ReadWriteCommunity=$ReadWriteCommunityList[$idx];
          SnmpV3AuthProtocol=$SnmpV3AuthProtocolList[$idx];
          SnmpV3PrivProtocol=$SnmpV3PrivProtocolList[$idx];
        } | Remove-EmptyValues | Resolve-EnumValues

        if ($Payload.Count -eq 0) {
          throw $(Get-i18n ERROR_NO_UPDATE_PAYLOAD)
        }

        $Parameters = @($RedfishSession, $Payload)
        $Logger.info($(Trace-Session $RedfishSession "Submit Set iBMC SNMP Settings task"))
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $ScriptBlock $Parameters))
      }

      $Results = Get-AsyncTaskResults $tasks
      return $Results
    }
    finally {
      $pool.close()
    }
  }

  end {
  }
}


function Get-iBMCSNMPTrapSetting {
<#
.SYNOPSIS
Get iBMC SNMP Trap Notification Settings.

.DESCRIPTION
Get iBMC SNMP Trap Notification Settings.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.OUTPUTS
PSObject[]
Returns PSObject indicates SNMP Trap Notification Settings if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> Get-iBMCSNMPTrapSetting -Session $session

ServiceEnabled     : True
TrapVersion        : V2C
TrapV3User         : UserName
TrapMode           : EventCode
TrapServerIdentity : BoardSN
AlarmSeverity      : Critical

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Get-iBMCSNMPSetting
Set-iBMCSNMPSetting
Set-iBMCSNMPTrapSetting
Get-iBMCSNMPTrapServer
Set-iBMCSNMPTrapServer
Connect-iBMC
Disconnect-iBMC

#>

  [CmdletBinding()]
  param (
    [RedfishSession[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    $Session
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
  }

  process {
    $Logger.info("Invoke Get iBMC SNMP Trap Settings function")

    $ScriptBlock = {
      param($RedfishSession)
      $(Get-Logger).info($(Trace-Session $RedfishSession "Invoke Get iBMC SNMP Trap Settings now"))
      $Path = "/Managers/$($RedfishSession.Id)/SnmpService"
      $Response = Invoke-RedfishRequest $RedfishSession $Path | ConvertFrom-WebResponse
      $Properties = @(
        "ServiceEnabled", "TrapVersion", "TrapV3User", "TrapMode",
        "TrapServerIdentity", "AlarmSeverity"
      )
      $TrapSettings = Copy-ObjectProperties $Response.SnmpTrapNotification $Properties
      return $TrapSettings
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Logger.info($(Trace-Session $RedfishSession "Submit Get iBMC SNMP Trap Settings task"))
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $ScriptBlock @($RedfishSession)))
      }

      $Results = Get-AsyncTaskResults $tasks
      return $Results
    }
    finally {
      $pool.close()
    }
  }

  end {
  }
}


function Set-iBMCSNMPTrapSetting {
<#
.SYNOPSIS
Modify iBMC SNMP Trap Notification Settings.

.DESCRIPTION
Modify iBMC SNMP Trap Notification Settings.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.PARAMETER ServiceEnabled
Indicates whether trap is enabled.
Support values are powershell boolean value: $true, $false.

.PARAMETER TrapVersion
Indicates the SNMP trap version
Available Value Set: V1, V2C, V3

.PARAMETER TrapV3User
Indicates the SNMPV3 user name. User name should be an exists iBMC user account's login name.

.PARAMETER TrapMode
Indicates the SNMP trap mode.
Available Value Set: OID, EventCode, PreciseAlarm.

.PARAMETER TrapServerIdentity
Indicates the trap server host identifier.
Available Value Set: BoardSN, ProductAssetTag, HostName.

.PARAMETER CommunityName
Indicates the Community name. Community name is invalid if SNMPv3 trap is used.
A character string that meets the following requirements:
- Cannot contain spaces.
- Contain 8 to 18 bytes and contain at least two types of uppercase letters, lowercase letters, digits, and special characters if password complexity check is enabled.
- Contain 1 to 18 password complexity check is disabled.
- Have at least two new characters when compared with the previous community name.

.PARAMETER AlarmSeverity
Indicates which severity level alarm should be notified
Available Value Set: Critical, Major, Minor, Normal

.OUTPUTS
Null
Returns Null if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> Set-iBMCSNMPSetting $session -SnmpV1Enabled $false -SnmpV2CEnabled $false `
        -LongPasswordEnabled $true -RWCommunityEnabled $true `
        -ReadOnlyCommunity 'SomeP@ssw0rd' -ReadWriteCommunity 'SomeP@ssw0rd' `
        -SnmpV3AuthProtocol MD5 -SnmpV3PrivProtocol DES


.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Get-iBMCSNMPSetting
Set-iBMCSNMPSetting
Get-iBMCSNMPTrapSetting
Get-iBMCSNMPTrapServer
Set-iBMCSNMPTrapServer
Connect-iBMC
Disconnect-iBMC

#>
  [CmdletBinding()]
  param (
    [RedfishSession[]]
    [ValidateNotNull()]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    $Session,

    [Boolean[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    $ServiceEnabled,

    [String[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [ValidateSet('V1', 'V2C', 'V3', $null)]
    $TrapVersion,

    [String[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    $TrapV3User,

    [String[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [ValidateSet('OID', 'EventCode', 'PreciseAlarm', $null)]
    $TrapMode,

    [String[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [ValidateSet('BoardSN', 'ProductAssetTag', 'HostName', $null)]
    $TrapServerIdentity,

    [String[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    $CommunityName,

    [String[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [ValidateSet('Critical', 'Major', 'Minor', 'Normal', $null)]
    $AlarmSeverity
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
    $ServiceEnabled = Get-OptionalMatchedSizeArray $Session $ServiceEnabled
    $TrapVersion = Get-OptionalMatchedSizeArray $Session $TrapVersion
    $TrapV3User = Get-OptionalMatchedSizeArray $Session $TrapV3User
    $TrapMode = Get-OptionalMatchedSizeArray $Session $TrapMode
    $TrapServerIdentity = Get-OptionalMatchedSizeArray $Session $TrapServerIdentity
    $CommunityName = Get-OptionalMatchedSizeArray $Session $CommunityName
    $AlarmSeverity = Get-OptionalMatchedSizeArray $Session $AlarmSeverity
  }

  process {
    $Logger.info("Invoke Set BMC SNMP Settings function")

    $ScriptBlock = {
      param($RedfishSession, $Payload)
      $(Get-Logger).info($(Trace-Session $RedfishSession "Invoke Set BMC SNMP Settings now"))
      $Path = "/Managers/$($RedfishSession.Id)/SnmpService"

      $Payload = @{ "SnmpTrapNotification"=$Payload; }
      $Response = Invoke-RedfishRequest $RedfishSession $Path 'Patch' $Payload
      Resolve-RedfishPartialSuccessResponse $RedfishSession $Response | Out-Null
      return $null
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Payload = Remove-EmptyValues @{
          ServiceEnabled=$ServiceEnabled[$idx];
          TrapVersion=$TrapVersion[$idx];
          TrapV3User=$TrapV3User[$idx];
          TrapMode=$TrapMode[$idx];
          TrapServerIdentity=$TrapServerIdentity[$idx];
          CommunityName=$CommunityName[$idx];
          AlarmSeverity=$AlarmSeverity[$idx];
        }

        if ($Payload.Count -eq 0) {
          throw $(Get-i18n ERROR_NO_UPDATE_PAYLOAD)
        }

        $Parameters = @($RedfishSession, $Payload)
        $Logger.info($(Trace-Session $RedfishSession "Submit Set iBMC SNMP Trap Settings task"))
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $ScriptBlock $Parameters))
      }

      $Results = Get-AsyncTaskResults $tasks
      return $Results
    }
    finally {
      $pool.close()
    }
  }

  end {
  }
}


function Get-iBMCSNMPTrapServer {
<#
.SYNOPSIS
Get iBMC SNMP Trap Notification Servers.

.DESCRIPTION
Get iBMC SNMP Trap Notification Servers.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.OUTPUTS
PSObject[][]
Returns PSObject Array indicates SNMP Trap Notification Servers if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> Get-iBMCSNMPTrapServer -Session $session

MemberId          : 0
BobEnabled        : False
Enabled           : False
TrapServerAddress :
TrapServerPort    : 300

MemberId          : 1
BobEnabled        : False
Enabled           : True
TrapServerAddress : 192.168.2.8
TrapServerPort    : 310

MemberId          : 2
BobEnabled        : False
Enabled           : False
TrapServerAddress : 192.168.2.7
TrapServerPort    : 163

MemberId          : 3
BobEnabled        : True
Enabled           : True
TrapServerAddress : 10.10.10.2
TrapServerPort    : 202

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Get-iBMCSNMPSetting
Set-iBMCSNMPSetting
Get-iBMCSNMPTrapSetting
Set-iBMCSNMPTrapSetting
Set-iBMCSNMPTrapServer
Connect-iBMC
Disconnect-iBMC

#>
  [CmdletBinding()]
  param (
    [RedfishSession[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    $Session
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
  }

  process {
    $Logger.info("Invoke Get iBMC SNMP Trap Servers function")

    $ScriptBlock = {
      param($RedfishSession)
      $(Get-Logger).info($(Trace-Session $RedfishSession "Invoke Get iBMC SNMP Trap Servers now"))
      $Path = "/Managers/$($RedfishSession.Id)/SnmpService"
      $Response = Invoke-RedfishRequest $RedfishSession $Path | ConvertFrom-WebResponse
      return ,$Response.SnmpTrapNotification.TrapServer
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Logger.info($(Trace-Session $RedfishSession "Submit Get iBMC SNMP Trap Servers task"))
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $ScriptBlock @($RedfishSession)))
      }

      $Results = Get-AsyncTaskResults $tasks
      return $Results
    }
    finally {
      $pool.close()
    }
  }

  end {
  }
}


function Set-iBMCSNMPTrapServer {
<#
.SYNOPSIS
Modify iBMC SNMP Trap Notification Server.

.DESCRIPTION
Modify iBMC SNMP Trap Notification Server.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.PARAMETER MemberId
Indicates which trap notification server to modify.
MemberId is the unique primary ID for Trap Notification Server.
Support integer value range: [0, 3]

.PARAMETER Enabled
Indicates Whether the trap server is enabled.
Support values are powershell boolean value: $true, $false.

.PARAMETER TrapServerAddress
Indicates the Notificate Server address.
Available values: IPv4, IPv6 address or domain name.

.PARAMETER TrapServerPort
Indicates the Notificate Server port.
Available Value Set: OID, EventCode, PreciseAlarm.

.OUTPUTS
Null
Returns Null if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> Set-iBMCSNMPTrapServer $session -MemberId 1 -Enabled $true -TrapServerAddress 192.168.2.8 -TrapServerPort 1024


.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Get-iBMCSNMPSetting
Set-iBMCSNMPSetting
Get-iBMCSNMPTrapSetting
Set-iBMCSNMPTrapSetting
Get-iBMCSNMPTrapServer
Connect-iBMC
Disconnect-iBMC

#>
  [CmdletBinding()]
  param (
    [RedfishSession[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    $Session,

    [int32[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [ValidateRange(0, 3)]
    $MemberId,

    [Boolean[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    $Enabled,

    [String[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    $TrapServerAddress,

    [int32[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [ValidateRange(1, 65535)]
    $TrapServerPort
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
    Assert-ArrayNotNull $MemberId 'MemberId'
    $MemberIds = Get-MatchedSizeArray $Session $MemberId
    $Enableds = Get-OptionalMatchedSizeArray $Session $Enabled
    $TrapServerAddresses = Get-OptionalMatchedSizeArray $Session $TrapServerAddress
    $TrapServerPorts = Get-OptionalMatchedSizeArray $Session $TrapServerPort
  }

  process {
    $Logger.info("Invoke Set BMC SNMP Trap Server function")

    $ScriptBlock = {
      param($RedfishSession, $MemberId, $Payload)
      $(Get-Logger).info($(Trace-Session $RedfishSession "Invoke Set BMC SNMP Trap Server now"))
      $Path = "/Managers/$($RedfishSession.Id)/SnmpService"

      $Members = New-Object System.Collections.ArrayList
      for ($idx = 0; $idx -lt 4; $idx++) {
        if ($MemberId -eq $idx) {
          [Void] $Members.Add($Payload)
        } else {
          [Void] $Members.Add(@{})
        }
      }

      $CompletePlayload = @{
        "SnmpTrapNotification"=@{
          TrapServer=$Members;
        }
      }

      $Response = Invoke-RedfishRequest $RedfishSession $Path 'Patch' $CompletePlayload
      Resolve-RedfishPartialSuccessResponse $RedfishSession $Response | Out-Null
      return $null
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $MemberId=$MemberIds[$idx];
        $Payload = Remove-NoneValues @{
          Enabled=$Enableds[$idx];
          TrapServerAddress=$TrapServerAddresses[$idx];
          TrapServerPort=$TrapServerPorts[$idx];
        }

        if ($Payload.Count -eq 0) {
          throw $(Get-i18n ERROR_NO_UPDATE_PAYLOAD)
        }

        $Parameters = @($RedfishSession, $MemberId, $Payload)
        $Logger.info($(Trace-Session $RedfishSession "Submit Set BMC SNMP Trap Server task"))
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $ScriptBlock $Parameters))
      }

      $Results = Get-AsyncTaskResults $tasks
      return $Results
    }
    finally {
      $pool.close()
    }
  }

  end {
  }
}
