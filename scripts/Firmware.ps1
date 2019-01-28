<# NOTE: iBMC Firmware module Cmdlets #>

function Get-iBMCOutbandFirmware {
<#
.SYNOPSIS
Query information about the updatable outband firmware resource collection of a server.

.DESCRIPTION
Query information about the updatable firmware resources of a server.
Only those out-band firmwares is included:
- ActiveBMC
- BackupBMC
- Bios
- MainBoardCPLD
- chassisDiskBP1CPLD

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.OUTPUTS
PSObject[]
Returns PSObject which contains all updatable firmware infomation if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $credential = Get-Credential
PS C:\> $session = Connect-iBMC -Address 10.1.1.2 -Credential $credential -TrustCert
PS C:\> $Firmwares = Get-iBMCOutbandFirmware $session
PS C:\> $Firmwares | fl

ActiveBMC                          : 3.18
BackupBMC                          : 3.18
Bios                               : 0.81
MainBoardCPLD                      : 2.02
chassisDiskBP1CPLD                 : 1.10

.LINK
https://github.com/Huawei/Huawei-iBMC-Cmdlets

Update-iBMCOutbandFirmware
Invoke-iBMCFileUpload
Get-iBMCSPResult
Set-iBMCSPService
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

    $Logger.info("Invoke Get BMC updatable outband firmware function")

    $ScriptBlock = {
      param($RedfishSession)
      $Logger.info($(Trace-Session $RedfishSession "Invoke Get BMC updatable outband firmware now"))

      $Output = New-Object PSObject

      # out-band
      $Logger.info($(Trace-Session $RedfishSession "Invoke Get BMC updatable out-band firmware now"))
      $Path = "/UpdateService/FirmwareInventory"
      $GetMembersResponse = Invoke-RedfishRequest $RedfishSession $Path | ConvertFrom-WebResponse
      $Members = $GetMembersResponse.Members
      for ($idx = 0; $idx -lt $Members.Count; $idx++) {
        $Member = $Members[$idx]
        $OdataId = $Member.'@odata.id'
        $InventoryName = $OdataId.Split("/")[-1]
        if ($InventoryName -in $BMC.OutBandFirmwares) {
          $Inventory = Invoke-RedfishRequest $RedfishSession $OdataId | ConvertFrom-WebResponse
          $Output |  Add-Member -MemberType NoteProperty $Inventory.Name $Inventory.Version
        }
      }

      return $Output
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Logger.info($(Trace-Session $RedfishSession "Submit Get BMC updatable outband firmware task"))
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $ScriptBlock @($RedfishSession)))
      }

      $Results = Get-AsyncTaskResults $tasks
      return ,$Results
    }
    finally {
      Close-Pool $pool
    }
  }

  end {
  }
}


function Set-iBMCSPService {
<#
.SYNOPSIS
Modify properties of the SP service resource.

.DESCRIPTION
Modify properties of the SP(Smart Provisioning) service resource.
Tips: only V5 servers used with BIOS version later than 0.39 support this function.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.PARAMETER StartEnabled
Indicates Whether SP start is enabled.
Support values are powershell boolean value: $true(1), $false(0).

.PARAMETER SysRestartDelaySeconds
Indicates Maximum time allowed for the restart of the OS.
A positive integer value is accept.

.OUTPUTS
Null
Returns Null if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $credential = Get-Credential
PS C:\> $session = Connect-iBMC -Address 10.1.1.2 -Credential $credential -TrustCert
PS C:\> Set-iBMCSPService -Session $session -StartEnabled $true -SysRestartDelaySeconds 60


.LINK
https://github.com/Huawei/Huawei-iBMC-Cmdlets

Get-iBMCOutbandFirmware
Update-iBMCOutbandFirmware
Invoke-iBMCFileUpload
Get-iBMCSPResult
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
    $StartEnabled,

    [int[]]
    [ValidateRange(1, [int]::MaxValue)]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 2)]
    $SysRestartDelaySeconds
  )

  begin {
  }

  process {
    Assert-ArrayNotNull $Session 'Session'

    $StartEnabledList = Get-OptionalMatchedSizeArray $Session $StartEnabled
    $SysRestartDelaySecondsList = Get-OptionalMatchedSizeArray $Session $SysRestartDelaySeconds

    $Logger.info("Invoke set SP Service function")

    $ScriptBlock = {
      param($RedfishSession, $Enabled, $SysRestartDelaySeconds)

      $Logger.info($(Trace-Session $RedfishSession "Invoke set SP Service function now"))
      # Enable SP Service
      $SPServicePath = "/Managers/$($RedfishSession.Id)/SPService"
      $EnableSpServicePayload = @{
        "SPStartEnabled"= $Enabled;
        "SysRestartDelaySeconds"= $SysRestartDelaySeconds;
        "SPTimeout"= 7200;
        "SPFinished"= $true;
      } | Remove-EmptyValues

      $Logger.Info($(Trace-Session $RedfishSession "Sending payload: $($EnableSpServicePayload | ConvertTo-Json)"))
      Invoke-RedfishRequest $RedfishSession $SPServicePath 'PATCH' $EnableSpServicePayload | Out-Null
      return $null
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $ParametersList = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Parameters = @($RedfishSession, $StartEnabledList[$idx], $SysRestartDelaySecondsList[$idx])
        if ($null -eq $StartEnabledList[$idx] -and $null -eq $SysRestartDelaySecondsList[$idx]) {
          throw $(Get-i18n FAIL_NO_UPDATE_PARAMETER)
        }
        [Void] $ParametersList.Add($Parameters)
      }

      for ($idx = 0; $idx -lt $ParametersList.Count; $idx++) {
        $Logger.info($(Trace-Session $RedfishSession "Submit set SP Service task"))
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $ScriptBlock $ParametersList[$idx]))
      }

      return Get-AsyncTaskResults $tasks
    }
    finally {
      Close-Pool $pool
    }
  }

  end {
  }
}


