<# NOTE: iBMC deploy module Cmdlets #>

# Get-iBMCVirtualMedia
# Set-iBMCVirtualMediaConnect
# Set-iBMCVirtualMediaDisconnect
# Get-iBMCBootupSequence
# Set-iBMCBootupSequence
# Get-iBMCBootSourceOverride
# Set-iBMCBootSourceOverride

function Get-iBMCVirtualMedia {
<#
.SYNOPSIS
Query information about a specified virtual media resource.

.DESCRIPTION
Query information about a specified virtual media resource.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.OUTPUTS
PSObject[]
Returns PSObject which identifies VirtualMedia if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> Restore-iBMCFactory $session

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Get-iBMCVirtualMedia
Connect-iBMC
Disconnect-iBMC

#>
  [CmdletBinding()]
  param (
    [RedfishSession[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position=0)]
    $Session
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
  }

  process {
    $Logger.info("Invoke Get Virtual Media infomation function")

    $ScriptBlock = {
      param($RedfishSession)
      $Path = "/Managers/$($RedfishSession.Id)/VirtualMedia/CD"
      $Response = Invoke-RedfishRequest $RedfishSession $Path
      return $Response | ConvertFrom-WebResponse
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx=0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Logger.info($(Trace-Session $RedfishSession "Submit Get Virtual Media task"))
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $ScriptBlock @($RedfishSession)))
      }

      $Results = Get-AsyncTaskResults $tasks
      return $Results
    } finally {
      $pool.close()
    }
  }

  end {
  }
}


function Connect-iBMCVirtualMedia {
  <#
  .SYNOPSIS
  Query information about a specified virtual media resource.

  .DESCRIPTION
  Query information about a specified virtual media resource.

  .PARAMETER Session
  iBMC redfish session object which is created by Connect-iBMC cmdlet.
  A session object identifies an iBMC server to which this cmdlet will be executed.

  .OUTPUTS
  PSObject[]
  Returns PSObject which identifies VirtualMedia if cmdlet executes successfully.
  In case of an error or warning, exception will be returned.

  .EXAMPLE

  PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
  PS C:\> Restore-iBMCFactory $session

  .LINK
  http://www.huawei.com/huawei-ibmc-cmdlets-document

  Connect-iBMC
  Disconnect-iBMC

  #>
    [CmdletBinding()]
    param (
      [RedfishSession[]]
      [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position=0)]
      $Session
    )

    begin {
      Assert-ArrayNotNull $Session 'Session'
    }

    process {
      $Logger.info("Invoke Get Virtual Media infomation function")

      $ScriptBlock = {
        param($RedfishSession)
        $Path = "/Managers/$($RedfishSession.Id)/VirtualMedia/CD"
        $Response = Invoke-RedfishRequest $RedfishSession $Path
        return $Response | ConvertFrom-WebResponse
      }

      try {
        $tasks = New-Object System.Collections.ArrayList
        $pool = New-RunspacePool $Session.Count
        for ($idx=0; $idx -lt $Session.Count; $idx++) {
          $RedfishSession = $Session[$idx]
          $Logger.info($(Trace-Session $RedfishSession "Submit Get Virtual Media task"))
          [Void] $tasks.Add($(Start-ScriptBlockThread $pool $ScriptBlock @($RedfishSession)))
        }

        $Results = Get-AsyncTaskResults $tasks
        return $Results
      } finally {
        $pool.close()
      }
    }

    end {
    }
  }
