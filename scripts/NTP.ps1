<# NOTE: iBMC NTP module Cmdlets #>

try { [NtpAddressOrigin] | Out-Null } catch {
Add-Type -TypeDefinition @'
    public enum NtpAddressOrigin {
      IPv4,
      IPv6,
      Static
    }
'@
}

try { [NtpKeyValueType] | Out-Null } catch {
Add-Type -TypeDefinition @'
    public enum NtpKeyValueType {
      Text,
      URI
    }
'@
}

function Get-iBMCNTPSetting {
<#
.SYNOPSIS
Get iBMC NTP Settings.

.DESCRIPTION
Get iBMC NTP Settings.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.OUTPUTS
PSObject[]
Returns PSObject indicates iBMC NTP Settings if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> Get-iBMCNTPSetting -Session $session

ServiceEnabled              : True
PreferredNtpServer          : pre.huawei.com
AlternateNtpServer          : alt.huawei.com
NtpAddressOrigin            : Static
MinPollingInterval          : 10
MaxPollingInterval          : 12
ServerAuthenticationEnabled : False

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Set-iBMCNTPSetting
Import-iBMCNTPKey
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
  }

  process {
    Assert-ArrayNotNull $Session 'Session'

    $Logger.info("Invoke Get iBMC NTP Settings function")

    $ScriptBlock = {
      param($RedfishSession)
      $(Get-Logger).info($(Trace-Session $RedfishSession "Invoke Get iBMC NTP Settings now"))
      $Path = "/Managers/$($RedfishSession.Id)/NtpService"
      $Response = Invoke-RedfishRequest $RedfishSession $Path | ConvertFrom-WebResponse

      $Properties = @(
        "ServiceEnabled", "PreferredNtpServer", "AlternateNtpServer", "NtpAddressOrigin",
        "MinPollingInterval", "MaxPollingInterval", "ServerAuthenticationEnabled"
      )
      $Settings = Copy-ObjectProperties $Response $Properties
      return $Settings
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Logger.info($(Trace-Session $RedfishSession "Submit Get iBMC NTP Settings task"))
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

function Set-iBMCNTPSetting {
<#
.SYNOPSIS
Modify iBMC NTP Settings.

.DESCRIPTION
Modify iBMC NTP Settings.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.PARAMETER ServiceEnabled
Indicates whether NTP is enabled.
Support values are powershell boolean value: $true, $false.

.PARAMETER PreferredNtpServer
Indicates the address of the preferred NTP server.
A character string that meets the following requirements:
- IPv4, IPv6 address or domain name
- Contains 1 to 67 characters

.PARAMETER AlternateNtpServer
Indicates the address of the alternate NTP server.
A character string that meets the following requirements:
- IPv4, IPv6 address or domain name
- Contains 1 to 67 characters

.PARAMETER NtpAddressOrigin
Indicates the NTP Address mode.
Available Value Set: IPV4, IPV6, Static

.PARAMETER MinPollingInterval
Minimum NTP polling interval.
It can be a value from 3 to 17. The value cannot be greater than MaxPollingInterval.

.PARAMETER MaxPollingInterval
Maximum NTP polling interval.
It can be a value from 3 to 17. The value cannot be less than MinPollingInterval.

.PARAMETER ServerAuthenticationEnabled
Indicates Whether server authentication is enabled.
Support values are powershell boolean value: $true, $false.

.OUTPUTS
Null
Returns Null if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> Set-iBMCNTPSetting $session -ServiceEnabled $true
          -PreferredNtpServer 'pre.huawei.com' -AlternateNtpServer 'alt.huawei.com' `
          -NtpAddressOrigin Static -ServerAuthenticationEnabled $false `
          -MinPollingInterval 10 -MaxPollingInterval 12

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Get-iBMCNTPSetting
Import-iBMCNTPKey
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
    $ServiceEnabled,

    [String[]]
    [ValidateLength(0, 67)]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    $PreferredNtpServer,

    [String[]]
    [ValidateLength(0, 67)]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    $AlternateNtpServer,

    [NtpAddressOrigin[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    $NtpAddressOrigin,

    [int32[]]
    [ValidateRange(3, 17)]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    $MinPollingInterval,

    [int32[]]
    [ValidateRange(3, 17)]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    $MaxPollingInterval,

    [Boolean[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    $ServerAuthenticationEnabled
  )

  begin {
  }

  process {
    Assert-ArrayNotNull $Session 'Session'
    $ServiceEnabledList = Get-OptionalMatchedSizeArray $Session $ServiceEnabled
    $PreferredNtpServerList = Get-OptionalMatchedSizeArray $Session $PreferredNtpServer
    $AlternateNtpServerList = Get-OptionalMatchedSizeArray $Session $AlternateNtpServer
    $NtpAddressOriginList = Get-OptionalMatchedSizeArray $Session $NtpAddressOrigin
    $MinPollingIntervalList = Get-OptionalMatchedSizeArray $Session $MinPollingInterval
    $MaxPollingIntervalList = Get-OptionalMatchedSizeArray $Session $MaxPollingInterval
    $ServerAuthenticationEnabledList = Get-OptionalMatchedSizeArray $Session $ServerAuthenticationEnabled

    $Logger.info("Invoke Set iBMC NTP Settings function")

    $ScriptBlock = {
      param($RedfishSession, $Payload)
      $(Get-Logger).info($(Trace-Session $RedfishSession "Invoke Set iBMC NTP Settings now"))
      $Path = "/Managers/$($RedfishSession.Id)/NtpService"
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
          ServiceEnabled=$ServiceEnabledList[$idx];
          PreferredNtpServer=$PreferredNtpServerList[$idx];
          AlternateNtpServer=$AlternateNtpServerList[$idx];
          NtpAddressOrigin=$NtpAddressOriginList[$idx];
          MinPollingInterval=$MinPollingIntervalList[$idx];
          MaxPollingInterval=$MaxPollingIntervalList[$idx];
          ServerAuthenticationEnabled=$ServerAuthenticationEnabledList[$idx];
        } | Remove-EmptyValues | Resolve-EnumValues

        if ($null -ne $Payload.MinPollingInterval -and $null -ne $Payload.MaxPollingInterval) {
          if ($Payload.MinPollingInterval -gt $Payload.MaxPollingInterval) {
            throw $(Get-i18n ERROR_NTP_MIN_GT_MAX)
          }
        }

        if ($Payload.Count -eq 0) {
          throw $(Get-i18n ERROR_NO_UPDATE_PAYLOAD)
        }

        $Parameters = @($RedfishSession, $Payload)
        $Logger.info($(Trace-Session $RedfishSession "Submit Set iBMC NTP Settings task"))
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

function Import-iBMCNTPGroupKey {
<#
.SYNOPSIS
Import the iBMC NTP group key

.DESCRIPTION
Import the iBMC NTP group key

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.PARAMETER PreferredNtpServer
Indicates the address of the preferred NTP server.
A character string that meets the following requirements:
- IPv4, IPv6 address or domain name
- Contains 1 to 67 characters

.PARAMETER KeyValueType
Indicates the Import group key value type.
Available Value Set: Text, URI.
- text: indicates that value is a private key.
- URI: indicates that value is a local URI(under iBMC /tmp directory) or remote URI (supports https、sftp、nfs、cifs、scp).

.PARAMETER KeyValue
Indicates the Import group key value.
- if Parameter "KeyValueType" is Text, KeyValue is the content of private key.
- if Parameter "KeyValueType" is URI, KeyValue is a path to a local certificate (under the /tmp directory only)
  or a certificate on a remote server (Supported file transfer protocols include HTTPS, SFTP, NFS, SCP, and CIFS).


.OUTPUTS
Null
Returns Null if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> $KeyValue = 'the-ntp-key-content'
PS C:\> Import-iBMCNTPGroupKey $session -KeyValueType Text -KeyValue $KeyValue

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Get-iBMCNTPSetting
Set-iBMCNTPSetting
Connect-iBMC
Disconnect-iBMC

#>
  [CmdletBinding()]
  param (
    [RedfishSession[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    $Session,

    [NtpKeyValueType[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
    $KeyValueType,

    [String[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 2)]
    $KeyValue
  )

  begin {
  }

  process {
    Assert-ArrayNotNull $Session 'Session'
    Assert-ArrayNotNull $KeyValueType 'KeyValueType'
    Assert-ArrayNotNull $KeyValue 'KeyValue'
    $KeyValueTypeList = Get-MatchedSizeArray $Session $KeyValueType
    $KeyValueList = Get-MatchedSizeArray $Session $KeyValue

    $Logger.info("Invoke Import iBMC NTP Group Key function")

    $ScriptBlock = {
      param($RedfishSession, $Payload)
      $(Get-Logger).info($(Trace-Session $RedfishSession "Invoke Import iBMC NTP Group Key now"))
      $Path = "/Managers/$($RedfishSession.Id)/NtpService/Actions/NtpService.ImportNtpKey"
      $Response = Invoke-RedfishRequest $RedfishSession $Path 'POST' $Payload
      Resolve-RedfishPartialSuccessResponse $RedfishSession $Response | Out-Null
      return $null
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Payload = @{
          Type=$KeyValueTypeList[$idx];
          Content=$KeyValueList[$idx];
        } | Remove-EmptyValues | Resolve-EnumValues

        $Parameters = @($RedfishSession, $Payload)
        $Logger.info($(Trace-Session $RedfishSession "Submit Import iBMC NTP Group Key task"))
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
