<# NOTE: iBMC Service module Cmdlets #>

function Get-iBMCService {
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
PSObject[][]
Returns PSObject Array which contains all support services infomation if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> Get-iBMCService $session

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Set-iBMCService
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
    $Logger.info("Invoke Get BMC Service function")

    $ScriptBlock = {
      param($RedfishSession)
      $(Get-Logger).info($(Trace-Session $RedfishSession "Invoke get BMC Service now"))
      $Path = "/Managers/$($RedfishSession.Id)/NetworkProtocol"
      $Response = Invoke-RedfishRequest $RedfishSession $Path | ConvertFrom-WebResponse

      $Properties = @("HTTP", "HTTPS", "SNMP", "VirtualMedia", "IPMI", "SSH", "KVMIP")
      $Services = Copy-ObjectProperties $Response $Properties
      $Services | Add-Member -MemberType NoteProperty "VNC" $Response.Oem.Huawei.VNC
      return $Services
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Logger.info($(Trace-Session $RedfishSession "Submit get BMC Service task"))
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

function Set-iBMCService {
<#
.SYNOPSIS
Modify iBMC service information, including the enablement state and port number.

.DESCRIPTION
Modify iBMC service information, including the enablement state and port number.
Support Services: "HTTP", "HTTPS", "SNMP", "VirtualMedia", "IPMI", "SSH", "KVMIP", "VNC

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.PARAMETER ServiceName
Indicates the type of service to be modified.
Support value set: "HTTP", "HTTPS", "SNMP", "VirtualMedia", "IPMI", "SSH", "KVMIP", "VNC.

.PARAMETER Enabled
Indicates enabled the service or not.
Support values are powershell boolean value: $true, $false.

.PARAMETER Port
Indicates the network port which this service listen on.
Support integer value range: [1, 65535]

.OUTPUTS
Null
Returns Null if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> Set-iBMCService -Session $session -ServiceName 'VNC' -Enabled $true -Port 5900

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Get-iBMCService
Connect-iBMC
Disconnect-iBMC

#>
  [CmdletBinding()]
  param (
    [RedfishSession[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    $Session,

    [string[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
    [ValidateSet("HTTP", "HTTPS", "SNMP", "VirtualMedia", "IPMI", "SSH", "KVMIP", "VNC")]
    $ServiceName,

    [Boolean[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 2)]
    $Enabled,

    [int[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 3)]
    [ValidateRange(1, 65535)]
    $Port
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
    Assert-ArrayNotNull $ServiceName 'ServiceName'
    Assert-ArrayNotNull $Enabled 'Enabled'
    Assert-ArrayNotNull $Port 'Port'

    $ServiceName = Get-MatchedSizeArray $Session $ServiceName 'Session' 'ServiceName'
    $Enabled = Get-MatchedSizeArray $Session $Enabled 'Session' 'Enabled'
    $Port = Get-MatchedSizeArray $Session $Port 'Session' 'Port'
  }

  process {
    $Logger.info("Invoke Set BMC Service function")

    $ScriptBlock = {
      param($RedfishSession, $ServiceName, $Enabled, $Port)
      $(Get-Logger).info($(Trace-Session $RedfishSession "Invoke Set BMC Service now"))
      $Path = "/Managers/$($RedfishSession.Id)/NetworkProtocol"
      $Payload = @{
        $ServiceName=@{
          "ProtocolEnabled"=$Enabled;
          "Port"=$Port;
        }
      }
      if ($ServiceName -eq 'VNC') {
        $Payload = @{
          'Oem'=@{
            'Huawei'=$Payload;
          };
        };
      }

      $(Get-Logger).info($(Trace-Session $RedfishSession "Update Service info: $Payload"))
      Invoke-RedfishRequest $RedfishSession $Path 'Patch' $Payload | Out-Null
      return $null
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Parameters = @($RedfishSession, $ServiceName[$idx], $Enabled[$idx], $Port[$idx])
        $Logger.info($(Trace-Session $RedfishSession "Submit Set BMC Service task"))
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