function Get-iBMCSPResult {
<#
.SYNOPSIS
Query information about the configuration result resource of the SP service.

.DESCRIPTION
Query information about the configuration result resource of the SP service.
Tips: only V5 servers used with BIOS version later than 0.39 support this function.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.OUTPUTS
PSObject[]
Returns PSObject indicates configuration result resource of SP Service if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $credential = Get-Credential
PS C:\> $session = Connect-iBMC -Address 10.1.1.2 -Credential $credential -TrustCert
PS C:\> $Result = Get-iBMCSPResult -Session $session
PS C:\> $Result

Id        : 1
Name      : SP Result
Status    : Idle
OSInstall :
Clone     :
Recover   :


.LINK
https://github.com/Huawei/Huawei-iBMC-Cmdlets

Get-iBMCOutbandFirmware
Update-iBMCOutbandFirmware
Invoke-iBMCFileUpload
Set-iBMCSPService
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

    $Logger.info("Invoke Get SP Result function")

    $ScriptBlock = {
      param($RedfishSession)

      $Logger.info($(Trace-Session $RedfishSession "Invoke Get SP Result function now"))
      $SPResultMemberPath = "/Managers/$($RedfishSession.Id)/SPService/SPResult"
      $Collection = Invoke-RedfishRequest $RedfishSession $SPResultMemberPath | ConvertFrom-WebResponse
      $Members = $Collection.Members
      if ($Members.Count -ge 1) {
        $GetSPResultPath = $Members[0].'@odata.id'
        $Result = Invoke-RedfishRequest $RedfishSession $GetSPResultPath | ConvertFrom-WebResponse
        $CleanUp = $Result | Clear-OdataProperties
        return $CleanUp
      } else {
        return $null
      }
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Logger.info($(Trace-Session $RedfishSession "Submit Get SP Result task"))
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $ScriptBlock @($RedfishSession)))
      }
      return Get-AsyncTaskResults $tasks
    }
    finally {
      Close-Pool $pool
    }
  }

  end {
  }
}



