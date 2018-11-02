<# NOTE: iBMC deploy module Cmdlets #>

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

Connect-iBMCVirtualMedia
Disconnect-iBMCVirtualMedia
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
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Logger.info($(Trace-Session $RedfishSession "Submit Get Virtual Media task"))
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


function Connect-iBMCVirtualMedia {
<#
.SYNOPSIS
Connect to virtual media.

.DESCRIPTION
Connect to virtual media.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.PARAMETER ImageFilePath
VRI of the virtual media image
Only the URI connections using the Network File System (NFS), Common Internet File System (CIFS) or HTTPS protocols are supported.

.OUTPUTS
PSObject[]
Returns the Connect Virtual Media task details if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> Connect-iBMCVirtualMedia $session 'nfs://10.10.10.10/usr/SLE-12-Server-DVD-x86_64-GM-DVD1.ISO'

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Get-iBMCVirtualMedia
Disconnect-iBMCVirtualMedia
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
    $ImageFilePath
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
    Assert-ArrayNotNull $ImageFilePath 'ImageFilePath'
    $ImageFilePath = Get-MatchedSizeArray $Session $ImageFilePath 'Session' 'ImageFilePath'
  }

  process {
    $Logger.info("Invoke Connect Virtual Media function")

    $ScriptBlock = {
      param($RedfishSession, $ImageFilePath)
      $Payload = @{
        "VmmControlType" = "Connect";
        "Image"          = $ImageFilePath;
      }
      $Path = "/Managers/$($RedfishSession.Id)/VirtualMedia/CD/Oem/Huawei/Actions/VirtualMedia.VmmControl"
      $Response = Invoke-RedfishRequest $RedfishSession $Path 'POST' $Payload
      return $Response | ConvertFrom-WebResponse
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Parameters = @($RedfishSession, $ImageFilePath[$idx])
        $Logger.info($(Trace-Session $RedfishSession "Submit Connect Virtual Media task"))
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $ScriptBlock $Parameters))
      }

      $RedfishTasks = Get-AsyncTaskResults $tasks
      $Results = Wait-RedfishTasks $pool $Session $RedfishTasks -ShowProgress
      return $Results
    }
    finally {
      $pool.close()
    }
  }

  end {
  }
}


function Disconnect-iBMCVirtualMedia {
<#
.SYNOPSIS
Disconnect virtual media.

.DESCRIPTION
Disconnect virtual media.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.OUTPUTS
PSObject[]
Returns the Disconnect Virtual Media task details if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> Disconnect-iBMCVirtualMedia $session

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Get-iBMCVirtualMedia
Connect-iBMCVirtualMedia
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
    $Logger.info("Invoke Disconnect Virtual Media function")

    $ScriptBlock = {
      param($RedfishSession)
      $Payload = @{
        "VmmControlType" = "Disconnect";
      }
      $Path = "/Managers/$($RedfishSession.Id)/VirtualMedia/CD/Oem/Huawei/Actions/VirtualMedia.VmmControl"
      $Response = Invoke-RedfishRequest $RedfishSession $Path 'POST' $Payload
      return $Response | ConvertFrom-WebResponse
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Parameters = @($RedfishSession)
        $Logger.info($(Trace-Session $RedfishSession "Submit Disconnect Virtual Media task"))
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $ScriptBlock $Parameters))
      }

      $RedfishTasks = Get-AsyncTaskResults $tasks
      $Results = Wait-RedfishTasks $pool $Session $RedfishTasks -ShowProgress
      return $Results
    }
    finally {
      $pool.close()
    }
  }

  end {
  }
}

