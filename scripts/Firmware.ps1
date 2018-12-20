<# NOTE: iBMC Firmware module Cmdlets #>

function Get-iBMCFirmwareInfo {
<#
.SYNOPSIS
Query information about the upgradable firmware resource collection of a server.

.DESCRIPTION
Query information about the upgradable firmware resources of a server.
Include all in-band firmwares and part of out-band firmwares.
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
Returns PSObject which contains all upgradable firmware infomation if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $credential = Get-Credential
PS C:\> $session = Connect-iBMC -Address 10.1.1.2 -Credential $credential -TrustCert
PS C:\> $Firmwares = Get-iBMCFirmwareInfo $session
PS C:\> $Firmwares

ActiveBMC                          : 3.00
BackupBMC                          : 3.08
Bios                               : 0.81
MainBoardCPLD                      : 2.02
chassisDiskBP1CPLD                 : 1.09
SR430C-M 1G (SAS3108)@[RAID Card1] : 4.270.00-4382
LOM (X722)@[LOM]                   : 3.33 0x80000f09 255.65535.255

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Set-iBMCSPService
Update-iBMCInbandFirmware
Update-iBMCOutbandFirmware
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

    $Logger.info("Invoke Get BMC upgradable firmware function")

    $ScriptBlock = {
      param($RedfishSession)
      $Logger.info($(Trace-Session $RedfishSession "Invoke Get BMC upgradable firmware now"))

      $Output = New-Object PSObject

      # out-band
      $Logger.info($(Trace-Session $RedfishSession "Invoke Get BMC upgradable out-band firmware now"))
      $Path = "/UpdateService/FirmwareInventory"
      $GetMembersResponse = Invoke-RedfishRequest $RedfishSession $Path | ConvertFrom-WebResponse
      $Members = $GetMembersResponse.Members
      for ($idx = 0; $idx -lt $Members.Count; $idx++) {
        $Member = $Members[$idx];
        $OdataId = $Member.'@odata.id'
        $InventoryName = $OdataId.Split("/")[-1]
        if ($InventoryName -in $BMC.OutBandFirmwares) {
          $Inventory = Invoke-RedfishRequest $RedfishSession $OdataId | ConvertFrom-WebResponse
          $Output |  Add-Member -MemberType NoteProperty $Inventory.Name $Inventory.Version
        }
      }

      # in-band
      try {
        $Logger.info($(Trace-Session $RedfishSession "Invoke Get BMC upgradable in-band firmware now"))
        $Path = "/Managers/$($RedfishSession.Id)/SPService/DeviceInfo"
        $DeviceInfo = Invoke-RedfishRequest $RedfishSession $Path | ConvertFrom-WebResponse
        for ($idx = 0; $idx -lt $BMC.InBandFirmwares.Count; $idx++) {
          $DeviceName = $BMC.InBandFirmwares[$idx];
          $Devices = $DeviceInfo."$DeviceName";
          if ($null -ne $Devices -and $Devices -is [Array] -and $Devices.Count -gt 0) {
            $Devices | ForEach-Object {
              $Name = $_.DeviceName
              $Model = $_.Controllers[0].Model
              $Position = $_.Position
              $Version = $_.Controllers[0].FirmwareVersion
              $Key = "$($Name) ($($Model))@[$($Position)]"
              $Output |  Add-Member -MemberType NoteProperty $Key $Version
            }
          }
        }
      }
      catch {
        $Logger.warn($(Trace-Session $RedfishSession "Failed to load in-band firmwares, reason: $_"))
      }

      return $Output
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Logger.info($(Trace-Session $RedfishSession "Submit Get BMC upgradable firmware task"))
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

function Update-iBMCInbandFirmware {
<#
.SYNOPSIS
Updata iBMC Inband firmware.

.DESCRIPTION
Updata iBMC Inband firmware. This function transfers firmware to SP service.
Those transfered firmwares takes effect upon next system restart when SP Service start is enabled (Set-iBMCSPService function is provided for this).
Tips: Only V5 servers used with BIOS version later than 0.39 support this function.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.PARAMETER Type
Indicates the firmware type to be updated.
Support value set: "Firmware", "SP".
- Firmware: inband firmware
- SP: Smart Provisioning Service

.PARAMETER FileUri
Indicates the file uri of firmware update image file.

- When "Type" is Firmware:
The firmware upgrade file is in .zip format.
It supports HTTPS, SFTP, NFS, CIFS, SCP and FILE file transfer protocols.
The URI cannot contain the following special characters: ||, ;, &&, $, |, >>, >, <

For examples:
- local storage: C:\Firmware.zip or \\192.168.1.2\Firmware.zip
- ibmc local temporary storage: /tmp/Firmware.zip
- remote storage: protocol://username:password@hostname/directory/Firmware.zip

- When "Type" is SP:
only the CIFS and NFS protocols.
The URI cannot contain the following special characters: ||, ;, &&, $, |, >>, >, <

For examples:
- remote storage: nfs://username:password@hostname/directory/Firmware.zip

.PARAMETER SignalFileUri
Indicates the file path of the certificate file of the upgrade file.
- Signal file should be in .asc format
- it supports HTTPS, SFTP, NFS, CIFS, SCP and FILE file transfer protocols.
- The URI cannot contain the following special characters: ||, ;, &&, $, |, >>, >, <

For examples:
- local storage: C:\Firmware.zip.asc or \\192.168.1.2\Firmware.zip.asc
- ibmc local temporary storage: /tmp/Firmware.zip.asc
- remote storage: protocol://username:password@hostname/directory/Firmware.zip.asc

.OUTPUTS
Null
Returns Null if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $credential = Get-Credential
PS C:\> $session = Connect-iBMC -Address 10.1.1.2 -Credential $credential -TrustCert
PS C:\> Update-iBMCInbandFirmware -Session $session -Type Firmware `
          -FileUri "E:\NIC(X722)-Electrical-05022FTM-FW(3.33).zip" `
          -SignalFileUri "E:\NIC(X722)-Electrical-05022FTM-FW(3.33).zip.asc"
PS C:\> Set-iBMCSPService -Session $session -StartEnabled $true -SysRestartDelaySeconds 60
PS C:\> Reset-iBMCServer -Session $session -ResetType ForceRestart

This example shows how to update inband firmware with local file, enabled SP service and restart server

.EXAMPLE

PS C:\> $credential = Get-Credential
PS C:\> $session = Connect-iBMC -Address 10.1.1.2 -Credential $credential -TrustCert
PS C:\> Update-iBMCInbandFirmware -Session $session -Type Firmware `
          -FileUri "/tmp/NIC(X722)-Electrical-05022FTM-FW(3.33).zip" `
          -SignalFileUri "/tmp/NIC(X722)-Electrical-05022FTM-FW(3.33).zip.asc"
PS C:\> Set-iBMCSPService -Session $session -StartEnabled $true -SysRestartDelaySeconds 60
PS C:\> Reset-iBMCServer -Session $session -ResetType ForceRestart

This example shows how to update inband firmware with ibmc temp file, enabled SP service and restart server

.EXAMPLE

PS C:\> $credential = Get-Credential
PS C:\> $session = Connect-iBMC -Address 10.1.1.2 -Credential $credential -TrustCert
PS C:\> Update-iBMCInbandFirmware -Session $session -Type Firmware `
          -FileUri "nfs://115.159.160.190/data/nfs/NIC(X722)-Electrical-05022FTM-FW(3.33).zip" `
          -SignalFileUri "nfs://115.159.160.190/data/nfs/NIC(X722)-Electrical-05022FTM-FW(3.33).zip.asc"
PS C:\> Set-iBMCSPService -Session $session -StartEnabled $true -SysRestartDelaySeconds 60
PS C:\> Reset-iBMCServer -Session $session -ResetType ForceRestart

This example shows how to update inband firmware with remote file, enabled SP service and restart server

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Get-iBMCFirmwareInfo
Set-iBMCSPService
Update-iBMCOutbandFirmware
Connect-iBMC
Disconnect-iBMC

#>
  [CmdletBinding()]
  param (
    [RedfishSession[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    $Session,

    [String[]]
    [ValidateSet("Firmware", "SP")]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
    $Type,

    [String[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 2)]
    $FileUri,

    [String[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 3)]
    $SignalFileUri
  )

  begin {
  }

  process {
    Assert-ArrayNotNull $Session 'Session'
    Assert-ArrayNotNull $Type 'Type'
    Assert-ArrayNotNull $FileUri 'FileUri'
    Assert-ArrayNotNull $SignalFileUri 'SignalFileUri'

    $FirmwareTypeList = Get-MatchedSizeArray $Session $Type 'Session' 'Type'
    $FileUriList = Get-MatchedSizeArray $Session $FileUri 'Session' 'FileUri'
    $SignalFileUriList = Get-MatchedSizeArray $Session $SignalFileUri

    $Logger.info("Invoke upgrade BMC inband firmware function")

    $ScriptBlock = {
      param($RedfishSession, $InbandFirmwareType, $ImageFilePath, $SignalFilePath)

      $Logger.info($(Trace-Session $RedfishSession "Invoke upgrade $InbandFirmwareType with file $ImageFilePath now"))

      # transfer firmware image file
      $GetSPUpdateService = "/Managers/$($RedfishSession.Id)/SPService/SPFWUpdate"
      $SPServices = Invoke-RedfishRequest $RedfishSession $GetSPUpdateService | ConvertFrom-WebResponse
      if ($SPServices.Members.Count -gt 0) {
        $Payload = @{
          "Parameter" = "all";
          "UpgradeMode" = "Recover";
          "ActiveMethod" = "OSRestart";
        }

        if ($InbandFirmwareType -eq "Firmware") {
          $ImageURI = Invoke-FileUploadIfNeccessary $RedfishSession $ImageFilePath $BMC.InBandImageFileSupportSchema
          $SignalURI = Invoke-FileUploadIfNeccessary $RedfishSession $SignalFilePath $BMC.SignalFileSupportSchema
          $Payload.ImageURI = $ImageURI
          $Payload.SignalURI = $SignalURI
          $Payload.ImageType = "Firmware";
        } else {
          $ImageURI = Invoke-FileUploadIfNeccessary $RedfishSession $ImageFilePath $BMC.SPImageFileSupportSchema
          $Payload.ImageURI = $ImageURI
          $Payload.ImageType = "SP";
        }

        if ($Payload.ImageURI.StartsWith('/tmp', "CurrentCultureIgnoreCase")) {
          $Payload.ImageURI = "file://$($Payload.ImageURI)";
        }
        if ($Payload.SignalURI.StartsWith('/tmp', "CurrentCultureIgnoreCase")) {
          $Payload.SignalURI = "file://$($Payload.SignalURI)";
        }

        $Logger.Info("payload $($Payload | ConvertTo-Json)")
        $SPServiceOdataId = $SPServices.Members[0].'@odata.id'
        $SPFWUpdateUri = "$SPServiceOdataId/Actions/SPFWUpdate.SimpleUpdate"
        Invoke-RedfishRequest $RedfishSession $SPFWUpdateUri 'POST' $Payload | Out-Null


        $Uri = New-Object System.Uri($Payload.ImageURI)
        $FileName = $Uri.Segments[-1]
        $Transfered = $false
        $WaitTransfer = 60
        while ($WaitTransfer -gt 0) {
          # wait transfer progress finished
          $Transfer = Invoke-RedfishRequest $RedfishSession $SPServiceOdataId | ConvertFrom-WebResponse
          $Percent = $Transfer.TransferProgressPercent
          $Logger.Info($(Trace-Session $RedfishSession "File $($Transfer.TransferFileName) transfer $($Percent)%"))
          if ($Transfer.TransferFileName -eq $FileName) {
            if ($null -ne $Percent -and $Percent -eq 100) {
              $Logger.Info($(Trace-Session $RedfishSession "File $FileName transfer finished."))
              $Transfered = $true
              break
            }
          }
          $WaitTransfer = $WaitTransfer - 1
          Start-Sleep -Seconds 2
        }

        if (-not $Transfered) {
          throw $(Get-i18n "FAIL_SP_FILE_TRANSFER")
        }

        # Enable SP Service
        # $SPServicePath = "/Managers/$($RedfishSession.Id)/SPService"
        # $EnableSpServicePayload = @{
        #   "SPStartEnabled"= $true;
        #   "SysRestartDelaySeconds"= 30;
        #   "SPTimeout"= 7200;
        #   "SPFinished"= $true;
        # }
        # Invoke-RedfishRequest $RedfishSession $SPServicePath 'PATCH' $EnableSpServicePayload | Out-Null
        # try {
        #   # Restart Server
        #   if ($Transfered) {
        #     $Payload = @{
        #       "ResetType" = [ResetType]::ForceRestart;
        #     } | Resolve-EnumValues
        #     $Path = "/Systems/$($RedfishSession.Id)/Actions/ComputerSystem.Reset"
        #     Invoke-RedfishRequest $RedfishSession $Path 'POST' $Payload | Out-Null
        #   }
        # } catch {
        #   throw $(Get-i18n "FAIL_SP_RESET_SYSTEM")
        # }

        return $null
      }
      else {
        throw $(Get-i18n "FAIL_SP_NOT_SUPPORT")
      }
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $FirmwareType = $FirmwareTypeList[$idx];
        $ImageFilePath = $FileUriList[$idx]
        $SignalFilePath = $SignalFileUriList[$idx]
        $Parameters = @($RedfishSession, $FirmwareType, $ImageFilePath, $SignalFilePath)
        $Logger.info($(Trace-Session $RedfishSession "Submit upgrade BMC inband firmware task"))
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $ScriptBlock $Parameters))
      }

      return Get-AsyncTaskResults $tasks
    }
    finally {
      $pool.close()
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
Support values are powershell boolean value: $true, $false.

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
http://www.huawei.com/huawei-ibmc-cmdlets-document

Get-iBMCFirmwareInfo
Update-iBMCInbandFirmware
Update-iBMCOutbandFirmware
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
      $pool.close()
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
Updata iBMC Outband firmware. Out-band, in-band and SP firmwares are supported.
Inband and SP firmware update is only supported by V5 servers used with BIOS version later than 0.39.

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
ActivityName : [112.93.129.9] Upgarde Task
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
ActivityName : [112.93.129.9] Upgarde Task
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
          -FileUri nfs://115.159.160.190/data/nfs/2288H_V5_5288_V5-iBMC-V318.hpm

Id           : 1
Name         : Upgarde Task
ActivityName : [112.93.129.9] Upgarde Task
TaskState    : Completed
StartTime    : 2018-11-23T08:57:45+08:00
EndTime      : 2018-11-23T09:01:24+08:00
TaskStatus   : OK
TaskPercent  : 100%

This example shows how to update outband firmware with NFS network file

.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Get-iBMCFirmwareInfo
Update-iBMCInbandFirmware
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

      $Logger.info($(Trace-Session $RedfishSession "Invoke upgrade outband firmware with file $ImageFileUri now"))
      $ImageFilePath = Invoke-FileUploadIfNeccessary $RedfishSession $ImageFilePath $BMC.OutBandImageFileSupportSchema
      $payload = @{'ImageURI' = $ImageFilePath; }
      if (-not $ImageFilePath.StartsWith('/tmp', "CurrentCultureIgnoreCase")) {
        $ImageFileUri = New-Object System.Uri($ImageFilePath)
        if ($ImageFileUri.Scheme -ne 'file') {
          $payload."TransferProtocol" = $ImageFileUri.Scheme.ToUpper();
        }
      }
      # try submit upgrade outband firmware task
      $Path = "/UpdateService/Actions/UpdateService.SimpleUpdate"
      $Response = Invoke-RedfishRequest $RedfishSession $Path 'Post' $payload
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
      $pool.close()
    }
  }

  end {
  }
}


<#
function Update-iBMCFirmware {
.SYNOPSIS
Updata iBMC firmware.

.DESCRIPTION
Updata iBMC firmware. Out-band, in-band and SP firmwares are supported.
Inband and SP firmware update is only supported by V5 servers used with BIOS version later than 0.39.

.PARAMETER Session
iBMC redfish session object which is created by Connect-iBMC cmdlet.
A session object identifies an iBMC server to which this cmdlet will be executed.

.PARAMETER Type
Indicates the firmware type to be updated.
Support value set: "OutBand", "InBand", "SP".
- OutBand: outband firmware
- InBand: inband firmware
- SP: Smart Provisioning Service

.PARAMETER FileUri
Indicates the file uri of firmware update image file.

- When "Type" is OutBand:
It is a string of up to 256 characters.
It supports HTTPS, SCP, SFTP, CIFS, TFTP, NFS, and FILE file transfer protocols.

- When "Type" is InBand:
The firmware upgrade file is in .zip format.
It supports HTTPS, SFTP, NFS, CIFS, SCP and FILE file transfer protocols.
The URI cannot contain the following special characters: ||, ;, &&, $, |, >>, >, <

- When "Type" is SP:
only the CIFS and NFS protocols.
The URI cannot contain the following special characters: ||, ;, &&, $, |, >>, >, <

.PARAMETER SignalFileUri
Indicates the file path of the certificate file of the upgrade file.
- This parameter only works when "Type" is InBand and SP.
- Signal file should be in .asc format
- it supports HTTPS, SFTP, NFS, CIFS, SCP and FILE file transfer protocols.
- The URI cannot contain the following special characters: ||, ;, &&, $, |, >>, >, <

.OUTPUTS
Null
Returns Null if cmdlet executes successfully.
In case of an error or warning, exception will be returned.

.EXAMPLE

PS C:\> $credential = Get-Credential
PS C:\> $session = Connect-iBMC -Address 10.1.1.2 -Credential $credential -TrustCert
PS C:\> Update-iBMCFirmware -Session $session -Type Outband `
          -FileUri E:\2288H_V5_5288_V5-iBMC-V318.hpm

Id           : 1
Name         : Upgarde Task
ActivityName : [112.93.129.9] Upgarde Task
TaskState    : Completed
StartTime    : 2018-11-23T08:57:45+08:00
EndTime      : 2018-11-23T09:01:24+08:00
TaskStatus   : OK
TaskPercent  : 100%



.EXAMPLE

PS C:\> $credential = Get-Credential
PS C:\> $session = Connect-iBMC -Address 10.1.1.2 -Credential $credential -TrustCert
PS C:\> Update-iBMCFirmware -Session $session -Type Outband `
          -FileUri nfs://115.159.160.190/data/nfs/2288H_V5_5288_V5-iBMC-V318.hpm

Id           : 1
Name         : Upgarde Task
ActivityName : [112.93.129.9] Upgarde Task
TaskState    : Completed
StartTime    : 2018-11-23T08:57:45+08:00
EndTime      : 2018-11-23T09:01:24+08:00
TaskStatus   : OK
TaskPercent  : 100%

.EXAMPLE

PS C:\> $credential = Get-Credential
PS C:\> $session = Connect-iBMC -Address 10.1.1.2 -Credential $credential -TrustCert
PS C:\> Update-iBMCFirmware -Session $session -Type Inband `
          -FileUri "E:\NIC(X722)-Electrical-05022FTM-FW(3.33).zip" `
          -SignalFileUri "E:\NIC(X722)-Electrical-05022FTM-FW(3.33).zip.asc"

Id           : 1
Name         : Upgarde Task
ActivityName : [112.93.129.9] Upgarde Task
TaskState    : Completed
StartTime    : 2018-11-23T08:57:45+08:00
EndTime      : 2018-11-23T09:01:24+08:00
TaskStatus   : OK
TaskPercent  : 100%


.EXAMPLE

PS C:\> $credential = Get-Credential
PS C:\> $session = Connect-iBMC -Address 10.1.1.2 -Credential $credential -TrustCert
PS C:\> Update-iBMCFirmware -Session $session -Type Inband `
          -FileUri nfs://115.159.160.190/data/nfs/NIC(X722)-Electrical-05022FTM-FW(3.33).zip `
          -SignalFileUri nfs://115.159.160.190/data/nfs/NIC(X722)-Electrical-05022FTM-FW(3.33).zip.asc

Id           : 1
Name         : Upgarde Task
ActivityName : [112.93.129.9] Upgarde Task
TaskState    : Completed
StartTime    : 2018-11-23T08:57:45+08:00
EndTime      : 2018-11-23T09:01:24+08:00
TaskStatus   : OK
TaskPercent  : 100%



.LINK
http://www.huawei.com/huawei-ibmc-cmdlets-document

Get-iBMCService
Connect-iBMC
Disconnect-iBMC

  [CmdletBinding()]
  param (
    [RedfishSession[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0)]
    $Session,

    [FirmwareType[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
    $Type,

    [String[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 2)]
    $FileUri,

    [String[]]
    [parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 3)]
    $SignalFileUri
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
    Assert-ArrayNotNull $Type 'Type'
    Assert-ArrayNotNull $FileUri 'FileUri'

    $FirmwareTypeList = Get-MatchedSizeArray $Session $Type 'Session' 'Type'
    $FileUriList = Get-MatchedSizeArray $Session $FileUri 'Session' 'FileUri'
    $SignalFileUriList = Get-OptionalMatchedSizeArray $Session $SignalFileUri
  }

  process {
    $Logger.info("Invoke upgrade BMC firmware function")

    $ScriptBlock = {
      param($RedfishSession, $FirmwareType, $ImageFilePath, $SignalFilePath)

      function Invoke-FileUploadIfNeccessary ($RedfishSession, $ImageFilePath, $SupportSchema) {
        $ImageFileUri = New-Object System.Uri($ImageFilePath)
        if ($ImageFileUri.Scheme -notin $SupportSchema) {
          throw $([string]::Format($(Get-i18n ERROR_FILE_URI_NOT_SUPPORT), $ImageFileUri, $SupportSchema.join(", ")))
        }

        $ImageFileUri = New-Object System.Uri($ImageFilePath)
        if ($ImageFileUri.Scheme -eq 'file') {
          $Ext = [System.IO.Path]::GetExtension($ImageFilePath)
          if ($null -eq $Ext -or $Ext -eq '') {
            $Ext = '.hpm'
          }
          $UploadFileName = "$(Get-RandomIntGuid)$Ext"

          # upload image file to bmc
          $Logger.Info($(Trace-Session $RedfishSession "$ImageFilePath is a local file, upload to iBMC now"))
          Invoke-RedfishFirmwareUpload $RedfishSession $UploadFileName $ImageFilePath | Out-Null
          $Logger.Info($(Trace-Session $RedfishSession "File uploaded as $UploadFileName success"))
          return "/tmp/web/$UploadFileName";
        }

        return $ImageFilePath;
      }

      function Update-OutbandFirmware ($RedfishSession, $ImageFilePath) {
        $payload = @{'ImageURI' = $ImageFilePath; }
        if (-not $ImageFilePath.StartsWith('/tmp/web/')) {
          $ImageFileUri = New-Object System.Uri($ImageFilePath)
          if ($ImageFileUri.Scheme -ne 'file') {
            $payload."TransferProtocol" = $ImageFileUri.Scheme.ToUpper();
          }
        }
        # try submit upgrade outband firmware task
        $Path = "/UpdateService/Actions/UpdateService.SimpleUpdate"
        $Response = Invoke-RedfishRequest $RedfishSession $Path 'Post' $payload
        return $Response | ConvertFrom-WebResponse
      }

      function Update-InbandFirmware ($RedfishSession, $Payload) {
        # try submit upgrade inband firmware task
        $SPServicePath = "/Managers/$($RedfishSession.Id)/SPService"
        # Enable SP Service
        $EnableSpServicePayload = @{
          "SPStartEnabled"= $true;
          "SysRestartDelaySeconds"= 30;
          "SPTimeout"= 7200;
          "SPFinished"= $true;
        }
        Invoke-RedfishRequest $RedfishSession $SPServicePath 'PATCH' $EnableSpServicePayload | Out-Null

        $GetSPUpdateService = "/Managers/$($RedfishSession.Id)/SPService/SPFWUpdate"
        $SPServices = Invoke-RedfishRequest $RedfishSession $GetSPUpdateService | ConvertFrom-WebResponse
        if ($SPServices.Members.Count -gt 0) {
          if ($payload.ImageURI.StartsWith('/tmp/web')) {
            $payload."ImageURI" = "file://$($payload.ImageURI)";
          }
          if ($payload.SignalURI.StartsWith('/tmp/web')) {
            $payload."SignalURI" = "file://$($payload.SignalURI)";
          }

          $SPServiceOdataId = $SPServices.Members[0].'@odata.id'
          $SPFWUpdateUri = "$SPServiceOdataId/Actions/SPFWUpdate.SimpleUpdate"
          $Response = Invoke-RedfishRequest $RedfishSession $SPFWUpdateUri 'POST' $payload

          # TODO 重启-os
          # TODO /Managers/1/SPService/SPResult/1
          return $Response | ConvertFrom-WebResponse
        } else {
          throw $(Get-i18n "FAIL_SP_NOT_SUPPORT")
        }
      }

      $Logger.info($(Trace-Session $RedfishSession "Invoke upgrade $FirmwareType with file $ImageFileUri now"))
      if ($FirmwareType -eq [FirmwareType]::OutBand) {
        $ImageFilePath = Invoke-FileUploadIfNeccessary $RedfishSession $ImageFilePath $BMC.OutBandImageFileSupportSchema
        return Update-OutbandFirmware $RedfishSession $ImageFilePath
      }
      else {
        if ($null -eq $SignalFilePath -or $SignalFilePath -eq '') {
          throw $(Get-i18n ERROR_SIGNAL_FILE_EMPTY)
        }

        $Payload = @{
          "Parameter" = "all";
          "UpgradeMode" = "Recover";
          "ActiveMethod" = "OSRestart";
        }

        if ($FirmwareType -eq [FirmwareType]::InBand) {
          $ImageURI = Invoke-FileUploadIfNeccessary $RedfishSession $ImageFilePath $BMC.InBandImageFileSupportSchema
          $SignalURI = Invoke-FileUploadIfNeccessary $RedfishSession $SignalFilePath $BMC.SignalFileSupportSchema
          $Payload.ImageURI = $ImageURI
          $Payload.SignalURI = $SignalURI
          $Payload.ImageType = "Firmware";
        } else {
          $ImageURI = Invoke-FileUploadIfNeccessary $RedfishSession $ImageFilePath $BMC.SPImageFileSupportSchema
          $Payload.ImageURI = $ImageURI
          $Payload.ImageType = "SP";
        }

        return Update-InbandFirmware $RedfishSession $Payload
      }

      return $null
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $FirmwareType = $FirmwareTypeList[$idx];
        $ImageFilePath = $FileUriList[$idx]
        $SignalFilePath = $SignalFileUriList[$idx]
        $Parameters = @($RedfishSession, $FirmwareType, $ImageFilePath, $SignalFilePath)
        $Logger.info($(Trace-Session $RedfishSession "Submit upgrade BMC firmware task"))
        [Void] $tasks.Add($(Start-ScriptBlockThread $pool $ScriptBlock $Parameters))
      }

      $RedfishTasks = Get-AsyncTaskResults $tasks
      $Logger.Info("Upgrade firmware tasks: " + $RedfishTasks)
      return Wait-RedfishTasks $pool $Session $RedfishTasks -ShowProgress
    }
    finally {
      $pool.close()
    }
  }

  end {
  }
}
#>