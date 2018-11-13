<# NOTE: iBMC Power Control module Cmdlets #>
try { [PowerControlType] | Out-Null } catch {
Add-Type -TypeDefinition @'
    public enum PowerControlType {
      On,
      GracefulShutdown,
      ForceRestart,
      Nmi,
      ForcePowerCycle
    }
'@
}

function Set-iBMCSystemPower {
<#
.SYNOPSIS
Control iBMC Operation System Power.

.DESCRIPTION
Control iBMC Operation System Power.

- On：上电
- GracefulShutdown：正常下电
- ForceRestart：强制重启
- Nmi：触发不可屏蔽中断
- ForcePowerCycle：强制下电再上电


.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.PARAMETER PowerControlType
Indicates the Operation System Power type.
Available Value Set:  On, GracefulShutdown, ForceRestart, Nmi, ForcePowerCycle.
- On: power on the OS.
- GracefulShutdown: gracefully shut down the OS.
- ForceRestart: forcibly restart the OS.
- Nmi: triggers a non-maskable interrupt (NMI).
- ForcePowerCycle: forcibly power off and then power on the OS.

.OUTPUTS
None
Returns None if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> Set-iBMCSystemPower -Session $session


.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Connect-iBMC
Disconnect-iBMC

#>
  [CmdletBinding()]
  param (
    [RedfishSession[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    $Session,

    [PowerControlType[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
    $PowerControlType
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
    Assert-ArrayNotNull $PowerControlType 'PowerControlType'
    $PowerControlTypeList = Get-MatchedSizeArray $Session $PowerControlType
  }

  process {
    $Logger.info("Invoke Control iBMC OS Power function")

    $ScriptBlock = {
      param($RedfishSession, $Payload)
      $(Get-Logger).info($(Trace-Session $RedfishSession "Invoke Control iBMC OS Power now"))
      $Path = "/Systems/$($RedfishSession.Id)/Actions/Oem/Huawei/ComputerSystem.FruControl"
      Invoke-RedfishRequest $RedfishSession $Path 'POST' $Payload | Out-Null
      return $null
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Payload = @{
          FruControlType=$PowerControlTypeList[$idx];
          FruID=$BMC.FRUOperationSystem;
        } | Resolve-EnumValues

        $Parameters = @($RedfishSession, $Payload)
        $Logger.info($(Trace-Session $RedfishSession "Submit Control iBMC OS Power task"))
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