function Get-iBMCBootupSequence {
<#
.SYNOPSIS
Query bios boot up device sequence.

.DESCRIPTION
Query bios boot up device sequence. Boot up device contains: Hdd, Cd, Pxe, Others.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.OUTPUTS
Array[String[]]
Returns string array identifies boot up device in order if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> Get-iBMCBootupSequence $session

Hdd
Cd
Pxe
Others

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Set-iBMCBootupSequence
Get-iBMCBootSourceOverride
Set-iBMCBootSourceOverride
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
    $Logger.info("Invoke Get Bootup Sequence function")

    $ScriptBlock = {
      param($RedfishSession)
      $Path = "/redfish/v1/Systems/$($RedfishSession.Id)"
      $Response = $(Invoke-RedfishRequest $RedfishSession $Path | ConvertFrom-WebResponse)
      # V3
      if ($null -ne $Response.Oem.Huawei.BootupSequence) {
        $Logger.info($(Trace-Session $RedfishSession "Find System.Oem.Huawei.BootupSequence, return directly"))
        return $Response.Oem.Huawei.BootupSequence
      }
      else {
        # V5
        $Logger.info($(Trace-Session $RedfishSession "V5 BMC, will try get sequence from BIOS API"))
        $BiosPath = "$Path/Bios"
        $BiosResponse = $(Invoke-RedfishRequest $RedfishSession $BiosPath | ConvertFrom-WebResponse)
        $Attrs = $BiosResponse.Attributes
        $seq = New-Object System.Collections.ArrayList
        0..3 | ForEach-Object {
          $BootType = $Attrs."BootTypeOrder$_"
          [Void] $seq.Add($BMC.V52V3Mapping[$BootType])
        }
        return $seq
      }
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Logger.info($(Trace-Session $RedfishSession "Submit Get Bootup Sequence task"))
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


function Set-iBMCBootupSequence {
<#
.SYNOPSIS
Set bios boot up device sequence.

.DESCRIPTION
Set bios boot up device sequence.
Boot up device contains: Hdd, Cd, Pxe, Others.
New boot up sequence settings take effect upon the next restart of the system.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.PARAMETER BootSequence
A array set of boot device in order, should contains all available boot devices.
example: @(@('Hdd', 'Cd', 'Pxe', 'Others'))

.OUTPUTS
None
Returns None if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> $BootUpSequence = ,@('Pxe', 'Hdd', 'Cd', 'Others')
PS C:\> Set-iBMCBootupSequence $session $BootUpSequence

Set boot up device sequence for single iBMC server

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2,10.10.10.3 -Username username -Password password -TrustCert
PS C:\> $BootUpSequence = @(@('Pxe', 'Hdd', 'Cd', 'Others'), @('Cd', 'Pxe', 'Hdd', 'Others'))
PS C:\> Set-iBMCBootupSequence $session $BootUpSequence

Set boot up device sequence for multiple iBMC server


.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Get-iBMCBootupSequence
Get-iBMCBootSourceOverride
Set-iBMCBootSourceOverride
Connect-iBMC
Disconnect-iBMC

#>
  [CmdletBinding()]
  param (
    [RedfishSession[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    $Session,

    [string[][]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
    $BootSequence
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
    Assert-ArrayNotNull $BootSequence 'BootSequence'
    $BootSequence = Get-MatchedSizeArray $Session $BootSequence 'Session' 'BootSequence'
    # validate boot sequence input
    $BootSequence | ForEach-Object {
      if ($null -ne $_ -or $_.Count -eq 4) {
        $diff = Compare-Object $_ $BMC.V32V5Mapping.Keys -PassThru
        if ($null -eq $diff) {
          return
        }
      }
      throw [String]::format($(Get-i18n "ERROR_ILLEGAL_BOOT_SEQ"), $_ -join ",")
    }
  }

  process {
    $Logger.info("Invoke Set Bootup Sequence function")

    $ScriptBlock = {
      param($RedfishSession, $BootSequence)
      $Path = "/redfish/v1/Systems/$($RedfishSession.Id)"
      $Response = Invoke-RedfishRequest $RedfishSession $Path
      $System = $Response | ConvertFrom-WebResponse

      if ($null -ne $System.Oem.Huawei.BootupSequence) {
        # V3
        $Logger.info($(Trace-Session $RedfishSession "[V3] Will set boot sequence using System resource"))
        $Payload = @{
          "Oem" = @{
            "Huawei" = @{
              "BootupSequence" = $BootSequence;
            };
          };
        }
        $Headers = @{'If-Match' = $Response.Headers.get('ETag'); }
        Invoke-RedfishRequest $RedfishSession $Path 'PATCH' $Payload $Headers | Out-Null
        return $null
      }
      else {
        # V5
        $Logger.info($(Trace-Session $RedfishSession "[V5] Will set boot sequence using BIOS settings resource"))
        $SetBiosPath = "$Path/Bios/Settings"
        $V5BootSequence = @{}
        for ($idx = 0; $idx -lt $BootSequence.Count; $idx++) {
          $BootType = $BMC.V32V5Mapping[$BootSequence[$idx]]
          $V5BootSequence."BootTypeOrder$idx" = $BootType
        }
        $Logger.info($(Trace-Session $RedfishSession "[V5] Boot device sequence: $V5BootSequence"))
        $Payload = @{"Attributes" = $V5BootSequence; }
        Invoke-RedfishRequest $RedfishSession $SetBiosPath 'PATCH' $Payload | Out-Null
        return $null
      }
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Parameters = @($RedfishSession, $BootSequence[$idx])
        $Logger.info($(Trace-Session $RedfishSession "Submit Get Bootup Sequence task"))
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


function Get-iBMCBootSourceOverride {
<#
.SYNOPSIS
Query bios boot source override target.

.DESCRIPTION
Query bios boot source override target. Boot up device contains: 'None', 'Pxe', 'Floppy', 'Cd', 'Hdd', 'BiosSetup'.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.OUTPUTS
String[]
Returns bios boot source override target if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> Get-iBMCBootSourceOverride $session

None


.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Get-iBMCBootupSequence
Set-iBMCBootupSequence
Set-iBMCBootSourceOverride
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
    $Logger.info("Invoke Get Boot Source Override function")

    $ScriptBlock = {
      param($RedfishSession)
      $(Get-Logger).info($(Trace-Session $RedfishSession "Get boot source override target now"))
      $Path = "/redfish/v1/Systems/$($RedfishSession.Id)"
      $Response = $(Invoke-RedfishRequest $RedfishSession $Path | ConvertFrom-WebResponse)
      return $Response.Boot.BootSourceOverrideTarget
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Logger.info($(Trace-Session $RedfishSession "Submit Get Boot Source Override task"))
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


function Set-iBMCBootSourceOverride {
<#
.SYNOPSIS
Modify bios boot source override target.

.DESCRIPTION
Modify bios boot source override target.
Available boot source override target: 'None', 'Pxe', 'Floppy', 'Cd', 'Hdd', 'BiosSetup'.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.PARAMETER BootSourceOverrideTarget
BootSourceOverrideTarget specifies the bios boot source override target

.OUTPUTS
Null
Returns Null if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
PS C:\> Set-iBMCBootSourceOverride $session 'Pxe'

Set boot source override target for single iBMC server

.EXAMPLE

PS C:\> $session = Connect-iBMC -Address 10.10.10.2,10.10.10.3 -Username username -Password password -TrustCert
PS C:\> Set-iBMCBootupSequence $session 'Pxe','Hdd'

Set boot source override target for multiple iBMC server


.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Get-iBMCBootupSequence
Set-iBMCBootupSequence
Get-iBMCBootSourceOverride
Connect-iBMC
Disconnect-iBMC

#>
  [CmdletBinding()]
  param (
    [RedfishSession[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    $Session,

    [String[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
    [ValidateSet('None', 'Pxe', 'Floppy', 'Cd', 'Hdd', 'BiosSetup')]
    $BootSourceOverrideTarget
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
    Assert-ArrayNotNull $BootSourceOverrideTarget 'BootSourceOverrideTarget'
    $BootSourceOverrideTarget = Get-MatchedSizeArray $Session $BootSourceOverrideTarget 'Session' 'BootSourceOverrideTarget'
  }

  process {
    $Logger.info("Invoke Set Bootup Sequence function")

    $ScriptBlock = {
      param($RedfishSession, $BootSourceOverrideTarget)
      $(Get-Logger).info($(Trace-Session $RedfishSession "Set boot source override target to $BootSourceOverrideTarget"))
      $Path = "/redfish/v1/Systems/$($RedfishSession.Id)"
      $Payload = @{
        "Boot" = @{
          "BootSourceOverrideTarget" = $BootSourceOverrideTarget;
        };
      }

      Invoke-RedfishRequest $RedfishSession $Path 'PATCH' $Payload | Out-Null
      return $null
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Parameters = @($RedfishSession, $BootSourceOverrideTarget[$idx])
        $Logger.info($(Trace-Session $RedfishSession "Submit Set Boot source override target task"))
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
