<# NOTE: iBMC BIOS Setting Module Cmdlets #>

function Export-iBMCBIOSSetting {
<#
.SYNOPSIS
Export iBMC BIOS and BMC Settings

.DESCRIPTION
Export iBMC BIOS and BMC Settings

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.PARAMETER DestFilePath
The dest settings file path:

Dest path examples:
1. export to ibmc local temporary storage: /tmp/filename.xml
2. export to remote storage: protocol://username:password@hostname/directory/filename.xml
   support protocol list: sftp, https, nfs, cifs, scp

.OUTPUTS
PSObject[]
Returns the export configuration task array if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

Export to remote NFS

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> $Tasks = Export-iBMCBIOSSetting $session 'nfs://10.10.10.3/data/nfs/bios.xml'

.EXAMPLE

Export to iBMC local storage

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> $Tasks = Export-iBMCBIOSSetting $session '/tmp/bios.xml'


.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document
Import-iBMCBIOSSetting
Reset-iBMCBIOS
Restore-iBMCFactory
Connect-iBMC
Disconnect-iBMC

#>
  [CmdletBinding()]
  param (
    [RedfishSession[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position=0)]
    $Session,

    [string[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position=1)]
    $DestFilePath
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
    Assert-ArrayNotNull $DestFilePath 'DestFilePath'
    $DestFilePath = Get-MatchedSizeArray $Session $DestFilePath 'Session' 'DestFilePath'
  }

  process {
    $Logger.info("Invoke Export BIOS Configurations function")

    $ScriptBlock = {
      param($Session, $DestFilePath)
      $payload = @{
        'Type' = "URI";
        'Content' = $DestFilePath;
      }
      $Path = "/redfish/v1/Managers/1/Actions/Oem/Huawei/Manager.ExportConfiguration"
      $Response = Invoke-RedfishRequest $Session $Path 'Post' $payload
      return $Response | ConvertFrom-WebResponse
      # Wait-RedfishTask $Session $Task
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx=0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Logger.info($(Trace-Session $RedfishSession "Submit export BIOS configs to $DestFilePath[$idx] task"))
        $Parameters = @($RedfishSession, $DestFilePath[$idx])
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $ScriptBlock $Parameters))
      }

      $RedfishTasks = Get-AsyncTaskResults $tasks
      $Logger.Info("Export configuration task: " + $RedfishTasks)
      return Wait-RedfishTasks $pool $Session $RedfishTasks -ShowProgress
    } finally {
      $pool.close()
    }
  }

  end {

  }
}

function Import-iBMCBIOSSetting {
<#
.SYNOPSIS
Import iBMC BIOS and BMC configuration

.DESCRIPTION
Import iBMC BIOS and BMC configuration. The BIOS setup configuration takes effect upon the next restart of the system.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.PARAMETER ConfigFilePath
The local bios&bmc configuration file path

.OUTPUTS
PSObject[]
Returns the import configuration task array if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

Import local configuration file

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> $Tasks = Import-iBMCBIOSSetting $session 'C:\10.10.10.2.xml'


.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document
Export-iBMCBIOSSetting
Reset-iBMCBIOS
Restore-iBMCFactory
Connect-iBMC
Disconnect-iBMC

#>
  [CmdletBinding()]
  param (
    [RedfishSession[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position=0)]
    $Session,

    [string[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position=1)]
    $ConfigFilePath
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
    Assert-ArrayNotNull $ConfigFilePath 'ConfigFilePath'
    $ConfigFilePath = Get-MatchedSizeArray $Session $ConfigFilePath 'Session' 'ConfigFilePath'
  }

  process {
    $Logger.info("Invoke Import BIOS Configurations function, batch size: $($Session.Count)")

    $ScriptBlock = {
      param($Session, $ConfigFilePath)
      $UploadFileName = "$(Get-RandomIntGuid).hpm"
      Invoke-RedfishFirmwareUpload $Session $UploadFileName $ConfigFilePath | Out-Null

      $payload = @{
        'Type' = "URI";
        'Content' = "/tmp/web/$UploadFileName";
      }
      $Path = "/redfish/v1/Managers/1/Actions/Oem/Huawei/Manager.ImportConfiguration"
      $Response = Invoke-RedfishRequest $Session $Path 'Post' $payload
      return $Response | ConvertFrom-WebResponse
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx=0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Logger.info($(Trace-Session $RedfishSession "Submit import BIOS config from $ConfigFilePath[$idx] task"))
        $Parameters = @($RedfishSession, $ConfigFilePath[$idx])
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $ScriptBlock $Parameters))
      }

      $RedfishTasks = Get-AsyncTaskResults $tasks
      $Logger.Info("Import configuration task: " + $RedfishTasks)
      return Wait-RedfishTasks $pool $Session $RedfishTasks -ShowProgress
    } finally {
      $pool.close()
    }
  }

  end {
  }
}


function Reset-iBMCBIOS {
<#
.SYNOPSIS
Restore BIOS default settings.

.DESCRIPTION
Restore BIOS default settings. The BIOS setup configuration takes effect upon the next restart of the system.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.OUTPUTS
None
Returns none if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

Restore BIOS default settings

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> Reset-iBMCBIOS $session


.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document
Export-iBMCBIOSSetting
Import-iBMCBIOSSetting
Restore-iBMCFactory
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
    $Logger.info("Invoke Reset BIOS configuration function")

    $ScriptBlock = {
      param($RedfishSession)
      $Path = "/Systems/$($RedfishSession.Id)/Bios/Actions/Bios.ResetBios"
      Invoke-RedfishRequest $RedfishSession $Path 'Post' | Out-Null
      return $null
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx=0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Logger.info($(Trace-Session $RedfishSession "Submit Reset BIOS configuration task"))
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

function Restore-iBMCFactory {
<#
.SYNOPSIS
Restore the factory settings.

.DESCRIPTION
Restore the factory settings.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.OUTPUTS
None
Returns None if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

Restore factory settings

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> Restore-iBMCFactory $session


.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Export-iBMCBIOSSetting
Import-iBMCBIOSSetting
Reset-iBMCBIOS
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
    $Logger.info("Invoke Restore BIOS Factory function")

    $ScriptBlock = {
      param($RedfishSession)
      $Path = "/Managers/$($RedfishSession.Id)/Actions/Oem/Huawei/Manager.RestoreFactory"
      Invoke-RedfishRequest $RedfishSession $Path 'Post' | Out-Null
      return $null
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx=0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Logger.info($(Trace-Session $RedfishSession "Submit Restore BIOS Factory task"))
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