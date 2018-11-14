<# NOTE: iBMC Syslog Module Cmdlets #>

try { [LogType] | Out-Null } catch {
Add-Type -TypeDefinition @'
    public enum LogType {
      OperationLog,
      SecurityLog,
      EventLog
    }
'@
}

function Get-iBMCSyslogSetting {
<#
.SYNOPSIS
Query information about the services and ports supported by the iBMC.

.DESCRIPTION
Query information about the services and ports supported by the iBMC.
Support Services: "HTTP", "HTTPS", "SNMP", "VirtualMedia", "IPMI", "SSH", "KVMIP", "VNC

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.OUTPUTS
PSObject[]
Returns PSObject indicates the Syslog-Settings if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> $syslog = Get-iBMCSyslogSetting $session
PS C:\> $syslog

ServiceEnabled       : True
ServerIdentitySource : BoardSN
AlarmSeverity        : Normal
TransmissionProtocol : UDP
SyslogServers        : {@{MemberId=0; Enabled=True; Address=192.168.2.96; Port=514; LogType=System.Object[]}, @{MemberId=1;
                      Enabled=True; Address=192.168.14.8; Port=514; LogType=System.Object[]}, @{MemberId=2; Enabled=True; A
                      ddress=192.168.3.161; Port=514; LogType=System.Object[]}, @{MemberId=3; Enabled=True; Address=112.93.
                      129.99; Port=514; LogType=System.Object[]}}

PS C:\> $syslog.SyslogServers

MemberId : 0
Enabled  : True
Address  : 192.168.2.96
Port     : 514
LogType  : {OperationLog, SecurityLog, EventLog}

MemberId : 1
Enabled  : True
Address  : 192.168.14.8
Port     : 514
LogType  : {OperationLog, SecurityLog, EventLog}

MemberId : 2
Enabled  : True
Address  : 192.168.3.161
Port     : 514
LogType  : {OperationLog, SecurityLog, EventLog}

MemberId : 3
Enabled  : True
Address  : 112.93.129.99
Port     : 514
LogType  : {OperationLog, SecurityLog, EventLog}



.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Set-iBMCSyslogSetting
Set-iBMCSyslogServer
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
    $Logger.info("Invoke Get BMC Syslog function")

    $ScriptBlock = {
      param($RedfishSession)

      $(Get-Logger).info($(Trace-Session $RedfishSession "Invoke Get BMC Syslog now"))
      $Path = "/Managers/$($RedfishSession.Id)/SyslogService"
      $Response = Invoke-RedfishRequest $RedfishSession $Path | ConvertFrom-WebResponse
      $Properties = @(
        "ServiceEnabled", "ServerIdentitySource", "AlarmSeverity",
        "TransmissionProtocol", "SyslogServers"
      )
      $Syslog = Copy-ObjectProperties $Response $Properties
      return $Syslog
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Logger.info($(Trace-Session $RedfishSession "Submit Get BMC Syslog task"))
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

function Set-iBMCSyslogSetting {
<#
.SYNOPSIS
Modify iBMC Syslog Notification Settings.

.DESCRIPTION
Modify iBMC Syslog Notification Settings.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.PARAMETER ServiceEnabled
Indicates whether syslog is enabled.
Support values are powershell boolean value: $true, $false.

.PARAMETER ServerIdentitySource
Indicates the notification server host identifier.
Available Value Set: BoardSN, ProductAssetTag, HostName.

.PARAMETER AlarmSeverity
Indicates which severity level alarm should be notified
Available Value Set: Critical, Major, Minor, Normal

.PARAMETER TransmissionProtocol
Indicates the transmission protocol of syslog.
Available Value Set: UDP, TCP, TLS

.OUTPUTS
Null
Returns Null if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> Set-iBMCSyslogSetting $session -ServiceEnabled $true -ServerIdentitySource HostName `
          -AlarmSeverity Major -TransmissionProtocol UDP

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Get-iBMCSyslogSetting
Set-iBMCSyslogServer
Connect-iBMC
Disconnect-iBMC

#>
  [CmdletBinding()]
  param (
    [RedfishSession[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    $Session,

    [Boolean[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
    $ServiceEnabled,

    [String[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 2)]
    [ValidateSet('BoardSN', 'ProductAssetTag', 'HostName', $null)]
    $ServerIdentitySource,

    [String[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 3)]
    [ValidateSet('Critical', 'Major', 'Minor', 'Normal', $null)]
    $AlarmSeverity,

    [String[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 4)]
    [ValidateSet('UDP', 'TCP', 'TLS', $null)]
    $TransmissionProtocol
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'

    $ServiceEnabled = Get-OptionalMatchedSizeArray $Session $ServiceEnabled
    $ServerIdentitySource = Get-OptionalMatchedSizeArray $Session $ServerIdentitySource
    $AlarmSeverity = Get-OptionalMatchedSizeArray $Session $AlarmSeverity
    $TransmissionProtocol = Get-OptionalMatchedSizeArray $Session $TransmissionProtocol
  }

  process {
    $Logger.info("Invoke Set iBMC Syslog settings function")

    $ScriptBlock = {
      param($RedfishSession, $Payload)
      $(Get-Logger).info($(Trace-Session $RedfishSession "Invoke Set iBMC Syslog settings now"))
      $Path = "/Managers/$($RedfishSession.Id)/SyslogService"
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
          ServerIdentitySource=$ServerIdentitySource[$idx];
          AlarmSeverity=$AlarmSeverity[$idx];
          TransmissionProtocol=$TransmissionProtocol[$idx];
        }

        if ($Payload.Count -eq 0) {
          throw $(Get-i18n ERROR_NO_UPDATE_PAYLOAD)
        }

        $Parameters = @($RedfishSession, $Payload)
        $Logger.info($(Trace-Session $RedfishSession "Submit Set iBMC Syslog settings task"))
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


function Set-iBMCSyslogServer {
<#
.SYNOPSIS
Modify iBMC Syslog Notification Server.

.DESCRIPTION
Modify iBMC Syslog Notification Server.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.PARAMETER MemberId
Indicates which Syslog notification server to modify.
MemberId is the unique primary ID for Syslog Notification Server.
Support integer value range: [0, 3]

.PARAMETER Enabled
Indicates Whether this server's syslog notification is enabled.
Support values are powershell boolean value: $true, $false.

.PARAMETER Address
Indicates the Notificate Server address.
Available values: IPv4, IPv6 address or domain name.

.PARAMETER Port
Indicates the Notificate Server port.
Support integer value range: [1, 65535]

.PARAMETER LogType
Indicates the Log type that should be notificated.
Available combined value set: OperationLog, SecurityLog, EventLog.


.OUTPUTS
Null
Returns Null if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> $LogType = ,@("OperationLog", "SecurityLog", "EventLog")
PS C:\> Set-ibmcSyslogServer $session -MemberId 1 -Enabled $true -Address 192.168.14.9 -Port 515 -LogType $LogType

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Get-iBMCSyslogSetting
Set-iBMCSyslogSetting
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
    $Address,

    [int32[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [ValidateRange(1, 65535)]
    $Port,

    [String[][]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [AllowEmptyCollection()]
    $LogType
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
    Assert-ArrayNotNull $MemberId 'MemberId'
    $MemberIds = Get-MatchedSizeArray $Session $MemberId

    $Enableds = Get-OptionalMatchedSizeArray $Session $Enabled
    $Addresses = Get-OptionalMatchedSizeArray $Session $Address
    $Ports = Get-OptionalMatchedSizeArray $Session $Port

    $ValidLogTypes = @("OperationLog", "SecurityLog", "EventLog")
    $LogTypes = Get-OptionalMatchedSizeMatrix $Session $LogType $ValidLogTypes 'Session' 'LogType'
  }

  process {
    $Logger.info("Invoke Set BMC Syslog Notification Server function")

    $ScriptBlock = {
      param($RedfishSession, $MemberId, $Payload)
      $(Get-Logger).info($(Trace-Session $RedfishSession "Invoke Set BMC Syslog Notification Server now"))
      $Path = "/Managers/$($RedfishSession.Id)/SyslogService"

      $Members = New-Object System.Collections.ArrayList
      for ($idx = 0; $idx -lt 4; $idx++) {
        if ($MemberId -eq $idx) {
          [Void] $Members.Add($Payload)
        } else {
          [Void] $Members.Add(@{})
        }
      }

      $CompletePlayload = @{
        "SyslogServers"=$Members;
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
          Address=$Addresses[$idx];
          Port=$Ports[$idx];
          LogType=$LogTypes[$idx];
        }

        if ($Payload.Count -eq 0) {
          throw $(Get-i18n ERROR_NO_UPDATE_PAYLOAD)
        }

        $Parameters = @($RedfishSession, $MemberId, $Payload)
        $Logger.info($(Trace-Session $RedfishSession "Submit Set BMC Syslog Notification Server task"))
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
