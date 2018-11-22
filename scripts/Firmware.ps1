<# NOTE: iBMC Firmware module Cmdlets #>

function Get-iBMCFirmwareInfo {
  <#
.SYNOPSIS
Query information about the upgradable firmware resource collection of a server.

.DESCRIPTION
Query information about the upgradable firmware resources of a server.
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

PS C:\> $session = Connect-iBMC -Address 10.10.10.2 -Username username -Password password -TrustCert
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

Update-iBMCFirmware
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

function Update-iBMCFirmware {
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
PS C:\> Set-iBMCService -Session $session -ServiceName VNC -Enabled $true -Port 5900

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

    [String[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
    $Firmware,

    [String[]]
    [parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 2)]
    $UpgradeFilePath
  )

  begin {
    Assert-ArrayNotNull $Session 'Session'
    Assert-ArrayNotNull $Firmware 'Firmware'
    Assert-ArrayNotNull $UpgradeFilePath 'UpgradeFilePath'

    $FirmwareList = Get-MatchedSizeArray $Session $Firmware 'Session' 'Firmware'
    $UpgradeFilePathList = Get-MatchedSizeArray $Session $UpgradeFilePath 'Session' 'UpgradeFilePath'
  }

  process {
    $Logger.info("Invoke upgrade BMC firmware function")

    $ScriptBlock = {
      param($RedfishSession, $Firmware, $FilePath)
      $Logger.info($(Trace-Session $RedfishSession "Invoke upgrade $Firmware with file $FilePath now"))

      $Uri = New-Object System.Uri($FilePath)
      if ($Uri.Scheme -eq 'file') {
        # if ($Uri.IsUnc) { # network file
        # }
        # else { # local file
        # }
        $UploadFileName = "$(Get-RandomIntGuid).hpm"
        $Logger.Info($(Trace-Session $RedfishSession "$FilePath is a local file, upload to iBMC now"))
        Invoke-RedfishFirmwareUpload $RedfishSession $UploadFileName $FilePath | Out-Null
        $Logger.Info($(Trace-Session $RedfishSession "File uploaded as $UploadFileName success"))

        $payload = @{
          'ImageURI' = "/tmp/web/$UploadFileName";
        }
      }
      elseif ($Uri.Scheme -in $BMC.SupportImageFileSchema) {
        $payload = @{
          'ImageURI'         = $FilePath;
          "TransferProtocol" = $Uri.Scheme.ToUpper();
        }
      }
      else {
        throw $([string]::Format($(Get-i18n ERROR_FILE_PATH_NOT_SUPPORT), 'UpgradeFilePath', $FilePath))
      }

      $Path = "/UpdateService/Actions/UpdateService.SimpleUpdate"
      $Response = Invoke-RedfishRequest $RedfishSession $Path 'Post' $payload
      return $Response | ConvertFrom-WebResponse
    }

    try {
      $tasks = New-Object System.Collections.ArrayList
      $pool = New-RunspacePool $Session.Count
      for ($idx = 0; $idx -lt $Session.Count; $idx++) {
        $RedfishSession = $Session[$idx]
        $Item = $FirmwareList[$idx];
        $FilePath = $UpgradeFilePathList[$idx]
        $Parameters = @($RedfishSession, $Item, $FilePath)
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

