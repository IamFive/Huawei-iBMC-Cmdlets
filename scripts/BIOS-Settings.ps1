<# NOTE: iBMC BIOS Setting Module Cmdlets #>

function Export-iBMCBIOSSetting {
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
    $Logger.info("Export BIOS Configurations Now")

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
        $Logger.info("Submit export BIOS configurations task for: $($Session[$idx].Address), `
         dest file path is: $($DestFilePath[$idx])")
        $Parameters = @($Session[$idx], $DestFilePath[$idx])
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
    $Logger.info("Import BIOS Configurations Now, batch size: $($Session.Count)")

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
        $Logger.info("[$($Session[$idx].Address)] Submit import BIOS config task, `
         config file path is: $($ConfigFilePath[$idx])")
        $Parameters = @($Session[$idx], $ConfigFilePath[$idx])
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
  [CmdletBinding()]
  param (

  )

  begin {
  }

  process {
  }

  end {
  }
}

function Restore-iBMCFactory {
  [CmdletBinding()]
  param (

  )

  begin {
  }

  process {
  }

  end {
  }
}