function Update-iBMCOutbandFirmware {
<#
.SYNOPSIS
Updata iBMC Outband firmware.

.DESCRIPTION
Updata iBMC Outband firmware.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.PARAMETER FileUri
Indicates the file uri of firmware update image file.

File Uri should be a string of up to 256 characters.
It supports HTTPS, SCP, SFTP, CIFS, TFTP, NFS and FILE file transfer protocols.

For examples:
- local storage: C:\2288H_V5_5288_V5-iBMC-V318.hpm or \\192.168.1.2\2288H_V5_5288_V5-iBMC-V318.hpm
- ibmc local temporary storage: /tmp/2288H_V5_5288_V5-iBMC-V318.hpm
- remote storage: protocol://username:password@hostname/directory/2288H_V5_5288_V5-iBMC-V318.hpm

.OUTPUTS
PSObject[]
Returns the update firmware task details if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $credential = Get-Credential
PS C:\> $session = Connect-iBMC -Address 10.1.1.2 -Credential $credential -TrustCert
PS C:\> Update-iBMCOutbandFirmware -Session $session -FileUri E:\2288H_V5_5288_V5-iBMC-V318.hpm

Id           : 1
Name         : Upgarde Task
ActivityName : [10.1.1.2] Upgarde Task
TaskState    : Completed
StartTime    : 2018-11-23T08:57:45+08:00
EndTime      : 2018-11-23T09:01:24+08:00
TaskStatus   : OK
TaskPercent  : 100%


This example shows how to update outband firmware with local file


.EXAMPLE

PS C:\> $credential = Get-Credential
PS C:\> $session = Connect-iBMC -Address 10.1.1.2 -Credential $credential -TrustCert
PS C:\> Update-iBMCOutbandFirmware -Session $session -FileUri '/tmp/2288H_V5_5288_V5-iBMC-V318.hpm'

Id           : 1
Name         : Upgarde Task
ActivityName : [10.1.1.2] Upgarde Task
TaskState    : Completed
StartTime    : 2018-11-23T08:57:45+08:00
EndTime      : 2018-11-23T09:01:24+08:00
TaskStatus   : OK
TaskPercent  : 100%

This example shows how to update outband firmware with ibmc temp file

.EXAMPLE

PS C:\> $credential = Get-Credential
PS C:\> $session = Connect-iBMC -Address 10.1.1.2 -Credential $credential -TrustCert
PS C:\> Update-iBMCOutbandFirmware -Session $session `
          -FileUri nfs://10.10.10.2/data/nfs/2288H_V5_5288_V5-iBMC-V318.hpm

Id           : 1
Name         : Upgarde Task
ActivityName : [10.1.1.2] Upgarde Task
TaskState    : Completed
StartTime    : 2018-11-23T08:57:45+08:00
EndTime      : 2018-11-23T09:01:24+08:00
TaskStatus   : OK
TaskPercent  : 100%

This example shows how to update outband firmware with NFS network file

.LINK
https://github.com/Huawei/Huawei-iBMC-Cmdlets

Get-iBMCOutbandFirmware
Update-iBMCInbandFirmware
Invoke-iBMCFileUpload
Get-iBMCSPResult
Set-iBMCSPService
Connect-iBMC
Disconnect-iBMC

#>
  [CmdletBinding()]
  param (
    [RedfishSession[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    $Session,

    [String[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 2)]
    $FileUri
  )

  begin {
  }

  process {
    Assert-ArrayNotNull $Session 'Session'
    Assert-ArrayNotNull $FileUri 'FileUri'
    $FileUriList = Get-MatchedSizeArray $Session $FileUri 'Session' 'FileUri'

    $Logger.info("Invoke upgrade BMC outband firmware function")

    $ScriptBlock = {
      param($RedfishSession, $ImageFilePath)

      $Logger.info($(Trace-Session $RedfishSession "Invoke upgrade outband firmware now"))
      $ImageFilePath = Invoke-FileUploadIfNeccessary $RedfishSession $ImageFilePath $BMC.OutBandImageFileSupportSchema
      $Payload = @{'ImageURI' = $ImageFilePath; }
      if (-not $ImageFilePath.StartsWith('/tmp', "CurrentCultureIgnoreCase")) {
        $ImageFileUri = New-Object System.Uri($ImageFilePath)
        if ($ImageFileUri.Scheme -ne 'file') {
          $Payload."TransferProtocol" = $ImageFileUri.Scheme.ToUpper();
        }
      }

      $Clone = $Payload.clone()
      $Clone.ImageURI = Protect-NetworkUriUserInfo $ImageFilePath
      $Logger.info($(Trace-Session $RedfishSession "Sending payload: $($Clone | ConvertTo-Json)"))

      # try submit upgrade outband firmware task
      $Path = "/UpdateService/Actions/UpdateService.SimpleUpdate"
      $Response = Invoke-RedfishRequest $RedfishSession $Path 'Post' $Payload
      return $Response | ConvertFrom-WebResponse
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $ImageFilePath = $FileUriList[$idx]
        $Parameters = @($RedfishSession, $ImageFilePath)
        $Logger.info($(Trace-Session $RedfishSession "Submit upgrade BMC outband firmware task"))
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $ScriptBlock $Parameters))
      }

      $RedfishTasks = Get-AsyncTaskResults $tasks
      $Logger.Info("Upgrade outband firmware tasks: " + $RedfishTasks)
      return Wait-RedfishTasks $pool $Session $RedfishTasks -ShowProgress
    }
    finally {
      Close-Pool $pool
    }
  }

  end {
  }
}
